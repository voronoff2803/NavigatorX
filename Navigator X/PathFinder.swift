//
//  PathFinder.swift
//  Navigator X
//
//  Created by Alexey on 13.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit
import GameplayKit

class PathNode: GKGraphNode3D {
    let mapPoint: MapPointModel
    
    init(mapPoint: MapPointModel) {
        self.mapPoint = mapPoint
        super.init(point: vector_float3(x: Float(mapPoint.position.x), y: Float(mapPoint.position.y), z: 0.0))
        
        if mapPoint.type == .entrance { self.position.z = 1000 }
        if mapPoint.type == .stairsUp { self.position.z = 700 }
        if mapPoint.type == .stairsDown { self.position.z = 700 }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PathFinder {
    static func findPath(from: MapPointModel, to: MapPointModel, points: [MapPointModel]) -> [MapPointModel] {
        var dict: Dictionary<String, PathNode> = [:]
        
        let pathGarph = GKGraph()
        let nodes = points.map({PathNode(mapPoint: $0)})
        
        nodes.forEach({dict[$0.mapPoint.id] = $0})
        
        var ix = 0
        
        for i in nodes {
            for id in i.mapPoint.connectedIDs {
                if let connectedNode = dict[id] {
                    ix += 1
                    i.addConnections(to: [connectedNode], bidirectional: true)
                }
            }
        }
        
        print(ix)
        
        pathGarph.add(nodes)
        
        let path = pathGarph.findPath(from: nodes.first(where: {$0.mapPoint == from})!, to: nodes.first(where: {$0.mapPoint == to})!)
        
        let resultPath = path.map({($0 as! PathNode).mapPoint})
        
        return resultPath
    }
}
