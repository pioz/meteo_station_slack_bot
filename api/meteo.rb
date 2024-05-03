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

def info_body(temperature, humidity, ppm)
  s = []
  s << "Temperature: #{temperature.round(2)}C"
  s << "Humidity: #{humidity.round(2)}%"
  s << "PPM: #{ppm.round(2)}ppm"
  return s.join("\n")
end

Handler = Proc.new do |request, response|
  user_id = request.query['user_id']
  command = request.query['command']
  case command
  when '/meteo'
    # data = collection.find.sort({ _id: -1 }).first
    # slack_client.chat_postMessage(channel: user_id, text: 'Hello from Vercel', as_user: true)
    response.status = 200
    response.body = info_body(23.0, 45.0, 400.2)
  else
    response.status = 400
    response.body = 'Bad request'
  end
end
