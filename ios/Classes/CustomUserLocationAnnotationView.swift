import Mapbox

class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
  let minDotSize: CGFloat = 24
  let minDotMeters: CGFloat = 8
  let maxDotSize: CGFloat
  var dotSize: CGFloat

  let arrowMeters: CGFloat = 6
  let minArrowSize: CGFloat = 12
  let smallHitTestLayer: CALayer
  var arrowRotation: CGFloat?
  var arrowScale: CGFloat

  let dotLayer: CALayer
  let arrowLayer: CAShapeLayer

  let lineWidth: CGFloat = 2

  init() {
    let size: CGFloat = 200
    dotSize = 0.0
    maxDotSize = size - lineWidth
    arrowScale = 1.0
    smallHitTestLayer = CALayer()
    let hitTestOffset = size / 2 - minDotSize / 2
    smallHitTestLayer.frame = CGRect(x: hitTestOffset, y: hitTestOffset, width: minDotSize, height: minDotSize)
    dotLayer = CALayer()
    arrowLayer = CAShapeLayer()

    super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: size, height: size)))
    isOpaque = false

    dotLayer.borderColor = UIColor.white.cgColor
    layer.addSublayer(dotLayer)

    arrowLayer.path = getArrowPath()
    arrowLayer.fillColor = dotLayer.borderColor
    layer.addSublayer(arrowLayer)
  }

  override var hitTestLayer: CALayer? {
    return smallHitTestLayer
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("storyboard not supported")
  }

  override func update() {
    if let accuracy = userLocation?.location?.horizontalAccuracy, let mpp = metersPerPoint(), let mv = mapView {
      let accuracySize = CGFloat(accuracy) / mpp * 2.0
      let dotMetersSize = minDotMeters / mpp
      let newDotSize = min(maxDotSize, max(dotMetersSize, max(minDotSize, accuracySize)))

      if newDotSize != dotSize {
        layoutDotLayer(newDotSize: newDotSize)
      }

      if let heading = userLocation?.heading?.trueHeading {
        let newArrowRotation = -MGLRadiansFromDegrees(mv.direction - heading)
        let newArrowScale = max(1.0, (arrowMeters / mpp) / minArrowSize)

        if newArrowScale != arrowScale || newArrowRotation != arrowRotation {
          layoutArrowLayer(newArrowScale: newArrowScale, newArrowRotation: newArrowRotation)
        }
      }
    }
  }

  private func layoutDotLayer(newDotSize: CGFloat) {
    CATransaction.begin()
    CATransaction.setDisableActions(abs(newDotSize - dotSize) < 4)

    dotSize = newDotSize
    let dotOffset = frame.size.width / 2.0 - dotSize / 2.0
    dotLayer.backgroundColor = tintColor.cgColor
    dotLayer.frame = CGRect(x: dotOffset, y: dotOffset, width: dotSize, height: dotSize)
    dotLayer.cornerRadius = dotSize / 2
    dotLayer.borderWidth = dotSize / 14
    dotLayer.opacity = Float(min(1.0, 0.1 + (maxDotSize - dotSize) / maxDotSize))

    CATransaction.commit()
  }

  private func layoutArrowLayer(newArrowScale: CGFloat, newArrowRotation: CGFloat) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    arrowScale = newArrowScale
    arrowRotation = newArrowRotation

    arrowLayer.setAffineTransform(CGAffineTransform(scaleX: arrowScale, y: arrowScale).concatenating(CGAffineTransform.identity.translatedBy(x: bounds.width / 2, y: bounds.height / 2).rotated(by: newArrowRotation)))

    CATransaction.commit()
  }

  private func getArrowPath() -> CGPath {
    let max: CGFloat = minArrowSize / 2.0
    let pad: CGFloat = 0.8

    let top = CGPoint(x: 0.0, y: -max * 1.1)
    let left = CGPoint(x: -max * pad, y: max)
    let right = CGPoint(x: max * pad, y: max)
    let center = CGPoint(x: 0.0, y: max * 0.4)

    let radius: CGFloat = max * 0.1

    let path = CGMutablePath()
    path.move(to: center)
    path.addArc(tangent1End: left, tangent2End: top, radius: radius)
    path.addArc(tangent1End: top, tangent2End: right, radius: radius)
    path.addArc(tangent1End: right, tangent2End: center, radius: radius)
    path.closeSubpath()

    return path
  }

  private func metersPerPoint() -> CGFloat? {
    if let coord = userLocation?.location?.coordinate, let mv = mapView {
      return CGFloat(mv.metersPerPoint(atLatitude: coord.latitude))
    } else {
      return nil
    }
  }
}
