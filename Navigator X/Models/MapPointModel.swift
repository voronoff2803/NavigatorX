//
//  MapPointModel.swift
//  Navigator X
//
//  Created by Alexey on 27.09.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit
import RealmSwift

class MapPointModel: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()

    // When configuring Sync, we selected `_partition` as the partition key.
    // A partition key is only required if you are using Sync.
    @objc dynamic var _partition: String = "nav"
    
    @objc enum PointType: Int, RealmEnum {
        case path = 0
        case room = 1
        case message = 2
        case icon = 3
        case other = 4
        case stairsUp = 5
        case stairsDown = 6
        case elevator = 7
        case mainEntrance = 8
        case entrance = 9
        case toiletMale = 10
        case toiletFemale = 11
        case toilet = 12
    }
    
    func isSearchable() -> Bool {
        switch type {
        case .room, .other, .entrance, .mainEntrance, .toiletMale, .toiletFemale, .toilet:
            return true
        default:
            return false
        }
    }
    
    func isSelectable() -> Bool {
        switch type {
        case .room, .other, .entrance, .mainEntrance, .toiletMale, .toiletFemale, .toilet:
            return true
        default:
            return false
        }
    }
    
    var connectedIDs = List<String>()
    
    @objc dynamic var type: PointType = .other
    @objc dynamic var scaleVisible: Double = 0.0
    @objc dynamic var labelText: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var info: String = ""
    @objc dynamic var building: Int = 0
    @objc dynamic var floor: Int = 0
    @objc dynamic var korpus: Int = 0
    @objc dynamic private var positionX: Double = 0.0
    @objc dynamic private var positionY: Double = 0.0
    
    var id: String {
        get {
            return self._id.stringValue
        }
    }
    
    var position: CGPoint {
        get {
            return CGPoint(x: self.positionX, y: self.positionY)
        }
        set {
            positionX = Double(newValue.x); positionY = Double(newValue.y)
        }
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    func distanceTo(point: MapPointModel) -> Double {
        return position.getDistance(to: point.position)
    }
    
//    func toJSON() -> String? {
//        let props = ["positionX": self.position.x, "positionY": self.position.y, "type": self.type.rawValue, "scaleVisible": self.scaleVisible, "connectedIDs": self.connectedIDs, "id": self.id, "text": self.text] as [String : Any]
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: props,
//                                                      options: [])
//            return String(data: jsonData, encoding: .utf8)
//        } catch let error {
//            print("error converting to json: \(error)")
//            return nil
//        }
//    }
//
//    init(json: String) {
//        do {
//            guard let data = json.data(using: .utf8) else {fatalError("error converting from json")}
//            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
//            guard let positionX = json?["positionX"] as? CGFloat else {fatalError("error converting from json")}
//            guard let positionY = json?["positionY"] as? CGFloat else {fatalError("error converting from json")}
//            guard let type = json?["type"] as? Int else {fatalError("error converting from json")}
//            let scaleVisible = json?["scaleVisible"] as? Double ?? 0.0
//            let connectedIDs = json?["connectedIDs"] as? [String] ?? []
//            guard let id = json?["id"] as? String else {fatalError("error converting from json")}
//            let text = json?["text"] as? String ?? ""
//
//            self.positionX = Double(positionX)
//            self.positionY = Double(positionY)
//            self.type = PointType(rawValue: type) ?? .other
//            self.scaleVisible = scaleVisible
//            self.connectedIDs = connectedIDs
//            self.id = id
//            self.text = text
//        } catch {
//            fatalError("error converting from json: \(error)")
//        }
//    }
//
//    override required convenience init() {
//        self.init(json: "{ \"positionX\":0,\"positionY\":0,\"type\":1,\"scaleVisible\":1,\"text\":\"2345\",\"id\":\"345\",\"connectedIDs\":[\"123\",\"234\"]}")
//    }
    
}
