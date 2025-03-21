//
//  ViewController.swift
//  Memo
//
//  Created by yk on 3/4/25.
//

import UIKit
import CoreData

class ListViewController: UIViewController {
    
    @IBOutlet weak var memoTableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = memoTableView.indexPath(for: cell) {
            if let vc = segue.destination as? DetailViewController {
                vc.memo = DataManger.shared.memoFetchedResults.object(at: indexPath)
            }
        }
        
    }
    
    func sestupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "메모 내용으로 검색해 보세요"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }

    @objc func resetCache() {
        NSFetchedResultsController<MemoEntity>.deleteCache(withName: nil)
        DataManger.shared.fetch()
        memoTableView.refreshControl?.endRefreshing()
        
    }
    
    func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(resetCache), for: .valueChanged)
        memoTableView.refreshControl = refreshControl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManger.shared.memoFetchedResults.delegate = self
        setupPullToRefresh()
        
    }
 
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sestupSearchBar()
    }
}

extension ListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        memoTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath {
                memoTableView.insertRows(at: [insertIndexPath], with: .automatic)
            }
        case .delete:
            if let deleteIndexPath = indexPath {
                memoTableView.deleteRows(at: [deleteIndexPath], with: .automatic)
            }
        case .move:
            if let originalIndexPath = indexPath, let targetIndexPath = newIndexPath {
                memoTableView.moveRow(at: originalIndexPath, to: targetIndexPath)
            }
        case .update:
            if let updateIndexPath = indexPath {
                memoTableView.reloadRows(at: [updateIndexPath], with: .automatic)
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        memoTableView.endUpdates()
        
    }
}

extension ListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        defer {
            memoTableView.reloadData()
        }
        
        guard let keyword = searchController.searchBar.text, keyword.count > 0 else {
            DataManger.shared.fetch()
            return
        }
        DataManger.shared.fetch(keyword: keyword)
    }
}


extension ListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DataManger.shared.memoFetchedResults.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = DataManger.shared.memoFetchedResults.sections else { return 0 }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let target = DataManger.shared.memoFetchedResults.object(at: indexPath)
        cell.textLabel?.text = target.content
        cell.detailTextLabel?.text = target.dateString
        
        return cell
    }
    
    // 테이블뷰에서 스와이프 to Delete가 활성화 됨, 버튼탭하면 호출됨
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataManger.shared.delete(at: indexPath)
        }
    }
    
    
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
