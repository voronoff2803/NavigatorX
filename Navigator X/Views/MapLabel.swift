//
//  MapLabel.swift
//  Navigator X
//
//  Created by Alexey on 21.09.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit

class MapLabel: UIView, MapCoordinatable {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var arrowShape: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageParentView: UIView!
    
    var mapCoordinate: CGPoint
    var scaleVisible: Double
    var mapPoint: MapPointModel
    var isSelectable: Bool {
        get {
            return mapPoint.isSelectable()
        }
    }
    
    var isHidable: Bool {
        get {
            if selected == true { return false }
            if self.layer.zPosition == 10 { return false }
            switch mapPoint.type {
            case .mainEntrance, .toiletMale, .toiletFemale:
                return false
            default:
                return true
            }
        }
    }
    
    func setText(text: String) {
        if text == "" { self.layer.zPosition = 0.0; textLabel.isHidden = true; return }
        textLabel.isHidden = false
        textLabel.text = text
        print(self.layer.zPosition)
        self.layer.zPosition = 10
    }
    
    func setIconIfNeed() {
        switch mapPoint.type {
        case .stairsDown:
            imageParentView.isHidden = false
            textLabel.isHidden = true
            imageView.image = UIImage(named: "downArrow")
        case .stairsUp:
            imageParentView.isHidden = false
            textLabel.isHidden = true
            imageView.image = UIImage(named: "upArrow")
        case .toiletMale:
            imageParentView.isHidden = false
            textLabel.isHidden = false
            imageView.image = UIImage(named: "maleIcon")
        case .toiletFemale:
            imageParentView.isHidden = false
            textLabel.isHidden = false
            imageView.image = UIImage(named: "femaleIcon")
        case .toilet:
            imageParentView.isHidden = false
            textLabel.isHidden = false
            imageView.image = UIImage(named: "toilet")
        case .message:
            //imageParentView.isHidden = false
            textLabel.isHidden = false
            //imageView.image = UIImage(named: "messageSmallIcon")
        default:
            imageParentView.isHidden = true
            textLabel.isHidden = false
        }
    }

    init(frame: CGRect, mapPoint: MapPointModel) {
        self.mapCoordinate = mapPoint.position
        self.scaleVisible = mapPoint.scaleVisible
        self.mapPoint = mapPoint

        super.init(frame: frame)
        self.xibInit()
        
        setIconIfNeed()
    }
    
    required init?(coder: NSCoder, mapPoint: MapPointModel) {
        self.mapCoordinate = mapPoint.position
        self.scaleVisible = mapPoint.scaleVisible
        self.mapPoint = mapPoint
        
        super.init(coder: coder)
        self.xibInit()
        
        setIconIfNeed()
    }
    
    required init?(coder: NSCoder) {
        self.mapCoordinate = .zero
        self.scaleVisible = 0.0
        self.mapPoint = MapPointModel()
        super.init(coder: coder)
    }
    
    func  xibInit() {
        let viewXib = Bundle(for: type(of: self)).loadNibNamed((self.mapPoint.type == .message ? "MapLabelMessage" : "MapLabel"), owner: self, options: nil)?.first as! UIView
        viewXib.frame = self.bounds
        addSubview(viewXib)
        self.isUserInteractionEnabled = false
        self.textLabel.text = mapPoint.labelText
    }
    
    override func didMoveToSuperview() {
//        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        UIView.animate(withDuration: 0.15, animations: {
//            self.transform = .identity
//        })
        
        self.alpha = 0.0
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 1.0
                })
        super.didMoveToSuperview()
    }
    
    var selected: Bool = false
    
    func setSelected(_ selected: Bool) {
        self.selected = selected
        
        if self.selected {
            self.imageView.tintColor = UIColor.whiteColor()
            self.bgView.backgroundColor = UIColor.blueColor()
            self.arrowShape.tintColor = UIColor.blueColor()
            self.textLabel.textColor = UIColor.whiteColor()
            
            self.layer.zPosition = 10
            UIView.animate(withDuration: 0.15) {
                self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15).translatedBy(x: 0.0, y: -3.0)
            }
        } else {
            self.imageView.tintColor = UIColor.blueColor()
            self.bgView.backgroundColor = UIColor.whiteColor()
            self.arrowShape.tintColor = UIColor.whiteColor()
            self.textLabel.textColor = UIColor.blackTextColor()
            
            self.layer.zPosition = 0.0
            UIView.animate(withDuration: 0.15) {
                self.transform = .identity
            }
        }
    }
}
