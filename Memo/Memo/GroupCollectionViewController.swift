//
//  GruopCollectionViewController.swift
//  Memo
//
//  Created by yk on 3/20/25.
//

import UIKit
import CoreData

class GroupCollectionViewController: UICollectionViewController {

    var updates = [() -> ()]()
    
    func setupCollectionViewLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
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
        DataManger.shared.groupFetchedResults.delegate = self
        
        NotificationCenter.default.addObserver(forName: .ungroupedInfoDidUpdate, object: nil, queue: .main) { [weak self] _ in
            // 마지막셀이니까 섹션이 가지고 있는개수 가져오면 됨
            if let index = DataManger.shared.groupFetchedResults.sections?.first?.numberOfObjects {
                let indexPath = IndexPath(item: index, section: 0)
                self?.collectionView.reloadItems(at: [indexPath])
            }
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UICollectionViewCell, let indexPath = collectionView.indexPath(for: cell) {
            // 원래 그룹선택했는지 확인
            if let sections = DataManger.shared.groupFetchedResults.sections, sections[indexPath.section].numberOfObjects > indexPath.item {
                
                if let vc = segue.destination as? ListViewController {
                    vc.group = DataManger.shared.groupFetchedResults.object(at: indexPath)
                }
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DataManger.shared.groupFetchedResults.sections?.count ?? 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = DataManger.shared.groupFetchedResults.sections else { return 0 }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GroupCollectionViewCell.self), for: indexPath) as! GroupCollectionViewCell
        
        if let sections = DataManger.shared.groupFetchedResults.sections, sections[indexPath.section].numberOfObjects == indexPath.item {
            cell.nameLabel.text = "그룹 없음"
            cell.contentView.backgroundColor = .tertiarySystemFill
            cell.lastUpdateDateLabel.text = DataManger.shared.ungroupedLastUpdate?.relativeDateString
            cell.memoCountLabel.text = "\(DataManger.shared.ungroupedMemoCount)"
        } else {
            let target = DataManger.shared.groupFetchedResults.object(at: indexPath)
            cell.nameLabel.text = target.title
            cell.contentView.backgroundColor = .yellow
            cell.lastUpdateDateLabel.text = target.lastUpdated?.relativeDateString
            cell.memoCountLabel.text = "\(target.memoCount)"
            
        }
        
        
        
        return cell
    }
}

extension GroupCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        updates.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath {
                updates.append( { [weak self] in
                    self?.collectionView.insertItems(at: [insertIndexPath])
                })
            }
        case .delete:
            if let deleteIndexPath = indexPath {
                updates.append({ [weak self] in
                    self?.collectionView.deleteItems(at: [deleteIndexPath])
                })
            } 
        case .move:
            if let origianlIndexPath = indexPath, let targetIndexPath = newIndexPath {
                updates.append({ [weak self] in
                    self?.collectionView.moveItem(at: origianlIndexPath, to: targetIndexPath)
                })
            }
        case .update:
            if let updateIndexPath = indexPath {
                updates.append({ [weak self] in
                    self?.collectionView.reloadItems(at: [updateIndexPath])
                })
            }
        default:
            break
        }
    }
    
    // 컬렉션뷰 뱃치업데이트 이렇게 구현
    // 테이블뷰처럼 비긴업데이트,엔드업데이트x
    // 작업할 내용 배열에 넣고 그거를 한번에 호출
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        collectionView.performBatchUpdates { [weak self] in
            self?.updates.forEach{ $0() }
        } completion: { [weak self] _ in // 실행이 끝나면 배열 초기화
            self?.updates.removeAll()
        }
    }
}
