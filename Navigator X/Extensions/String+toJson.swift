//
//  String+toJson.swift
//  Navigator X
//
//  Created by Alexey on 29.11.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import Foundation

extension String {
    func toJson() -> Dictionary<String, Any>? {
        let data = self.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>
            {
               return jsonArray
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            //
        }
        return nil
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
