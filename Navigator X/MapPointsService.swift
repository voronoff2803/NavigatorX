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
    
    var points: Results<MapPointModel>?
    var notificationToken: NotificationToken?
    
    var changeCallBack: (() -> ())?
    
    func start() {
        let app = App(id: "navigator-unscj")
        
        
        app.login(credentials: Credentials.anonymous()) { (user, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Login failed: \(error!)")
                    return
                }

                let partitionValue = "nav"
                do {
                    self.realm = try Realm(configuration: user!.configuration(partitionValue: partitionValue))
                    
                    //self.addDataToRealm()
                    
                    self.points = self.realm?.objects(MapPointModel.self)
                    
                    self.notificationToken = self.points?.observe { (changes) in
                        (self.changeCallBack ?? {})()
                    }
                }
                catch {print(error.localizedDescription)}
            }
        }
    }
    
    deinit {
        self.notificationToken?.invalidate()
    }
    
    func getMapPoints(_ onlyVisible: Bool = false, building: Int) -> [MapPointModel] {
        print("GetPoints")
        if onlyVisible {
            return points?.toArray(type: MapPointModel.self).filter({$0.type != .path && $0.building == building}) ?? []
        } else {
            return points?.toArray(type: MapPointModel.self).filter({$0.building == building}) ?? []
        }
    }
    
    func addToDatabase(point: MapPointModel) {
        try! realm?.write {
            realm?.add(point)
        }
    }
    
    func removeFromDatabase(point: MapPointModel) {
        try! realm?.write {
            for id in point.connectedIDs {
                if let connectedPoint = getMapPoint(id: id) {
                    if let index = connectedPoint.connectedIDs.firstIndex(of: point.id) {
                        connectedPoint.connectedIDs.remove(at: index)
                    }
                }
            }
            
            realm?.delete(point)
        }
    }

    
    func getMapPoint(id: String) -> MapPointModel? {
        print("GetPoint")
        let key = try! ObjectId(string: id)
        return realm?.object(ofType: MapPointModel.self, forPrimaryKey: key)
    }
    
    func findPath(from: MapPointModel, to: MapPointModel, building: Int) -> [MapPointModel] {
        return PathFinder.findPath(from: from, to: to, points: getMapPoints(building: building))
    }
    
    func addConnection(from: MapPointModel, to: MapPointModel) {
        if from.connectedIDs.contains(to.id) { return }
        
        try! realm?.write {
            from.connectedIDs.append(to.id)
            to.connectedIDs.append(from.id)
        }
    }
    
    func addDataToRealm() {
        if let path = Bundle.main.path(forResource: "kronva2", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? [Dictionary<String, AnyObject>] {
                    var pointss: [MapPointModel] = []
                    
                    for i in jsonResult {
                        let point = MapPointModel()
                        point.type = MapPointModel.PointType(rawValue: (i["type"] as! Int))!
                        point.labelText = i["labelText"] as! String
                        point.text = i["text"] as! String
                        point.info = i["info"] as! String
                        point.building = i["building"] as! Int
                        point.floor = i["floor"] as! Int
                        point.scaleVisible = i["scaleVisible"] as! Double
                        point._id = try! ObjectId(string: (i["_id"] as! Dictionary<String, String>)["$oid"]!)
                        (i["connectedIDs"] as? Array<String> ?? []).forEach({point.connectedIDs.append($0)})
                        point.position = CGPoint(x: i["positionX"] as! CGFloat, y: i["positionY"] as! CGFloat)
                        
                        print(point)
                        
                        pointss.append(point)
                    }
                    
                    try! realm?.write {
                        realm?.add(pointss)
                    }
                  }
              } catch {
                   // handle error
              }
        }
    }
}
