//
//  ComposeViewController.swift
//  Memo
//
//  Created by yk on 3/5/25.
//

import UIKit

class ComposeViewController: UIViewController {

    
    // 있으면 편집, nil이면 추가
    var editTarget: MemoEntity?
    var group: GroupEntity?
    var originalContent = ""
    
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
            
        } else {
            DataManger.shared.insert(memo: text, to: group)
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
            originalContent = editTarget.content ?? ""
        } else {
            navigationItem.title = "새 메모"
            contentTextView.text = ""
        }
        
        contentTextView.delegate = self
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

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        if let _ = editTarget {
            // 원래내용과 새로운내용 다르면 true (안내려가게)
            isModalInPresentation = originalContent != textView.text
        } else {
            //뷰컨트롤러에 동작을 결정하는 속성(기본값false)
            isModalInPresentation = !textView.text.isEmpty
        }
        
        
    }
}
