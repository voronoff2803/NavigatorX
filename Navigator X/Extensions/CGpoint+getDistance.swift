//
//  CGpoint+getDistance.swift
//  Navigator X
//
//  Created by Alexey on 13.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit

extension CGPoint {
    func getDistance(to: CGPoint) -> Double {
        return sqrt(pow(Double(to.x - self.x), 2) + pow(Double(to.y - self.y), 2))
    }
}

