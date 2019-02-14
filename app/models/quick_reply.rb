class QuickReply < ApplicationRecord
  has_many :quick_reply_items, ->{ where(deleted: false) }
  has_one :response_datum
  has_one :quick_reply_schedule, dependent: :destroy
  has_one :quick_reply_text, dependent: :destroy
  belongs_to :form
  belongs_to :lineuser, optional: true

  scope :undeleted, ->{ where(deleted: false) }

  validates :name, presence: true, lt4bytes: true, length: { in: 1..250 }
  validates :form_id, numericality: true
  validates :text, presence: true#, lt4bytes: true
  validates :reply_type, numericality: true


  def destroy
    self.deleted = true
    save
  end

  def switch_quick_reply
    self.is_normal_message = false
    save
  end

  def items_param
    items = self.quick_reply_items
    items_array = []
    items.each do |item|
      data = "[#{self.reply_type}][#{item.id}]" + item.text
      label = item.text
      item = QuickReply.create_item(data, label)
      items_array.push(item)
    end
    return {:items => items_array}
  end

  def days_param
    return nil if reply_type != 3
    time = Time.now
    quick_reply_schedule = self.quick_reply_schedule
    items_array = []
    available_day_array = quick_reply_schedule.available_day.split("").map(&:to_i)
    quick_reply_schedule.duration_days.times do |i|
      time += 60*60*24
      if available_day_array[time.wday] != 0
        data = "[#{reply_type}][#{id}]" + time.strftime("%Y-%m-%d")
        item = QuickReply.create_item(data, time.strftime("%m月%d日"))
        items_array.push(item)
      end
    end
    return {:items => items_array}
  end

  def check_param
    items_array = []
    2.times do |i|
      check = i == 0 ? "決定" : "戻る"
      data = "[#{99}]" + "[#{id}]" + check
      item = QuickReply.create_item(data, check)
      items_array.push(item)
    end
    return {:items => items_array}
  end

  def times_param(day)
    #day(Time)の空いている予定を、0時+30分*start_count(Int)から最大num(Int)個取得し、quick_reply用のparamで返す
    quick_reply_schedule = self.quick_reply_schedule
    day = Time.local(day.year, day.month, day.day, 0, 0, 0, 0)
    calendar_events = GoogleCalendar.get_events(self.form.bot)
    available_array = []
    48.times do |j|
      available_array.push(0)
    end
    available_day_array = Manager.available_array_day(calendar_events, day, available_array)
    items_array = []
    duration_num = quick_reply_schedule.duration_num
    day += 60*60*(quick_reply_schedule.start_num)
    count = quick_reply_schedule.start_num * 2
    quick_reply_schedule.term_num.times do |i|
      day += 60*duration_num * 30 if i != 0

      if available_day_array[(count+i*duration_num)..(count+i*duration_num+duration_num-1)].all?{|n| n == 0 }
        data = "[4][#{self.id}]" + day.strftime("%Y-%m-%d %H:%M")
        item = QuickReply.create_item(data, day.strftime("%H:%M"))
        items_array.push(item)
      end
    end
    data = "[#{99}]" + "[#{id}]" + "戻る"
    item = QuickReply.create_item(data, "戻る")
    items_array.push(item)
    return {:items => items_array}
  end

  def self.get(id)
    self.find(id)
  end

  def self.get_before_quick_reply_plural(quick_reply)
    self.undeleted.where(form_id: quick_reply.form_id, next_reply_id: quick_reply.id)
  end

  def self.optional_create(form_id, quick_reply_params, quick_reply_schedule_params)
    form = Form.get(form_id)
    quick_reply = form.quick_replies.new(name: quick_reply_params[:name], text: quick_reply_params[:text], reply_type: quick_reply_params[:reply_type])
    if before_quick_reply = form.quick_replies.order(order_count: :desc).limit(1)[0]
      quick_reply.order_count = before_quick_reply.order_count + 1
      quick_reply.save!
      before_quick_reply.update_attributes!(next_reply_id: quick_reply.id)
    else
      quick_reply.order_count = 0
      quick_reply.save!
      quick_reply.form.update_attributes!(first_reply_id: quick_reply.id)
    end
    case quick_reply.reply_type
    when 0
    when 1
    when 2
      self.create_text(quick_reply)
    when 3
      self.create_schedule(quick_reply, quick_reply_schedule_params)
    when 5
      self.create_date(quick_reply)
    end
    return quick_reply
  end

  def self.create_schedule(quick_reply, quick_reply_schedule_params)
    quick_reply.is_normal_message = false
    quick_reply.save!
    QuickReplySchedule.create_option(quick_reply, quick_reply_schedule_params)
  end

  def self.create_date(quick_reply)
    quick_reply.is_normal_message = false
    quick_reply.save!
  end

  def self.create_text(quick_reply)
    quick_reply.is_normal_message = false
    quick_reply.save!
    QuickReplyText.create_option(quick_reply)
  end

  def self.select_array(quick_replies)
    quick_replies.map{|reply| [reply.name, reply.id]}
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

  def self.create_item(data, label)
    return pushed_item = {:type=>"action",
                  :action=>{
                            :type => "postback",
                            :label => label,
                            :data => data,
                            :displayText => ("回答：" + label)
                            }
                }
  end
end