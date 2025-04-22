@_cdecl("app_main")
func main() {

  let sensor = PressureSensor()
  while true {
    let (temperature, pressure) = sensor.measure()
    print("Temperature: \(format(double: Double(temperature)))°C Pressure: \(pressure)Pa")
    print("Altitude: \(format(double: sensor.readAltitude()))m")
    vTaskDelay(1000 / (1000 / UInt32(configTICK_RATE_HZ)))
  }
}

func format(double: Double) -> String {
    let int = Int(double)
    let frac = Int((double - Double(int)) * 100)
    return "\(int).\(frac)"
}