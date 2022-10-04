//
//  SelectBuildingView.swift
//  Navigator X
//
//  Created by Alexey on 12.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit

class SelectBuildingView: UIView {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var cardView: UIView!
    
    var delegate: SelectBuildingViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibInit()
    }
    
    
    func removeAnimated() {
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundView.alpha = 0.0
            self.cardView.transform = CGAffineTransform(translationX: 0, y: self.cardView.frame.height + 40)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //self.xibInit()
    }
    
    func xibInit() {
        let viewXib = Bundle(for: type(of: self)).loadNibNamed("SelectBuildingView", owner: self, options: nil)?.first as! UIView
        viewXib.frame = self.bounds
        addSubview(viewXib)
        self.isUserInteractionEnabled = false
        
        backgroundView.alpha = 0.0
        self.cardView.transform = CGAffineTransform(translationX: 0, y: self.cardView.frame.height + 40)
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 0.3
            self.cardView.transform = .identity
        }
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        
        cardView.addGestureRecognizer(panGesture)
    }
    
    @objc func panAction(_ gestureRecognizer : UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == .ended {
            if self.cardView.transform.ty < 100 {
                UIView.animate(withDuration: 0.3) {
                    self.cardView.transform = .identity
                }
                print(self.delegate)
            } else {
                hide()
            }
        } else {
            let translation = gestureRecognizer.translation(in: self)
            
            cardView.transform = CGAffineTransform(translationX: 0, y: cardView.transform.ty + translation.y)

            // 3
            gestureRecognizer.setTranslation(.zero, in: self)
        }
    }
    
    @objc func hide() {
        delegate?.hideAction()
    }
    
    @IBAction func selectBuilding(button: UIButton){
        delegate?.buildingDidSelected(building: button.tag)
        delegate?.hideAction()
        print(self.delegate)
    }

}

protocol SelectBuildingViewDelegate {
    func buildingDidSelected(building: Int)
    func hideAction()
}
