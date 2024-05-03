require 'mongo'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

mongo_client = Mongo::Client.new(ENV['MONGO_URI'], { server_api: { version: '1' } })

def info_body(temperature, humidity, ppm, created_at)
  s = []
  s << "🌡️ Temperature: #{temperature.round(2)}C"
  s << "🚰 Humidity: #{humidity.round(2)}%"
  s << "🦠 PPM: #{ppm.round(2)}ppm"
  s << "registered at #{created_at.strftime("%H:%M")}"
  return s.join("\n")
end

Handler = Proc.new do |request, response|
  command = request.query['command']
  case command
  when '/meteo'
    collection = mongo_client['measurements']
    data = collection.find.sort({ _id: -1 }).first
    response.status = 200
    response.body = info_body(data['temperature'], data['humidity'], data['ppm'], data['_created_at'])
  else
    response.status = 400
    response.body = 'Bad request'
  end
end

# require 'webrick'
# require 'json'
# server = WEBrick::HTTPServer.new(:Port => 3031, :DocumentRoot => '/')
# server.mount_proc '/', Handler
# server.start
