class LineNotify
  require 'net/http'
  require 'uri'

    TOKEN = ENV["LINE_NOTIFY_TOKEN"]
    URI = URI.parse("https://notify-api.line.me/api/notify")

    def self.make_request(msg, token)
      request = Net::HTTP::Post.new(URI)
      request["Authorization"] = "Bearer #{token}"
      request.set_form_data(message: msg)
      request
    end

    def self.send(msg, token)
      request = make_request(msg, token)
      response = Net::HTTP.start(URI.hostname, URI.port, use_ssl: URI.scheme == "https") do |https|
        https.request(request)
      end
    end
end