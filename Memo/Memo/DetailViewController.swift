//
//  DetailViewController.swift
//  Memo
//
//  Created by yk on 3/5/25.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!
    
    var memo: MemoEntity?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination.children.first as? ComposeViewController {
            vc.editTarget = memo
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let memo {
            contentTextView.text = memo.content
        }
    }
    


}
