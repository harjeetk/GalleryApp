//
//  DynamicAsync.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

import Foundation

private let queue = DispatchQueue(label: "concurent-worker", attributes: DispatchQueue.Attributes.concurrent)

infix operator -->

func --> (
    backgroundClosure: @escaping () -> (),
    mainClosure: @escaping () -> ())
{
    queue.async {
        backgroundClosure()
        DispatchQueue.main.async(execute: mainClosure)
    }
}

func --> <R> (
    backgroundClosure: @escaping () -> R,
    mainClosure: @escaping (_ result: R) -> ())
{
    queue.async {
        let result = backgroundClosure()
        DispatchQueue.main.async(execute: {
            mainClosure(result)
        })
    }
}

prefix operator -->

prefix func --> (closure: @escaping ()-> ()) {
    DispatchQueue.main.async {
        closure()
    }
}

class DynamicAsync<T>: Dynamic<T> {
    
    // MARK: - Overrides
    
    override func fire() {
        -->{ self.listener?(self.value) }
    }
    
    // MARK: - Initialisation
    
    override init(_ v: T) {
        super.init(v)
    }
}
