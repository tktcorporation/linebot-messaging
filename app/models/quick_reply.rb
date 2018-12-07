class QuickReply < ApplicationRecord
  has_many :quick_reply_items, ->{ where(deleted: false) }
  has_many :response_data
  has_one :quick_reply_schedule, dependent: :destroy
  has_one :quick_reply_text, dependent: :destroy
  belongs_to :form
  belongs_to :lineuser, optional: true

  scope :undeleted, ->{ where(deleted: false) }

  validates :name, presence: true
  validates :form_id, presence: true
  validates :text, presence: true

  def destroy
    self.deleted = true
    save
  end

  def switch_quick_reply
    self.is_normal_message = false
    save
  end

  def self.get(id)
    self.find(id)
  end

  def self.get_before_quick_reply_plural(quick_reply)
    self.undeleted.where(form_id: quick_reply.form_id, next_reply_id: quick_reply.id)
  end

  def self.create(form_id, quick_reply_params)
    form = Form.get(form_id)
    quick_reply = form.quick_replies.new(quick_reply_params)
    if before_quick_reply = form.quick_replies.order(order_count: :desc).limit(1)[0]
      quick_reply.order_count = before_quick_reply.order_count + 1
      quick_reply.save!
      before_quick_reply.update_attributes!(next_reply_id: quick_reply.id)
    else
      quick_reply.order_count = 0
      quick_reply.save!
      quick_reply.form.update_attributes!(first_reply_id: quick_reply.id)
    end
  end

  def relational_delete
    QuickReply.transaction do
      before_quick_replies = QuickReply.get_before_quick_reply_plural(self)
      if before_quick_replies.present?
        if self.next_reply_id.present?
          before_quick_replies.update_all(next_reply_id: self.next_reply_id)
        else
          before_quick_replies.update_all(next_reply_id: nil)
        end
      else
        if self.next_reply_id.present?
          self.form.update_attributes(first_reply_id: self.next_reply_id)
        else
          self.form.update_attributes(first_reply_id: nil)
        end
      end
      self.destroy
    end
  rescue => e
    p e.message
  end

  def self.extract_by_phase_of_lineuser(lineuser, form)
    self.find_by(form_id: form.id, id: lineuser.quick_reply_id)
  end

  def items_param
    items = self.quick_reply_items
    items_array = []
    items.each do |item|
      data = "[#{self.reply_type}][#{item.id}]" + item.text
      pushed_item = {:type=>"action",
                :action=>{
                          :type => "postback",
                          :label => item.text,
                          :data => data,
                          :text => item.text
                          }
              }
      items_array.push(pushed_item)
    end
    return {:items => items_array}
  end

  def days_param
    return nil if reply_type != 3
    day = Time.now
    duration_days = self.quick_reply_schedule.duration_days
    items_array = []
    duration_days.times do |i|
      day += 60*60*24 if i != 0
      data = "[#{reply_type}][#{id}]" + day.strftime("%Y-%m-%d")
      item = QuickReply.create_item(data, day.strftime("%m月%d日"))
      items_array.push(item)
    end
    return {:items => items_array}
  end

  def times_param(quick_reply, day, num, start_count)
    #day(Time)の空いている予定を、0時+30分*start_count(Int)から最大num(Int)個取得し、quick_reply用のparamで返す
    day = Time.local(day.year, day.month, day.day, 0, 0, 0, 0)
    calendar_events = GoogleCalendar.get_events(self.form.bot)
    available_array = []
    48.times do |j|
      available_array.push(0)
    end
    available_day_array = Manager.available_array_day(calendar_events, day, available_array)
    p "==============available_day_array================="
    p available_day_array
    items_array = []
    day += 60*30*start_count
    num.times do |i|
      count = start_count
      day += 60*30 if i != 0
      if available_day_array[count + i] == 0
        data = "[4][#{quick_reply.id}]" + day.strftime("%Y-%m-%d %H:%M")
        item = QuickReply.create_item(data, day.strftime("%H:%M"))
        items_array.push(item)
      end
    end
    return {:items => items_array}
  end

  def self.create_item(data, label)
    return pushed_item = {:type=>"action",
                  :action=>{
                            :type => "postback",
                            :label => label,
                            :data => data,
                            :text => label
                            }
                }
  end
end