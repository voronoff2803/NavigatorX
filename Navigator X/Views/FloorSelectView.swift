//
//  FloorSelectView.swift
//  Navigator X
//
//  Created by Alexey on 17.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit


class FloorSelectView: UIView {
    var floor: Int = 1
    var delegate: FloorSelectViewDelegate?
    
    var maxFloor = 8
    var minFloor = 1
    
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var upImageView: UIImageView!
    @IBOutlet weak var downImageView: UIImageView!
    
    @IBAction func upAction() {
        if floor < maxFloor {
            floor += 1
            upAnimation()
        }
    }
    
    @IBAction func downAction() {
        if floor > minFloor {
            floor -= 1
            downAnimation()
        }
    }
    
    func selectFloor(floor: Int) {
        self.floor = floor
        upAnimation()
    }
    
    func setFloor(floor: Int) {
        print(floor)
        self.floor = floor
        updateLabel()
    }
    
    func updateLabel() {
        delegate?.floorDidChange(floor: self.floor)
        floorLabel.text = String(self.floor)
        
        if floor == maxFloor {
            upImageView.alpha = 0.3
        } else {
            upImageView.alpha = 1.0
        }
        
        if floor == minFloor {
            downImageView.alpha = 0.3
        } else {
            downImageView.alpha = 1.0
        }
    }
    
    func upAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.floorLabel.transform = CGAffineTransform(translationX: 0, y: 20)
            self.floorLabel.alpha = 0.0
        }) {_ in
            self.updateLabel()
            self.floorLabel.transform = CGAffineTransform(translationX: 0, y: -20)
            UIView.animate(withDuration: 0.1, animations: {
                self.floorLabel.transform = .identity
                self.floorLabel.alpha = 1.0
            })
        }
    }
    
    func downAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.floorLabel.transform = CGAffineTransform(translationX: 0, y: -20)
            self.floorLabel.alpha = 0.0
        }) {_ in
            self.updateLabel()
            self.floorLabel.transform = CGAffineTransform(translationX: 0, y: 20)
            UIView.animate(withDuration: 0.1, animations: {
                self.floorLabel.transform = .identity
                self.floorLabel.alpha = 1.0
            })
        }
    }
}


protocol FloorSelectViewDelegate {
    func floorDidChange(floor: Int)
}
