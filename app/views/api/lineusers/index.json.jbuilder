json.statuses do
  json.array! @status_array do |status|
    json.name status[0]
    json.id status[1]
  end
end
json.lineusers do
  json.array! @lineusers do |lineuser|
    json.extract! lineuser, :id, :pictureUrl, :name
    json.lastmessage do
      json.to_bot lineuser.lastmessage&.to_bot
      json.content lineuser.lastmessage&.content
    end
  end
end