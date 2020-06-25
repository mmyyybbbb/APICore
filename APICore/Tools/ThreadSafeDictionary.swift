//
//  ThreadSafeDictionary.swift
//  APICore
//
//  Created by Andrey Raevnev on 25.06.2020.
//  Copyright © 2020 BCS. All rights reserved.
//

import Foundation

/// A thread-safe dictionary
class ThreadSafeDictionary<Key: Hashable, Value> {
    private let queue = DispatchQueue(label: "apicore.ThreadSafeDictionary", attributes: .concurrent)
    private var dictionary = [Key: Value]()
    
    init() {}
    
    convenience init(_ dictionary: [Key: Value]) {
        self.init()
        self.dictionary = dictionary
    }
}

// MARK: - Properties
extension ThreadSafeDictionary {
    
    /// The first element of the collection.
    var keys: Dictionary<Key, Value>.Keys? {
        var keys: Dictionary<Key, Value>.Keys?
        queue.sync { keys = self.dictionary.keys }
        return keys
    }
 
    /// The number of elements in the array.
    var count: Int {
        var result = 0
        queue.sync { result = self.dictionary.count }
        return result
    }
    
    /// A Boolean value indicating whether the collection is empty.
    var isEmpty: Bool {
        var result = false
        queue.sync { result = self.dictionary.isEmpty }
        return result
    }
    
    /// A textual representation of the array and its elements.
    var description: String {
        var result = ""
        queue.sync { result = self.dictionary.description }
        return result
    }
}


// MARK: - Immutable
extension ThreadSafeDictionary {
    
    func contains(where predicate: ((key: Key, value: Value)) -> Bool) -> Bool {
        var result = false
        queue.sync { result = self.dictionary.contains(where: predicate) }
        return result
    }
    
}

extension ThreadSafeDictionary {
    
    subscript(key: Key) -> Value? {
        get {
            var result: Value?
            queue.sync { result = self.dictionary[key] }
            return result
        }
        set {
            guard let newValue = newValue else { return }
            queue.async(flags: .barrier) {
                self.dictionary[key] = newValue
            }
        }
    }
    
    func removeValue(forKey key: Key, completion: ((Value?) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let value = self.dictionary.removeValue(forKey: key)
            DispatchQueue.main.async { completion?(value) }
        }
    }
    
}

