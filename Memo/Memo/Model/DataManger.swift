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
        
    }
    var list = [MemoEntity]()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Memo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
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
        } catch {
            print(error)
        }
#endif
    }
    
    
    func fetch() {
        let request = MemoEntity.fetchRequest()
        
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        
        do {
            list = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }
    
    func insert(memo: String) {
        let newMemo = MemoEntity(context: mainContext)
        
        newMemo.content = memo
        newMemo.insertDate = .now
        
        saveContext()
        // fetch()
        list.insert(newMemo, at: 0)
    }
    
    func update(entity: MemoEntity, with content: String) {
        entity.content = content
        saveContext()
    }
    
    
    @discardableResult // 리턴값 사용하지 않아도 경고표시안되게
    func delete(entity: MemoEntity) -> Int? {
        mainContext.delete(entity)
        saveContext()
        
        if let index = list.firstIndex(of: entity) {
            list.remove(at: index)
            return index
        }
        return nil
    }
    
    func delete(at index: Int) {
        let target = list[index]
        delete(entity: target)
    }
}
