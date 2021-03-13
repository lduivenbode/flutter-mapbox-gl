import CoreLocation
import Mapbox

class CalmLocationManager: NSObject, MGLLocationManager, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager

  override init() {
    locationManager = CLLocationManager()
    locationManager.distanceFilter = 50
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
}
