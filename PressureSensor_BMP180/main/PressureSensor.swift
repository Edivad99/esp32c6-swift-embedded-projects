
class PressureSensor {

  private let ctx: bmp180_t

  init() {
    var config = i2c_lowlevel_config(
      bus: nil,
      port: I2C_NUM_0,
      pin_sda: 5,
      pin_scl: 6
    )
    ctx = bmp180_init(&config, 0, BMP180_MODE_HIGH_RESOLUTION)
  }

  deinit {
    bmp180_free(ctx)
  }

  func measure() -> (temperature: Float, pressure: UInt32) {
    var temperature: Float = 0
    var pressure: UInt32 = 0

    bmp180_measure(ctx, &temperature, &pressure)

    return (temperature, pressure)
  }

  func readAltitude(sealevelPressure: UInt32 = 101325) -> Double {
    let (_, pressure) = measure()
    let altitude = 44330 * (1.0 - pow(Double(pressure) / Double(sealevelPressure), 0.1903));
    return altitude
  }
}
