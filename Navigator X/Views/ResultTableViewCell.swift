//
//  ResultTableViewCell.swift
//  Navigator X
//
//  Created by Alexey on 06.10.2020.
//  Copyright © 2020 a2803. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainLabelView: UILabel!
    @IBOutlet weak var descriptionLabelView: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var floorLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(point: MapPointModel) {
        
        mainLabelView.text = point.text
        descriptionLabelView.text = point.info.toJson()?["real_usage"] as? String ?? ""
        if descriptionLabelView.text?.count ?? 0 > 1 { descriptionLabelView.text! += "  "}
        
        floorLabel.text = "\(point.floor) ЭТАЖ"
        
        setupIcon(point: point)
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

}
