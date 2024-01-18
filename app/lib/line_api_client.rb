require 'net/http'
require 'uri'

module LineApiClient
  CHANNEL_ID = ENV['LINE_CHANNEL_ID'].freeze
  CLIENT_SECRET = ENV['LINE_CHANNEL_SECRET'].freeze
  CHANNEL_ACCESS_TOKEN = ENV['LINE_CHANNEL_ACCESS_TOKEN'].freeze

  def get_line_user_id(id_token)
    uri = URI.parse('https://api.line.me/oauth2/v2.1/verify')
    res = Net::HTTP.post_form(uri, {
      'id_token': id_token,
      'client_id': CHANNEL_ID
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

  def send_push_message(line_user_id, messages)
    return if messages.nil?

    uri = URI.parse('https://api.line.me/v2/bot/message/push')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === 'https'

    body = {
      to: line_user_id,
      messages: messages
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
    Rails.logger.error("An error occurred during LINE messaging request: #{e.message}")
    nil
  end

  def build_messages_for_unnotified_bookmarks(user_id)
    user = User.find(user_id)
    bookmarks = user.bookmarks.for_notification
    messages = [{
      type: 'text',
      text: "後で読もうと思ったまま、お忘れの記事はないですか？\nLaterlessから未読のブックマークをお届けします。"
    }]
    bookmarks.each do |bookmark|
      messages.push({
        type: 'text',
        text: "『#{bookmark.title}』\n#{bookmark.url}"
      })
    end
    messages.length == 1 ? [nil, nil] : [messages, bookmarks]
  end
end
