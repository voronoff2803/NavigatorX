//
//  UIView+decoration.swift
//  ITMO
//
//  Created by Alexey Voronov on 01/08/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    
    func applyShadow(
        apply: Bool,
        color: UIColor = UIColor.black,
        offset: CGSize = CGSize(width: 0.0, height: 2.0),
        opacity: Float = 0.25, radius: Float = 16.0,
        shadowRect: CGRect? = nil) {
        self.layer.shadowColor = apply ? color.cgColor : UIColor.white.withAlphaComponent(0.0).cgColor
        self.layer.shadowOffset = apply ? offset : CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = apply ? opacity : 0.0
        self.layer.shadowRadius = apply ? CGFloat(radius) : 0.0
        self.layer.masksToBounds = false
        if let shadowRect = shadowRect {
            self.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
        }
    }
    
    func rounded(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    var nibName: String {
        return type(of: self).description().components(separatedBy: ".").last! // to remove the module name and get only files name
    }
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    // MARK: IBInspectable
    
    @IBInspectable var borderColor: UIColor {
        get {
            let color = self.layer.borderColor ?? UIColor.white.cgColor
            return UIColor(cgColor: color) // not using this property as such
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    @IBInspectable var cornerRadiusSize: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.rounded(cornerRadius: newValue)
        }
    }
}
