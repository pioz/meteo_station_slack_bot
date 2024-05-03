const { MongoClient, ServerApiVersion } = require('mongodb')

const client = new MongoClient(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverApi: ServerApiVersion.v1
})

const collection = client.db().collection('measurements')

const infoBody = (temperature, humidity, ppm, createdAt) => (
  [
    `🌡️ Temperature: ${temperature.toFixed(2)}C`,
    `🚰 Humidity: ${humidity.toFixed(2)}%`,
    `🦠 PPM: ${ppm.toFixed(2)}ppm`,
    `🕓 registered at ${createdAt.getHours()}:${createdAt.getMinutes()}`
  ].join('\n')
)

module.exports = async (req, res) => {
  const params = req.body || req.query

  switch (params.command) {
    case '/meteo':
      try {
        await client.connect()
        const lastMeasure = await collection.findOne({}, { sort: { _id: -1 } })

        if (lastMeasure) {
          const responseMessage = infoBody(
            lastMeasure.temperature,
            lastMeasure.humidity,
            lastMeasure.ppm,
            lastMeasure._created_at
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
