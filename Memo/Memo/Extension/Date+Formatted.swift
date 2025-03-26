//
//  Date+Formatted.swift
//  Memo
//
//  Created by yk on 3/26/25.
//

import Foundation

fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    
    return formatter
}()

extension Date {
    var relativeDateString: String? {
        let comps = Calendar.current.dateComponents([.second], from: self, to: .now)
        
        guard let second = comps.second else {
            return formatter.string(from: self)
        }
        
        if second < 60 {
            return "조금 전"
        } else if second < 3600 {
            let min = Int(second / 60)
            return "\(min)분 전"
        } else if second < 3600 * 24 {
            let hour = Int(second / 3600)
            return "\(hour)시간 전"
        } else {
            return formatter.string(from: self)
        }
    }
}
