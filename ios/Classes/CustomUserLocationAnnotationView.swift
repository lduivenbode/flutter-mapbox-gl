import Mapbox

class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
  let minDotSize: CGFloat = 24
  let minDotMeters: CGFloat = 8
  let maxDotSize: CGFloat
  var dotSize: CGFloat

  let arrowMeters: CGFloat = 4
  let minArrowSize: CGFloat = 12
  let maxArrowSize: CGFloat = 28
  let smallHitTestLayer: CALayer
  var arrowRotation: CGFloat?
  var arrowSize: CGFloat

  let lineWidth: CGFloat = 2

  init() {
    let size: CGFloat = 200
    dotSize = minDotSize
    maxDotSize = size - lineWidth
    arrowSize = minArrowSize
    smallHitTestLayer = CALayer()
    let hitTestOffset = size / 2 - minDotSize / 2
    smallHitTestLayer.frame = CGRect(x: hitTestOffset, y: hitTestOffset, width: minDotSize, height: minDotSize)
    super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: size, height: size)))
    backgroundColor = UIColor.clear
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
        dotSize = newDotSize
        setNeedsDisplay()
      }

      let newArrowSize = min(maxArrowSize, max(minArrowSize, arrowMeters / mpp))
      if newArrowSize != arrowSize {
        arrowSize = newArrowSize
        setNeedsDisplay()
      }

      if let heading = userLocation!.heading?.trueHeading {
        let newArrowRotation = -MGLRadiansFromDegrees(mv.direction - heading)

        if newArrowRotation != arrowRotation {
          arrowRotation = newArrowRotation
          setNeedsDisplay()
        }
      }
    }
  }

  private func metersPerPoint() -> CGFloat? {
    if let coord = userLocation?.location?.coordinate, let mv = mapView {
      return CGFloat(mv.metersPerPoint(atLatitude: coord.latitude))
    } else {
      return nil
    }
  }

  override func draw(_: CGRect) {
    if let context = UIGraphicsGetCurrentContext() {
      drawDot(context)
      drawArrow(context)
    }
  }

  private func drawDot(_ context: CGContext) {
    let dotOffset = frame.size.width / 2.0 - dotSize / 2.0
    let circleRect = CGRect(x: dotOffset, y: dotOffset, width: dotSize, height: dotSize)
    context.setAlpha(min(1.0, 0.2 + (maxDotSize - dotSize) / maxDotSize))
    context.setFillColor(super.tintColor.cgColor)
    context.setStrokeColor(UIColor.white.cgColor)
    context.setLineWidth(lineWidth)
    context.fillEllipse(in: circleRect)
    context.strokeEllipse(in: circleRect)
    context.setAlpha(1.0)
  }

  // Calculate the vector path for an arrow, for use in a shape layer.
  private func drawArrow(_ context: CGContext) {
    if let rotation = arrowRotation {
      let max: CGFloat = arrowSize / 2.0
      let offset: CGFloat = frame.size.width / 2.0
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

      let bezierPath = UIBezierPath(cgPath: path)
      bezierPath.apply(CGAffineTransform(rotationAngle: rotation).concatenating(CGAffineTransform(translationX: offset, y: offset)))
      context.setFillColor(UIColor.white.cgColor)
      bezierPath.fill()
    }
  }
}
