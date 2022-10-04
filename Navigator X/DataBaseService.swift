//
//  DataBaseService.swift
//  Navigator X
//
//  Created by Alexey on 01.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import Foundation
import RealmSwift

class MapPointsService {
    static let shared = MapPointsService()
    private init() { self.start() }
    
    var realm: Realm?
    
    func start() {
        let app = App(id: "navigator-unscj")
        
        
        app.login(credentials: Credentials.anonymous()) { (user, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Login failed: \(error!)")
                    return
                }

                let partitionValue = "nav"
                do { self.realm = try Realm(configuration: user!.configuration(partitionValue: partitionValue)) }
                catch {print(error.localizedDescription)}
            
            }
        }
    }
    
    func getMapPoints() -> [MapPointModel] {
        
        
//        try! realm?.write {
//            let point = MapPointModel()
//            
//            point.building = 0
//            point.floor = 0
//            point.labelText = "2135"
//            point.text = "Ауд. 2135"
//            point.info = "Кафедра высшей математики"
//            point.type = .room
//            point.scaleVisible = 0.5
//            point.position = CGPoint(x: 5131, y: 4785)
//            
//            let list = List<String>()
//            
//            list.append("id1")
//            list.append("id2")
//            
//            point.connectedIDs = list
//            
//            realm?.add(point)
//        }
        
        return realm?.objects(MapPointModel.self).toArray(type: MapPointModel.self) ?? []
    }
}
