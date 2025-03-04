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
}
