//
//  SATCollectionViewCell.swift
//
//  Created by bayareahank on 1/9/22.
//

import UIKit

class SATCollectionViewCell: UICollectionViewCell {
    static let cellID = "satCVCell"
    
    @IBOutlet var testLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    func configure(_ score: TestScore) {
        testLabel.text = score.test.rawValue + " :"
        scoreLabel.text = score.value
    }
}
