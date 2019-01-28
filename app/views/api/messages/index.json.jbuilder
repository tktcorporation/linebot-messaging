json.lineuser do |json|
  json.set! @lineusers do
    json.array!(@lineusers.messages) do |message|
      json.extract! message, :content, :to_bot, :created_at
    end
  end
end
