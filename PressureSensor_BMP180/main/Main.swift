@_cdecl("app_main")
func main() {

  let pressureSensor = BMP180()
  let dht11Sensor = DHT22()
  while true {
    let (temperature, pressure) = pressureSensor.measure()
    print("Temperature: \(format(double: Double(temperature)))°C Pressure: \(pressure)Pa")
    print("Altitude: \(format(double: pressureSensor.readAltitude()))m")

    let (humidity, temperature2) = dht11Sensor.measure()
    print("Temperature: \(format(double: Double(temperature2)))°C Humidity: \(format(double: Double(humidity)))%")
    print(String(repeating: "-", count: 40))
    vTaskDelay(1000 / (1000 / UInt32(configTICK_RATE_HZ)))
  }
}

func format(double: Double) -> String {
    let int = Int(double)
    let frac = Int((double - Double(int)) * 100)
    return "\(int).\(frac)"
}