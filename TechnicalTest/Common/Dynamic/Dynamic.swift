//
//  Dynamic.swift
//  TechnicalTest
//
//  Created by Harjeet on 11/03/22.
//

class Dynamic<T> {
    
    // MARK: - Typealias
    
    typealias Listener = (T) -> ()
    
    // MARK: - Vars & Lets
    
    var listener: Listener?
    var value: T {
        didSet {
            self.fire()
        }
    }
    
    // MARK: - Initialization
    
    init(_ v: T) {
        value = v
    }
    
    // MARK: - Public func
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    // MARK: -
    
    internal func fire() {
        self.listener?(value)
    }
    
}
