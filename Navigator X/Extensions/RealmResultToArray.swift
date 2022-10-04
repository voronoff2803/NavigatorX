//
//  RealmResultToArray.swift
//  Navigator X
//
//  Created by Alexey on 06.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import Foundation
import RealmSwift


extension Results {
    func toArray<T>(type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }
}
