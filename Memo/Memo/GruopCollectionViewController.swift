//
//  GruopCollectionViewController.swift
//  Memo
//
//  Created by yk on 3/20/25.
//

import UIKit

class GruopCollectionViewController: UICollectionViewController {

    func setupCollectionViewLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .flexible(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionViewLayout()
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GruopCollectionViewCell.self), for: indexPath) as! GruopCollectionViewCell

        cell.nameLabel.text = "Group"
        cell.contentView.backgroundColor = .yellow
        
        return cell
    }

}
