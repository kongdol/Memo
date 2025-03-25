//
//  DataManger.swift
//  Memo
//
//  Created by yk on 3/4/25.
//

import Foundation
import CoreData

class DataManger {
    // 타입프로퍼티로 쉽게 접근가능, 인스턴스 하나 만들어짐
    static let shared = DataManger()
    
    // 클래스밖에서 생성자를 호출 못함
    private init() {
        let container = NSPersistentContainer(name: "Memo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        persistentContainer = container
        mainContext = persistentContainer.viewContext
        
        let request = MemoEntity.fetchRequest()
        let sortByDateDesc = NSSortDescriptor(keyPath: \MemoEntity.insertDate, ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        
        memoFetchedResults = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        let groupRequest = GroupEntity.fetchRequest()
        let sortByName = NSSortDescriptor(keyPath: \GroupEntity.name, ascending: true)
        groupRequest.sortDescriptors = [sortByName]
        
        groupFetchedResults = NSFetchedResultsController(fetchRequest: groupRequest, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: "MemoGroupCache")
        
        
        do {
            try memoFetchedResults.performFetch()
            try groupFetchedResults.performFetch()
        } catch {
            print(error)
        }
    }
    
    let memoFetchedResults: NSFetchedResultsController<MemoEntity>
    let groupFetchedResults: NSFetchedResultsController<GroupEntity>
    
    let mainContext: NSManagedObjectContext
    
    
    // MARK: - Core Data stack
    
    let persistentContainer: NSPersistentContainer
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func insertDummyData() {
#if DEBUG
        // 저장되어있는게 있으면 바로리턴
        let countRequest = MemoEntity.fetchRequest()
        
        do {
            let count = try mainContext.count(for: countRequest)
            if count > 0 {
                return
            }
            
        } catch {
            print(error)
        }
        
        guard let path = Bundle.main.path(forResource: "lipsum", ofType: "txt") else {
            return
        }
        
        do {
            // 파일에 포함된 내용 문자열로 리턴
            let source = try String(contentsOfFile: path)
            
            let sentences = source.components(separatedBy: .newlines).filter {
                // 비어있지 않는 문자열만 필터링
                $0.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
            }
            // 배치insert
            var dataList = [[String: Any]]()
            
            for sentence in sentences {
//                let memo = MemoEntity(context: mainContext)
//                memo.content = sentence
//                // TimeInterval타입으로 전달해야되는데 이게 double타입과 같아서
//                memo.insertDate = Date(timeIntervalSinceNow: Double.random(in: 0 ... 3600 * 24 * 30) * -1)
                
                dataList.append([
                    "content": sentence,
                    "insertDate": Date(timeIntervalSinceNow: Double.random(in: 0 ... 3600 * 24 * 30) * -1)
                ])
            }
            
            let insertRequest = NSBatchInsertRequest(entityName: "Memo", objects: dataList)
            
            if let result = try mainContext.execute(insertRequest) as? NSBatchInsertResult, let succeeded = result.result as? Bool {
                if succeeded {
                    print("Batch Insert 성공")
                } else {
                    print("Batch Insert 실패")
                }
            }
            
            let groupList: [[String: Any]] = [
                ["name": "일상"],
                ["name": "업무"],
                ["name": "공부"],
                ["name": "쇼핑"],
                ["name": "기타"]
            ]
            
            let groupInsertRequest = NSBatchInsertRequest(entityName: "Group", objects: groupList)
            
            if let result = try mainContext.execute(groupInsertRequest) as? NSBatchInsertResult,
               let succeeded = result.result as? Bool {
                if succeeded {
                    print("Group Batch Insert 성공")
                } else {
                    print("Group Batch Insert 실패")
                }
            }
            
            try groupFetchedResults.performFetch()
            try memoFetchedResults.performFetch()
            
            
        } catch {
            print(error)
        }
#endif
    }
    
    // 코어데이터에 메모데이터를 주세요!라고 요청하는것
    func fetch(group: GroupEntity?, keyword: String? = nil) {
        memoFetchedResults.fetchRequest.predicate = nil
        
        if let group {
            if let keyword {
                let predicate = NSPredicate(format: "%K == %@ AND %K CONTAINS [c] %@", #keyPath(MemoEntity.group), group, #keyPath(MemoEntity.content), keyword) // [c] 대소문자구분x
                memoFetchedResults.fetchRequest.predicate = predicate
            } else {
                let predicate = NSPredicate(format: "%K == %@", #keyPath(MemoEntity.group), group)
                memoFetchedResults.fetchRequest.predicate = predicate
            }
        } else {
            if let keyword {
                let predicate = NSPredicate(format: "%K == NIL AND %K CONTAINS [c] %@", #keyPath(MemoEntity.group), #keyPath(MemoEntity.content), keyword) // [c] 대소문자구분x
                memoFetchedResults.fetchRequest.predicate = predicate
            } else {
                let predicate = NSPredicate(format: "%K == NIL", #keyPath(MemoEntity.group))
                memoFetchedResults.fetchRequest.predicate = predicate
            }
        }
        
        
        do {
            try memoFetchedResults.performFetch()
        } catch {
            print(error)
        }
    }
    
    func insert(memo: String) {
        let newMemo = MemoEntity(context: mainContext)
        
        newMemo.content = memo
        newMemo.insertDate = .now
        
        saveContext()
    }
    
    func update(entity: MemoEntity, with content: String) {
        // 엔티티는 클래스여서 따로 배열을 업데이트 안해도됨, 참조형식이여서
        entity.content = content
        saveContext()
    }
    
    func delete(entity: MemoEntity) {
        mainContext.delete(entity)
        saveContext()
    }
    
    func delete(at indexPath: IndexPath) {
        let target = memoFetchedResults.object(at: indexPath)
        delete(entity: target)
    }
}
