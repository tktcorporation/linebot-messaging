class Bot::ImagesController < ApplicationController
  before_action :check_auth

  def show
    message = Message.get(params[:id])
    response = Manager.get_img_binary(message)
    if response.class == Net::HTTPOK
      send_data response.body, type: 'image/jpeg', disposition: 'inline'
    else
      render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
    end
  end

  private
    def check_auth
      return if !params[:id]
      if Message.get(params[:id]).lineuser.bot.user_id != @current_user.id
        render file: Rails.root.join('public/404.html'), status: 404, layout: false, content_type: 'text/html'
      end
    end
end