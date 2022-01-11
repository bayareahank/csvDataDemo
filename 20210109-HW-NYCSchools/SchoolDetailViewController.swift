//
//  SchoolDetailViewController.swift
//
//  Created by bayareahank on 1/9/22.
//

/** Bonus:
 1. It would be good to add a right swipe gesture handler, so right swipe brings you up the navigation stack, back to the list view of shools, rather than using the back navigation button.
 2. Add website and map (from school's location), and show them upon touch.
 */

import UIKit

class SchoolDetailViewController: UIViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var scoreCollectionView: UICollectionView!
    
    var school: School!
    var scores = [TestScore]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scoreCollectionView.dataSource = self
        scoreCollectionView.delegate = self
        scoreCollectionView.collectionViewLayout = makeLayout()
        
        nameLabel.text = school.name
        descriptionLabel.text = school.description
        
        // Sort by test name. 
        scores = Array(school.scores.values).sorted { $0.test.rawValue < $1.test.rawValue }
    }
    
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 1.0), heightDimension: .fractionalHeight(1.0 / 1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
        // In total 3 kinds of SAT scores.
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0/CGFloat(3)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
            
        return layout
    }

}

extension SchoolDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scores.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SATCollectionViewCell.cellID, for: indexPath) as! SATCollectionViewCell
        
        cell.configure(scores[indexPath.item])
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        
        return cell
    }
}

extension SchoolDetailViewController: UICollectionViewDelegate {
    
}
