require 'json'
require 'mongo'
require 'slack-ruby-client'

Slack.configure do |config|
  config.token = ENV['SLACK_BOT_TOKEN']
end

slack_client = Slack::Web::Client.new
mongo_client = Mongo::Client.new(ENV['MONGO_URI'], { server_api: { version: '1' } })
collection = mongo_client['measurements']
logger = Logger.new(STDOUT)

Handler = Proc.new do |request, response|
  channel_id = request.query['channel_id']
  command = request.query['command']
  case command
  when 'meteo'
    data = collection.find.last
    slack_client.chat_postMessage(channel: channel_id, text: "Data: #{data.to_json}", as_user: true)
    response.status = 200
    response.body = 'Event processed'
  else
    response.status = 400
    response.body = 'Bad request'
  end
end
