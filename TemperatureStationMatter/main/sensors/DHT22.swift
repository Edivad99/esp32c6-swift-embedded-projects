class DHT22 {

  let sensorType: dht_sensor_type_t = DHT_TYPE_AM2301
  let pin: gpio_num_t

  init(pin: Int32 = 8) {
    self.pin = gpio_num_t(rawValue: pin)
    // Enable internal pull-up resistor if specified in Kconfig
    /*if (CONFIG_EXAMPLE_INTERNAL_PULLUP) {
      gpio_pullup_en(pin);
    } else {
      gpio_pullup_dis(pin);
    }*/
  }

  func measure() -> (humidity: Float, temperature: Float) {
    var humidity: Float = 0
    var temperature: Float = 0

    // Read the sensor data
    let result = dht_read_float_data(sensorType, pin, &humidity, &temperature)

    if result == ESP_OK {
      return (humidity, temperature)
    } else {
      print("Failed to read from DHT sensor")
      return (0, 0)
    }
  }
}