//
//  ViewController.swift
//
//  Created by bayareahank on 1/9/22.
//

/** Bonus
 Add an acitivity indicator while the data is being loaded over the net, so user will see some action.
 */

import UIKit
import os.log

class ViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    var schoolData: [School] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = makeLayout()
        
        let modelData = ModelData.shared()
        modelData.fetchData {
            [weak self] error in
            guard error == nil else {
                // alert
                os_log("ViewController.viewDidLoad fetch data failed %@", type: .error,  error?.localizedDescription ?? "")
                
                let alert = UIAlertController(title: "Warning", message: "Unable to fetch data from source", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                
                }))
                
                self?.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let sself = self else {
                return
            }
                
            // Sort schools by their names.
            // print ("ViewDidLoad: Total schools found \(ModelData.shared().schools.count)")
            DispatchQueue.main.async {
                sself.schoolData = ModelData.shared().schools.values.sorted(by: { $0.name < $1.name
                })
                sself.collectionView.reloadData()
            }
        }
    }
    
    // Compositional layout, available since iOS 13
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        
        let heightDimension = NSCollectionLayoutDimension.estimated(100)

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 1.0), heightDimension: heightDimension)
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
         
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: heightDimension)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
            
        return layout
    }
    
    // Navigation stuff.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as! SchoolDetailViewController
        
        let button = sender as! UIButton
        let buttonPosition : CGPoint = button.convert(CGPoint.zero, to: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: buttonPosition) else {
            fatalError ("Button outside of collectionView")
        }
        
        detailVC.school = schoolData[indexPath.item]
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return schoolData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SchoolCollectionViewCell.cellID, for: indexPath) as! SchoolCollectionViewCell
        
        cell.configure(schoolData[indexPath.item])
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        
        return cell 
    }
}

// Still needed, just in case.
extension ViewController: UICollectionViewDelegate {
    
}

