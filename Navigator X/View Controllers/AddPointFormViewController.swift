//
//  AddPointFormViewController.swift
//  Navigator X
//
//  Created by Alexey on 14.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit
import Eureka

class AddPointFormViewController: FormViewController {
    let building: Int
    let floor: Int
    let position: CGPoint
    let types = ["path","room","message","icon","other","stairsUp","stairsDown","elevator","mainEntrance","entrance","toiletMale","toiletFemale","toilet"]
    
    init(point: CGPoint, building: Int, floor: Int) {
        self.building = building
        self.floor = floor
        self.position = point
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        form +++ Section()
        <<< PickerRow<String>(){ row in
            row.title = "type"
            row.options = types
            row.value = types[0]
        }
        <<< TextRow(){
            $0.title = "labelText"
        }
        <<< TextRow(){
            $0.title = "text"
            $0.onCellSelection { (cell, row) in
                cell.textField.text = self.form.allRows[1].baseValue as? String ?? ""
            }
        }
        <<< TextRow(){
            $0.title = "info"
        }
        <<< SegmentedRow<Int>(){
            $0.title = "building"
            $0.options = [0,1,2,3,4,5,6]
            $0.value = building
        }
        <<< SegmentedRow<Int>{
            $0.title = "floor"
            $0.options = [0,1,2,3,4,5,6]
            $0.value = floor
        }
        <<< ButtonRow(){
            $0.title = "Push!"
        }.onCellSelection({ (_, _) in
            let rows = self.form.allRows
            
            let point = MapPointModel()
            
            point.type = MapPointModel.PointType(rawValue: self.types.firstIndex(of: rows[0].baseValue as! String)!)!
            point.labelText = rows[1].baseValue as? String ?? ""
            point.text = rows[2].baseValue as? String ?? ""
            point.info = rows[3].baseValue as? String ?? ""
            point.building = rows[4].baseValue as! Int
            point.floor = rows[5].baseValue as! Int
            point.position = self.position
            
            print(point)
            
            MapPointsService.shared.addToDatabase(point: point)
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
}
