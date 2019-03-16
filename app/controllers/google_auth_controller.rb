APPLICATION_NAME = "calendar"

class GoogleAuthController < ApplicationController
  require 'google/apis/calendar_v3'
  require 'googleauth'
  require 'googleauth/stores/file_token_store'
  require 'fileutils'
  require 'time'

  def redirect
    bot = Bot.get(params[:bot_id])
    client = Signet::OAuth2::Client.new(client_options(bot))
    redirect_to client.authorization_uri.to_s
  end

  def callback
    #bot = Bot.get_by_google_auth_hash(params[:hash])
    #bot = Bot.get_with_callback_hash(params[:hash])
    bot = current_user.bot
    GoogleCalendar.callback_process(bot, params[:code])
    redirect_to bot_url(id: bot.id)
  end

  private
  def client_options(bot)
    return client_option = {
      client_id: bot.google_api_set.client_id,
      client_secret: bot.google_api_set.client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://www.googleapis.com/oauth2/v4/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: "https://#{ENV.fetch('DOMAIN_NAME')}/google_auth/callback/#{bot.callback_hash}",
      additional_parameters: {prompt:'consent'},
    }
  end

end