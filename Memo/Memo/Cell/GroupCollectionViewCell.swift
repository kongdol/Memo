//
//  GruopCollectionViewCell.swift
//  Memo
//
//  Created by yk on 3/20/25.
//

import UIKit

class GroupCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
 
    @IBOutlet weak var lastUpdateDateLabel: UILabel!
    
    @IBOutlet weak var memoCountLabel: UILabel!
    
    override func awakeFromNib() {
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
    }
    
}
