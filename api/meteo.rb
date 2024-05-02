require 'json'
require 'mongo'
require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_BOT_TOKEN']
end

slack_client = Slack::Web::Client.new
mongo_client = Mongo::Client.new(ENV['MONGO_URI'], { server_api: { version: '1' } })
collection = client['measurements']

def handler(event:, context:)
  request_data = JSON.parse(event[:body])
  case request_data['type']
  when 'url_verification'
    { statusCode: 200, body: request_data['challenge'].to_json }
  when 'event_callback'
    data = collection.find.last
    client.chat_postMessage(channel: request_data['event']['channel'], text: "Dati: #{data.to_json}", as_user: true)
    { statusCode: 200, body: 'Event processed'.to_json }
  else
    { statusCode: 400, body: 'Bad request'.to_json }
  end
end

