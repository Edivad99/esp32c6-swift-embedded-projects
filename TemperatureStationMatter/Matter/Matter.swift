enum Matter {}

extension Matter {

  class Node {
    var identifyHandler: (() -> Void)?

    var endpoints: [Endpoint] = []

    func addEndpoint(_ endpoint: Endpoint) {
      endpoints.append(endpoint)
    }

    // swift-format-ignore: NeverUseImplicitlyUnwrappedOptionals
    // This is never actually nil after init(), and inside init we want to form a callback closure that references self.
    var innerNode: RootNode!

    init() {
      // Initialize persistent storage.
      nvs_flash_init()

      // For now, leak the object, to be able to use local variables to declare it. We don't expect this object to be created and destroyed repeatedly.
      _ = Unmanaged.passRetained(self)

      // Create the actual root node object, wire up callbacks.
      let root = RootNode(
        attribute: self.eventHandler,
        identify: { _, _, _, _ in self.identifyHandler?() })
      guard let root else {
        fatalError("Failed to setup root node.")
      }
      self.innerNode = root
    }

    func eventHandler(
      type: MatterAttributeEvent, endpoint: __idf_main.Endpoint,
      cluster: Cluster, attribute: UInt32,
      value: UnsafeMutablePointer<esp_matter_attr_val_t>?
    ) {
      guard type == .didSet else { return }
    }
  }
}

extension Matter {

  class Endpoint {

    var id: Int = 0

    init(node: Node) {
      // For now, leak the object, to be able to use local variables to declare
      // it. We don't expect this object to be created and destroyed repeatedly.
      _ = Unmanaged.passRetained(self)
    }

    func publish() {
      // No-op
    }
  }
}

extension Matter {

  class TemperatureSensor: Endpoint {

    var getTemperature: (() -> Float)? = nil

    override init(node: Node) {
      super.init(node: node)

      var temperature_sensor_config = esp_matter.endpoint.temperature_sensor.config_t()
      temperature_sensor_config.temperature_measurement.measured_value = .init(20 * 100)
      temperature_sensor_config.temperature_measurement.min_measured_value = .init(-40 * 100)
      temperature_sensor_config.temperature_measurement.max_measured_value = .init(80 * 100)

      let sensor = MatterTemperatureSensor(node.innerNode,
        configuration: temperature_sensor_config)
      self.id = Int(sensor.id)
    }

    override func publish() {
      guard let getTemperature = self.getTemperature else { return }

      var temperature_value = esp_matter_attr_val_t(
        type: ESP_MATTER_VAL_TYPE_INT32,
        val: .init(i32: Int32(getTemperature() * 100)))

      let endpointId = UInt16(self.id)
      let clusterId = TemperatureMeasurement.clusterTypeId.rawValue
      let attributeId = TemperatureMeasurement.AttributeID<TemperatureMeasurement.CurrentTemperature>.measuredValue.rawValue
      esp_matter.attribute.update_shim(endpointId, clusterId, attributeId, &temperature_value);
    }
  }

  class HumiditySensor: Endpoint {

    var getHumidity: (() -> Float)? = nil

    override init(node: Node) {
      super.init(node: node)

      var humidity_sensor_config = esp_matter.endpoint.humidity_sensor.config_t()
      humidity_sensor_config.relative_humidity_measurement.measured_value = .init(50 * 100)
      humidity_sensor_config.relative_humidity_measurement.min_measured_value = .init(0 * 100)
      humidity_sensor_config.relative_humidity_measurement.max_measured_value = .init(100 * 100)

      let sensor = MatterHumiditySensor(node.innerNode,
        configuration: humidity_sensor_config)
      self.id = Int(sensor.id)
    }

    override func publish() {
      guard let getHumidity = self.getHumidity else { return }

      var humidity_value = esp_matter_attr_val_t(
        type: ESP_MATTER_VAL_TYPE_INT32,
        val: .init(i32: Int32(getHumidity() * 100)))

      let endpointId = UInt16(self.id)
      let clusterId = HumidityMeasurement.clusterTypeId.rawValue
      let attributeId = HumidityMeasurement.AttributeID<HumidityMeasurement.CurrentHumidity>.measuredValue.rawValue
      esp_matter.attribute.update_shim(endpointId, clusterId, attributeId, &humidity_value);
    }
  }

  class PressureSensor: Endpoint {

    var getPressure: (() -> UInt32)? = nil

    override init(node: Node) {
      super.init(node: node)

      var pressure_sensor_config = esp_matter.endpoint.pressure_sensor.config_t()
      pressure_sensor_config.pressure_measurement.pressure_measured_value = .init(0)

      let sensor = MatterPressureSensor(node.innerNode,
        configuration: pressure_sensor_config)
      self.id = Int(sensor.id)
    }

    override func publish() {
      guard let getPressure = self.getPressure else { return }

      var pressure_value = esp_matter_attr_val_t(
        type: ESP_MATTER_VAL_TYPE_INT32,
        val: .init(i: Int32(getPressure() * 100)))

      let endpointId = UInt16(self.id)
      let clusterId = PressureMeasurement.clusterTypeId.rawValue
      let attributeId = PressureMeasurement.AttributeID<PressureMeasurement.CurrentPressure>.measuredValue.rawValue
      esp_matter.attribute.update_shim(endpointId, clusterId, attributeId, &pressure_value);
    }
  }
}

extension Matter {

  class Application {
    var rootNode: Node? = nil

    init() {
      // For now, leak the object, to be able to use local variables to declare
      // it. We don't expect this object to be created and destroyed repeatedly.
      _ = Unmanaged.passRetained(self)
    }

    func start() {
      func callback(
        event: UnsafePointer<chip.DeviceLayer.ChipDeviceEvent>?,
        context: Int) {
        // Ignore callback if event not set.
        guard let event else { return }
        switch Int(event.pointee.Type) {
          case chip.DeviceLayer.DeviceEventType.kFabricRemoved: recomissionFabric()
          default: break
        }
      }

      esp_matter.start(callback, 0)
    }

    func publishSensorData() {
      guard let rootNode = self.rootNode else { return }

      for endpoint in rootNode.endpoints {
        endpoint.publish()
        sleep(1)
      }
    }
  }
}
