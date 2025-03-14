//
//  ViewController.swift
//  Memo
//
//  Created by yk on 3/4/25.
//

import UIKit

class ListViewController: UIViewController {
    
    var reloadTargetIndexPath: IndexPath?
    var deleteTargetIndexPath: IndexPath?

    @IBOutlet weak var memoTableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = memoTableView.indexPath(for: cell) {
            if let vc = segue.destination as? DetailViewController {
                vc.memo = DataManger.shared.list[indexPath.row]
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManger.shared.fetch()
        
        NotificationCenter.default.addObserver(forName: .memoDidInsert, object: nil, queue: .main) { [weak self]_ in
            guard let self else { return }
            //self.memoTableView.reloadData()
           
            let indexPath = IndexPath(row: 0, section: 0)
            self.memoTableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        // MARK: 메모업데이트 노티피케이션
        NotificationCenter.default.addObserver(forName: .memoDidUpdate, object: nil, queue: .main) { [weak self] noti in
            guard let self else { return }
            
            if let memo = noti.userInfo?["memo"] as? MemoEntity,
               let index = DataManger.shared.list.firstIndex(of: memo) {
                let indexPath = IndexPath(row: index, section: 0)
//                self.memoTableView.reloadRows(at: [indexPath], with: .automatic)
                self.reloadTargetIndexPath = indexPath
            }
        }
        
        NotificationCenter.default.addObserver(forName: .memoDidDelete, object: nil, queue: .main) { [weak self] noti in
            guard let self else {return}
            
            if let index = noti.userInfo?["index"] as? Int {
                let indexPath = IndexPath(row: index, section: 0)
                self.deleteTargetIndexPath = indexPath
            }
        }
        
    }
    // 루트뷰가 계층에 추가되고 나서 화면이 표시되기 전에 호출
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if let reloadTargetIndexPath {
            // 인덱스 저장되어있으면 해당 인덱스페스 릴로드
            memoTableView.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
            self.reloadTargetIndexPath = nil
        }
        
        if let deleteTargetIndexPath {
            memoTableView.deleteRows(at: [deleteTargetIndexPath], with: .automatic)
            self.deleteTargetIndexPath = nil
        }
    }
}




extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManger.shared.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let target = DataManger.shared.list[indexPath.row]
        cell.textLabel?.text = target.content
        cell.detailTextLabel?.text = target.dateString
        
        return cell
    }
    
    // 테이블뷰에서 스와이프 to Delete가 활성화 됨, 버튼탭하면 호출됨
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataManger.shared.delete(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
