//
//  ComposeViewController.swift
//  Memo
//
//  Created by yk on 3/5/25.
//

import UIKit

extension Notification.Name {
    static let memoDidInsert = Notification.Name("memoDidInsert")
    static let memoDidUpdate = Notification.Name("memoDidUpdate")
}

class ComposeViewController: UIViewController {

    var editTarget: MemoEntity?
    
    @IBOutlet weak var contentTextView: UITextView!
    
    
    @IBAction func closeVC(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let text = contentTextView.text, text.count > 0 else {
            // TODO: 경고창 추가
            return
        }
        
        if let editTarget {
            DataManger.shared.update(entity: editTarget, with: text)
            // 몇번째 셀을 수정하는지 알아야되서 userInfo넣어줌
            NotificationCenter.default.post(name: .memoDidUpdate, object: nil, userInfo: ["memo": editTarget])
        } else {
            DataManger.shared.insert(memo: text)
            NotificationCenter.default.post(name: .memoDidInsert, object: nil)
        }
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 바로 입력할수있게 키보드 표시
        contentTextView.becomeFirstResponder()
        
        if let editTarget {
            navigationItem.title = "편집"
            contentTextView.text = editTarget.content
        } else {
            navigationItem.title = "새 메모"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 키보드 숨기기
        if contentTextView.isFirstResponder {
            contentTextView.resignFirstResponder()
        }
    }

    deinit {
        print(self,#function)
    }
    
}
