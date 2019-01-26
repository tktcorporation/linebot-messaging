json.set! :lineuser do
  json.name(@lineuser.name)
  json.pictureUrl(@lineuser.pictureUrl)
  json.messages do
    json.array! @lineuser.messages do |message|
      json.extract! message,:id, :content, :to_bot, :created_at
    end
  end
end