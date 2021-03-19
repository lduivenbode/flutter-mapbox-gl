import CoreLocation
import Mapbox

class CalmLocationManager: NSObject, MGLLocationManager, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager
  private var heading: Int = 0

  override init() {
    locationManager = CLLocationManager()
    locationManager.distanceFilter = 4
    super.init()
    locationManager.delegate = self
  }

  var delegate: MGLLocationManagerDelegate?

  var authorizationStatus: CLAuthorizationStatus {
    if #available(iOS 14.0, *) {
      return locationManager.authorizationStatus
    } else {
      return CLAuthorizationStatus.notDetermined
    }
  }

  func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    delegate?.locationManager(self, didUpdate: locations)
  }

  func locationManager(_: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    if Int(newHeading.trueHeading) != heading {
      heading = Int(newHeading.trueHeading)
      delegate?.locationManager(self, didUpdate: newHeading)
    }
  }

  func locationManager(_: CLLocationManager, didFailWithError error: Error) {
    delegate?.locationManager(self, didFailWithError: error)
  }

  func locationManagerShouldDisplayHeadingCalibration(_: CLLocationManager) -> Bool {
    delegate?.locationManagerShouldDisplayHeadingCalibration(self)
    return false
  }

  func requestAlwaysAuthorization() {
    locationManager.requestAlwaysAuthorization()
  }

  func requestWhenInUseAuthorization() {
    locationManager.requestWhenInUseAuthorization()
  }

  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }

  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
  }

  var headingOrientation: CLDeviceOrientation {
    get {
      return locationManager.headingOrientation
    }
    set {
      locationManager.headingOrientation = newValue
    }
  }

  func startUpdatingHeading() {
    locationManager.startUpdatingHeading()
  }

  func stopUpdatingHeading() {
    locationManager.stopUpdatingHeading()
  }

  func dismissHeadingCalibrationDisplay() {
    locationManager.dismissHeadingCalibrationDisplay()
  }

  deinit {
    locationManager.stopUpdatingLocation()
    locationManager.stopUpdatingHeading()
  }
}
