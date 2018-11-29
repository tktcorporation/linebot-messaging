class LineuserSearch
  include ActiveModel::Model

  attr_accessor :name, :convert_time_from, :convert_time_to, :session_time_from, :session_time_to, :messages_created_at_from, :messages_created_at_to, :limit
end