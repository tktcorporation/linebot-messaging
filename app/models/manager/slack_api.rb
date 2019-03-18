class Manager::SlackApi
  def self.push_message(message, webhook_url)
    notifier = Slack::Notifier.new(webhook_url)
    notifier.ping(message)
  end
end