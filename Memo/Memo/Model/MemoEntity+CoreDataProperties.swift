//
//  MemoEntity+CoreDataProperties.swift
//  Memo
//
//  Created by yk on 3/4/25.
//
//

import Foundation
import CoreData


extension MemoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoEntity> {
        return NSFetchRequest<MemoEntity>(entityName: "Memo")
    }

    @NSManaged public var content: String?
    @NSManaged public var insertDate: Date?

}

extension MemoEntity : Identifiable {

}
