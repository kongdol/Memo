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
    
    @IBAction func deleteMemo(_ sender: Any) {
        // 경고창 띄우고 삭제
        let alert = UIAlertController(title: "삭제확인", message: "메모를 삭제할까요?", preferredStyle: .alert)
        
        // .destructive 타이틀이 빨간색으로 표시
        let okAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            guard let memo = self.memo else { return }
            
            DataManger.shared.delete(entity: memo)
                
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
        
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: .main) { [weak self]_ in
            self?.contentTextView.text = self?.memo?.content
        }
    }
    
    deinit {
        print(self,#function)
    }

}
