import UIKit

// Keypath

// a.b.c

// Keypath string expr
struct Person {
    let name: String = "Jane Doe"
    var age: Int  = 0
}

// Key-value coding
let p = Person()
//p.value(forKey: "name")
//var keyPath = #keyPath(Person.name)
//
//p.value(forKey: keyPath)
//p.value(forKeyPath: keyPath)
// 리턴타입이 옵셔널이여서 타입캐스팅하는과정에서 크래시발생가능 -> 100안전 x

// Keypath타입, Keypath expr
// 안전한방법

let keyPathToName = \Person.name
let keyPathToAge = \Person.age
