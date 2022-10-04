//
//  mapScrollView.swift
//  Navigator X
//
//  Created by Alexey on 20.09.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit

class MapScrollView: UIScrollView {
    var canvasView: UIView!
    var imageZoomView: UIImageView!
    var scrollDelegate: MapScrollViewDelegate?
    
    let pathView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10000, height: 10000)))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func setup() {
        self.delegate = self
        self.decelerationRate = .fast
        self.minimumZoomScale = 0.08
        self.maximumZoomScale = 0.9
        
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        
        canvasView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10000, height: 10000)))
        canvasView.addSubview(pathView)
        self.contentSize = canvasView.frame.size
        self.addSubview(canvasView)
        
//        let poinView = PositionPinView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 200)))
//        poinView.layer.zPosition = 10.0
//        poinView.center = canvasView.center
//
//        poinView.sizeToFit()

//        canvasView.addSubview(poinView)
    }
    
    func drawPath(points: [MapPointModel], delay: Double = 0.0) {
        
        if points.count < 2 { return }
        
        let line = CAShapeLayer()
        let aPath = UIBezierPath()
        
        aPath.move(to: points.first!.position)
        for point in points.dropFirst() {
            aPath.addLine(to: point.position)
        }
        
        line.strokeColor = UIColor.blueColor().withAlphaComponent(0.8).cgColor
        line.lineWidth = 17
        line.fillColor = UIColor.clear.cgColor
        line.lineJoin = CAShapeLayerLineJoin.round
        line.lineCap = .round
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.autoreverses = false
        
        
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName(rawValue: "easeInEaseOut"))
        
        line.path = aPath.cgPath
        line.add(animation, forKey: "path")
        
        self.pathView.layer.addSublayer(line)
    }
    
    func zoomToPath(points: [MapPointModel]) {
        if points.count > 1 {
            let rect = findRect(points: points)
                   
            self.zoom(to: rect, animated: true)
        }
    }
    
    func clearPath() {
        self.pathView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    
    func zoomToPoint(point: MapPointModel) {
        let rect = findRect(points: [point])
        
        self.zoom(to: rect, animated: true)
    }
    
    func findRect(points: [MapPointModel]) -> CGRect {
        var maxX: CGFloat = 0.0
        var maxY: CGFloat = 0.0
        var minX: CGFloat = 10000.0
        var minY: CGFloat = 10000.0
        
        for point in points.map({$0.position}) {
            if point.x > maxX {
                maxX = point.x
            }
            if point.y > maxY {
                maxY = point.y
            }
            if point.x < minX {
                minX = point.x
            }
            if point.y < minY {
                minY = point.y
            }
        }
        
        return CGRect(x: minX - (maxX - minX) * 0.15, y: minY - (maxY - minY) * 0.37, width: (maxX - minX) * 1.3, height: (maxY - minY) * 1.8)
    }
    
    func clearConnections() {
        self.pathView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    
    func drawConnections(points: [MapPointModel]) {
        self.pathView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        for point in points {
            point.connectedIDs.forEach({id in
                if let connectedPoint = points.first(where: {$0.id == id}) {
                    drawPath(from: point, to: connectedPoint)
                }
            })
        }
    }
    
    // its for debug_main_vc
    private func drawPath(from: MapPointModel, to: MapPointModel) {
        let line = CAShapeLayer()
        let aPath = UIBezierPath()
        
        aPath.move(to: from.position)
        aPath.addLine(to: to.position)
        aPath.close()
        
        line.path = aPath.cgPath
        line.strokeColor = UIColor.blueColor().withAlphaComponent(0.3).cgColor
        line.lineWidth = 10
        line.lineJoin = CAShapeLayerLineJoin.round
        
        self.pathView.layer.addSublayer(line)
    }
    
    
    

    
    func set(imagePath: String, isUp: Bool) {
        if imageZoomView != nil {
            
            //let offset: CGFloat = isUp ? 30 : -30
            
            
            //UIView.animate(withDuration: 0.3) {
                //self.imageZoomView.transform = CGAffineTransform(translationX: 0, y: offset)
            //}
            //UIView.animate(withDuration: 0.1, delay: 0.2) {
                //self.imageZoomView.alpha = 0.2
            //}
            
            DispatchQueue.global().async {
                let image = UIImage(contentsOfFile: imagePath)
                DispatchQueue.main.async {
                    self.imageZoomView.image = image
                    //self.imageZoomView.transform = CGAffineTransform(translationX: 0, y: -offset)
                    //UIView.animate(withDuration: 0.2) {
                        //self.imageZoomView.alpha = 1.0
                        //self.imageZoomView.transform = .identity
                    //}
                }
            }
            return
        }
        
        imageZoomView?.removeFromSuperview()
        imageZoomView = nil
        
        DispatchQueue.global().async {
            let image = UIImage(contentsOfFile: imagePath)
            DispatchQueue.main.async {
                self.imageZoomView = UIImageView(image: image)
                
                self.imageZoomView.frame.size = CGSize(width: 5000, height: 5000)
                self.imageZoomView.center = self.canvasView.center
                self.canvasView.addSubview(self.imageZoomView)
                
                self.canvasView.bringSubviewToFront(self.pathView)
                
                self.zoomScale = 0.25
            }
        }
    }
    
    func scrollToCenter(animated: Bool = false) {
        let centerOffsetX = (self.contentSize.width - self.frame.size.width) / 2
        let centerOffsetY = (self.contentSize.height - self.frame.size.height) / 2
        let centerPoint = CGPoint(x: centerOffsetX, y: centerOffsetY)
        self.setContentOffset(centerPoint, animated: animated)
    }
}

extension MapScrollView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.didScroll()
    }
}


protocol MapScrollViewDelegate {
    func didScroll()
}
