import UIKit

class Counter {
    var count = 0

    func countUp() {
        count += 1
        print("count: \(count)")
    }
}

// 사용
let counter = Counter()
counter.countUp()  // 출력: count: 1
counter.countUp()  // 출력: count: 2


func makeCounter() -> () -> Void {
    var count = 0

    return {
        count += 1
        print("count: \(count)")
    }
}

// 사용
let counter = makeCounter()
counter()  // 출력: count: 1
counter()  // 출력: count: 2
