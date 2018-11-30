class CallbackController < ApplicationController
  require 'line/bot'

  protect_from_forgery except: :callback
  skip_before_action :require_sign_in!
  def callback
    bot = Bot.get_with_callback_hash(params[:hash])
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client(bot).validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    events = client(bot).parse_events_from(body)
    events.each { |event|
      Manager.start_event(event, bot.id)
    }
    head :ok
  end

  private
    def client(bot)
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = bot.channel_secret
        config.channel_token = bot.channel_token
      }
    end
end