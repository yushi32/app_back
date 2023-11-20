class Api::V1::UsersController < Api::V1::BaseController
  require 'net/http'
  require 'uri'

  def update
    id_token = params[:idToken]
    channel_id = ENV["LIFF_CHANNEL_ID"]
    
    res = Net::HTTP.post_form(URI.parse('https://api.line.me/oauth2/v2.1/verify'), { 'id_token' => id_token, 'client_id' => channel_id })
    line_user_id = JSON.parse(res.body)['sub']

    #if user.nil?
    #  user = User.create(line_user_id:)
    #elsif (session[:user_id] = user.id)
    #  render json: user
    #end
    render json: current_user

  end
end
