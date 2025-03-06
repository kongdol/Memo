//
//  ViewController.swift
//  Memo
//
//  Created by yk on 3/4/25.
//

import UIKit

class ListViewController: UIViewController {
    
    var reloadTargetIndexPath: IndexPath?

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
        
        NotificationCenter.default.addObserver(forName: .memoDidUpdate, object: nil, queue: .main) { [weak self] noti in
            guard let self else { return }
            
            if let memo = noti.userInfo?["memo"] as? MemoEntity,
               let index = DataManger.shared.list.firstIndex(of: memo) {
                let indexPath = IndexPath(row: index, section: 0)
//                self.memoTableView.reloadRows(at: [indexPath], with: .automatic)
                self.reloadTargetIndexPath = indexPath
            }
        }
    }
    // 화면이 호출되기 전에 호출
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        if let reloadTargetIndexPath {
            memoTableView.reloadRows(at: [reloadTargetIndexPath], with: .automatic)
            self.reloadTargetIndexPath = nil
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
