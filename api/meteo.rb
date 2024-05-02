require 'json'
require 'mongo'
require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_BOT_TOKEN']
end

slack_client = Slack::Web::Client.new
mongo_client = Mongo::Client.new(ENV['MONGO_URI'], { server_api: { version: '1' } })
collection = mongo_client['measurements']

def handler(event:, context:)
end


Handler = Proc.new do |request, response|
  request_body = JSON.parse(request.body.read)
  case request_body['type']
  when 'url_verification'
    response.status = 200
    response.body = request_body['challenge']
  when 'event_callback'
    data = collection.find.last
    slack_client.chat_postMessage(channel: request_body['event']['channel'], text: "Data: #{data.to_json}", as_user: true)
    response.status = 200
    response.body = 'Event processed'
  else
    response.status = 400
    response.body = 'Bad request'
  end
end
