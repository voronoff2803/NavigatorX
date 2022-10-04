//
//  PositionPinView.swift
//  Navigator X
//
//  Created by Alexey on 21.09.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit

class PositionPinView: UIView {
    var imageView = UIImageView()
    
    override func draw(_ rect: CGRect) {
        imageView.image = UIImage(named: "positionPin")
        imageView.contentMode = .scaleAspectFit
        imageView.frame = self.bounds
        imageView.removeFromSuperview()
        self.addSubview(imageView)
        
        print("Add pin to view")
    }
}
