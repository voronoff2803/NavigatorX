//
//  InformationViewController.swift
//  Navigator X
//
//  Created by Alexey on 17.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit
import TagListView

class InformationViewController: UIViewController {
    
    var mapPoint: MapPointModel!
    var delegate: InformationViewControllerDelegate?
    
    var bookURL: URL?
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var floorTagLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tagListView: TagListView!
    
    @IBAction func bookAction() {
        if let url = bookURL { UIApplication.shared.open(url) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagListView.textFont = UIFont.boldSystemFont(ofSize: 14)
        // Do any additional setup after loading the view.
    }

    func setup(mapPoint: MapPointModel) {
        self.mapPoint = mapPoint
        
        mainLabel.text = mapPoint.text
        
        floorTagLabel.text = "\(mapPoint.floor) Этаж"
        nameLabel.text = (mapPoint.info.toJson()?["rt_name"] as? String ?? "").capitalizingFirstLetter()
        additionalInfoLabel.text = (mapPoint.info.toJson()?["dep_names"] as? String ?? "Нет информации").capitalizingFirstLetter()
        descriptionLabel.text = mapPoint.info.toJson()?["real_usage"] as? String ?? "Нет информации"
        
        if let urlStr = mapPoint.info.toJson()?["reserv_url"] as? String {
            bookButton.isHidden = false
            print(urlStr)
            bookURL = URL(string: urlStr)
        } else {
            bookButton.isHidden = true
        }
        
        setupIcon(point: mapPoint)
        
        tagListView.removeAllTags()
        
        if let equipment = mapPoint.info.toJson()?["equipment"] as? [Dictionary<String, Any>] {
            for eq in equipment {
                if let name = eq["eq_name"] as? String {
                    tagListView.addTag(name)
                }
            }
        }
    }
    
    func setupIcon(point: MapPointModel) {
        switch point.type {
        case .entrance, .mainEntrance:
            mainImageView.image = UIImage(named: "enteranceIcon")
        case .message:
            mainImageView.image = UIImage(named: "messageIcon")
        case .toiletMale, .toiletFemale, .toilet:
            mainImageView.image = UIImage(named: "toiletIcon")
        default:
            mainImageView.image = UIImage(named: "placeIcon")
        }
    }
    
    @IBAction func didSelectFromPoint() {
        delegate?.didSelectFromPoint(point: self.mapPoint)
    }
    
    @IBAction func didSelectToPoint() {
        delegate?.didSelectToPoint(point: self.mapPoint)
    }
}


protocol InformationViewControllerDelegate {
    func didSelectFromPoint(point: MapPointModel)
    func didSelectToPoint(point: MapPointModel)
}
