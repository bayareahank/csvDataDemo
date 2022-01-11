//
//  SchoolCollectionViewCell.swift
//
//  Created by bayareahank on 1/9/22.
//

import UIKit

class SchoolCollectionViewCell: UICollectionViewCell {
    static let cellID = "schoolCVCell"
    
    @IBOutlet var schoolButton: UIButton!
    
    func configure(_ school: School) {
        schoolButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        schoolButton.contentVerticalAlignment = UIControl.ContentVerticalAlignment.top
        schoolButton.setTitle(school.name, for: .normal)
    }
}
