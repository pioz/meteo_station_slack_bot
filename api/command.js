const { MongoClient } = require('mongodb')

const client = new MongoClient(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverApi: MongoClient.ServerApiVersion.v1
})

const collection = client.db().collection('measurements')

const infoBody = (temperature, humidity, ppm, createdAt) => (
  [
    `🌡️ Temperature: ${temperature.toFixed(2)}C`,
    `🚰 Humidity: ${humidity.toFixed(2)}%`,
    `🦠 PPM: ${ppm.toFixed(2)}ppm`,
    `registered at ${createdAt.getHours()}:${createdAt.getMinutes()}`
  ].join('\n')
)

module.exports = async (req, res) => {
  const command = req.query.command

  switch (command) {
    case '/meteo':
      try {
        await client.connect()
        const data = await collection.find().sort({ _id: -1 }).limit(1).toArray()

        if (data.length > 0) {
          const latestData = data[0]
          const responseMessage = infoBody(
            latestData.temperature,
            latestData.humidity,
            latestData.ppm,
            latestData._created_at
          )
          res.status(200).send(responseMessage)
        } else {
          res.status(404).send('No data found')
        }
      } catch (error) {
        res.status(500).send('Internal Server Error')
        console.error(error)
      }
      break
    default:
      res.status(400).send('Bad request')
  }
}
