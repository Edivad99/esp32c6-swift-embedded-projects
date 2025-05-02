protocol MatterCluster {
  var cluster: UnsafeMutablePointer<esp_matter.cluster_t> { get }

  init(_ cluster: UnsafeMutablePointer<esp_matter.cluster_t>)
}

extension MatterCluster {
  init?(endpoint: some MatterEndpoint, id: UInt32) {
    guard let cluster = esp_matter.cluster.get_shim(endpoint.endpoint, id)
    else {
      return nil
    }
    self.init(cluster)
  }
}

protocol MatterConcreteCluster: MatterCluster {
  static var clusterTypeId: ClusterID<Self> { get }
}

struct ClusterID<Cluster: MatterCluster>: RawRepresentable {
  var rawValue: UInt32

  static var identify: ClusterID<Identify> {
    .init(rawValue: 0x0000_0003)
  }
  //NEW
  static var temperatureMeasurement: ClusterID<TemperatureMeasurement> {
    .init(rawValue: 0x0000_0402)
  }

  static var humidityMeasurement: ClusterID<HumidityMeasurement> {
    .init(rawValue: 0x0000_0405)
  }

  static var pressureMeasurement: ClusterID<PressureMeasurement> {
    .init(rawValue: 0x0000_0403)
  }
}

struct Cluster: MatterCluster {
  var cluster: UnsafeMutablePointer<esp_matter.cluster_t>

  init(_ cluster: UnsafeMutablePointer<esp_matter.cluster_t>) {
    self.cluster = cluster
  }

  func `as`<T: MatterConcreteCluster>(_ type: T.Type) -> T? {
    let expected = T.clusterTypeId
    let id = esp_matter.cluster.get_id(cluster)
    if id == expected.rawValue {
      return T(cluster)
    }
    return nil
  }
}

struct Identify: MatterConcreteCluster {
  static var clusterTypeId: ClusterID<Self> { .identify }
  struct AttributeID<Attribute: MatterAttribute>: MatterAttributeID {
    var rawValue: UInt32
  }

  var cluster: UnsafeMutablePointer<esp_matter.cluster_t>

  init(_ cluster: UnsafeMutablePointer<esp_matter.cluster_t>) {
    self.cluster = cluster
  }

  func attribute<Attribute: MatterAttribute>(_ id: AttributeID<Attribute>) -> Attribute {
    Attribute(attribute: esp_matter.attribute.get_shim(cluster, id.rawValue))
  }
}

struct TemperatureMeasurement: MatterConcreteCluster {
  static var clusterTypeId: ClusterID<Self> { .temperatureMeasurement }
  struct AttributeID<Attribute: MatterAttribute>: MatterAttributeID {
    var rawValue: UInt32

    static var measuredValue: AttributeID<CurrentTemperature> {
      .init(rawValue: 0x0000_0000)
    }
  }

  var cluster: UnsafeMutablePointer<esp_matter.cluster_t>

  init(_ cluster: UnsafeMutablePointer<esp_matter.cluster_t>) {
    self.cluster = cluster
  }

  func attribute<Attribute: MatterAttribute>(_ id: AttributeID<Attribute>) -> Attribute {
    Attribute(attribute: esp_matter.attribute.get_shim(cluster, id.rawValue))
  }

  var measuredValue: CurrentTemperature { attribute(.measuredValue) }
}

struct HumidityMeasurement: MatterConcreteCluster {
  static var clusterTypeId: ClusterID<Self> { .humidityMeasurement }
  struct AttributeID<Attribute: MatterAttribute>: MatterAttributeID {
    var rawValue: UInt32

    static var measuredValue: AttributeID<CurrentHumidity> {
      .init(rawValue: 0x0000_0000)
    }
  }

  var cluster: UnsafeMutablePointer<esp_matter.cluster_t>

  init(_ cluster: UnsafeMutablePointer<esp_matter.cluster_t>) {
    self.cluster = cluster
  }

  func attribute<Attribute: MatterAttribute>(_ id: AttributeID<Attribute>) -> Attribute {
    Attribute(attribute: esp_matter.attribute.get_shim(cluster, id.rawValue))
  }

  var measuredValue: CurrentHumidity { attribute(.measuredValue) }
}

struct PressureMeasurement: MatterConcreteCluster {
  static var clusterTypeId: ClusterID<Self> { .pressureMeasurement }
  struct AttributeID<Attribute: MatterAttribute>: MatterAttributeID {
    var rawValue: UInt32

    static var measuredValue: AttributeID<CurrentPressure> {
      .init(rawValue: 0x0000_0000)
    }
  }

  var cluster: UnsafeMutablePointer<esp_matter.cluster_t>

  init(_ cluster: UnsafeMutablePointer<esp_matter.cluster_t>) {
    self.cluster = cluster
  }

  func attribute<Attribute: MatterAttribute>(_ id: AttributeID<Attribute>) -> Attribute {
    Attribute(attribute: esp_matter.attribute.get_shim(cluster, id.rawValue))
  }

  var measuredValue: CurrentPressure { attribute(.measuredValue) }
}
