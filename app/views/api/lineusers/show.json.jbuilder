json.lineuser do
  json.extract! @lineuser, :id, :pictureUrl, :name
  json.messages do
    json.array! @lineuser.messages do |message|
      json.extract! message, :id, :to_bot, :content, :msg_type, :created_at
    end
  end
end