class QuickReply < ApplicationRecord
  has_many :quick_reply_items, ->{ where(deleted: false) }
  has_many :response_data
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

  def set_lineuser_to_next_reply_id
    #quick_reply_itemを無視、quick_replyのnext_reply_idのみを参照してlineuserにnext_reply_idをセットする
    if self.next_reply_id.present?
      switch_quick_reply_id = self.next_reply_id
      lineuser.update_attributes!(quick_reply_id: switch_quick_reply_id)
    else
      lineuser.update_attributes!(quick_reply_id: nil)
    end
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

  def self.quick_reply_items_param(quick_reply)
    items = quick_reply.quick_reply_items
    items_array = []
    items.each do |item|
      data = "[#{quick_reply.reply_type}][#{item.id}]" + item.text
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
    quick_reply = {:items => items_array}
  end
end