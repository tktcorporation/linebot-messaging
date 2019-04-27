json.lineuser do
  json.extract! @lineuser, :id, :pictureUrl, :name, :is_closed
  json.status_id @lineuser.status&.id ? @lineuser.status.id : 0
  json.converted @lineuser.converted_lineuser.present?
  json.response_data do
    json.array! @lineuser.response_data do |response|
      json.quick_reply response.quick_reply.name
      json.response_text response.response_text
    end
  end
  json.messages do
    json.array! @lineuser.messages do |message|
      json.extract! message, :id, :to_bot, :content, :msg_type, :created_at
    end
  end
end