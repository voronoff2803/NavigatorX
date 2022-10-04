//
//  UIViewController+hideKeyboard.swift
//  Navigator X
//
//  Created by Alexey on 06.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.view.endEditing(true)
        }
    }
}
