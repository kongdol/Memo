//
//  MemoEntity+CoreDataClass.swift
//  Memo
//
//  Created by yk on 3/4/25.
//
//

import Foundation
import CoreData



fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.doesRelativeDateFormatting = true // 가까운날 - 어제, 오늘 표시
    return formatter
}()

@objc(MemoEntity)
public class MemoEntity: NSManagedObject {
    var dateString: String? {
        return formatter.string(for: insertDate)
    }
}
