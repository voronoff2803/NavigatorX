//
//  MapCoordinatable.swift
//  Navigator X
//
//  Created by Alexey on 28.09.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit

protocol MapCoordinatable  where Self: UIView {
    var mapCoordinate: CGPoint { get }
    var scaleVisible: Double { get }
    var isHidable: Bool { get }
}
