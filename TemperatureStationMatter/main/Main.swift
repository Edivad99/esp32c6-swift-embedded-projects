@_cdecl("app_main")
func main() {
  // (1) Create a Matter root node
  let rootNode = Matter.Node()
  rootNode.identifyHandler = {
    print("identify")
  }

  let temperatureSensor = DHT22()
  let pressureSensor = BMP180()

  let temperatureEndpoint = Matter.TemperatureSensor(node: rootNode)
  temperatureEndpoint.getTemperature = { temperatureSensor.measure().temperature }

  let humidityEndpoint = Matter.HumiditySensor(node: rootNode)
  humidityEndpoint.getHumidity = { temperatureSensor.measure().humidity }

  let pressureEndpoint = Matter.PressureSensor(node: rootNode)
  pressureEndpoint.getPressure = {
    let value = pressureSensor.measure().pressure
    print("Pressure: \(value) hPa")
    return value
  }

  // (3) Add the endpoint to the node
  rootNode.addEndpoint(temperatureEndpoint)
  rootNode.addEndpoint(humidityEndpoint)
  //rootNode.addEndpoint(pressureEndpoint)

  // (4) Provide the node to a Matter application and start it
  let app = Matter.Application()
  app.rootNode = rootNode
  app.start()

  // Keep local variables alive. Workaround for issue #10
  // https://github.com/apple/swift-matter-examples/issues/10
  while true {
    app.publishSensorData()
    sleep(3)
  }
}

func format(_ double: Double) -> String {
  let int = Int(double)
  let frac = Int((double - Double(int)) * 100)
  return "\(int).\(frac)"
}