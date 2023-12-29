require 'net/http'
require 'uri'

module LineApiClient
  LINE_CHANNEL_ID = ENV["LINE_CHANNEL_ID"].freeze
  CLIENT_SECRET = ENV['LINE_CHANNEL_SECRET'].freeze
  CHANNEL_ACCESS_TOKEN = ENV['LINE_CHANNEL_ACCESS_TOKEN'].freeze

  def get_line_user_id(id_token)
    uri = URI.parse('https://api.line.me/oauth2/v2.1/verify')
    res = Net::HTTP.post_form(uri, {
      'id_token' => id_token,
      'client_id' => LINE_CHANNEL_ID
    })
    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)['sub']
    else
      nil
    end
  rescue Net::ReadTimeout, Net::OpenTimeout
    Rails.logger.error("LINE ID Token verification request timed out.")
    nil
  rescue StandardError => e
    Rails.logger.error("An error occurred during LINE ID Token verification: #{e.message}")
    nil
  end

  def send_unread_bookmarks(line_user_id)
    uri = URI.parse('https://api.line.me/v2/bot/message/push')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === 'https'

    body = {
      to: line_user_id,
      messages: [
        {
            "type": "text",
            "text": "test"
        }
      ]
    }
    headers = {
      'Content-Type': 'application/json',
      Authorization: "Bearer #{CHANNEL_ACCESS_TOKEN}"
    }
    res = http.post(uri.path, body.to_json, headers)

  rescue Net::ReadTimeout, Net::OpenTimeout
    Rails.logger.error('LINE messaging request timed out.')
    nil
  rescue StandardError => e
    Rails.logger.error("An error occurred during LINE ID Token verification: #{e.message}")
    nil
  end

  private

  def get_channel_access_token
    uri = URI.parse('https://api.line.me/oauth2/v3/token')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === 'https'
  
    body = {
      grant_type: 'client_credentials',
      client_id: LINE_CHANNEL_ID,
      client_secret: CLIENT_SECRET
    }
    headers = { 'Content-Type': 'application/x-www-form-urlencoded' }
    res = http.post(uri.path, URI.encode_www_form(body), headers)
  
    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)['access_token']
    else
      nil
    end
  rescue Net::ReadTimeout, Net::OpenTimeout
    Rails.logger.error('LINE ID Token verification request timed out.')
    nil
  rescue StandardError => e
    Rails.logger.error("An error occurred during LINE ID Token verification: #{e.message}")
    nil
  end
end
