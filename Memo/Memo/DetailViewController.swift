//
//  DetailViewController.swift
//  Memo
//
//  Created by yk on 3/5/25.
//

import UIKit

extension Notification.Name {
    static let memoDidDelete = Notification.Name("memoDidDelete")
}

class DetailViewController: UIViewController {

    @IBOutlet weak var contentTextView: UITextView!
    
    var memo: MemoEntity?
    
    @IBAction func deleteMemo(_ sender: Any) {
        let alert = UIAlertController(title: "삭제확인", message: "메모를 삭제할까요?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            guard let memo = self.memo else { return }
            if let index = DataManger.shared.delete(entity: memo) {
                NotificationCenter.default.post(name: .memoDidDelete, object: nil, userInfo: ["index": index])
            }
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        
        let cancleAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancleAction)
        
        present(alert, animated: true)
    }
    
    
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
        NotificationCenter.default.addObserver(forName: .memoDidUpdate, object: nil, queue: .main) { [weak self]_ in
            guard let self else { return }
            self.contentTextView.text = self.memo?.content
        }
    }
    
    deinit {
        print(self,#function)
    }

}
