require 'net/http'
require 'uri'

module LineApiClient
  LINE_CHANNEL_ID = ENV["LINE_CHANNEL_ID"].freeze

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
end