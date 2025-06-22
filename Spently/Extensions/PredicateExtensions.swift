//
//  PredicateExtensions.swift
//  Spently
//
//  Created by David Wang on 2025/6/22.
//

import Foundation

extension Array {
    func combined<T>() -> Predicate<T> where Element == Predicate<T> {
        reduce(#Predicate<T> { _ in true }) { a, b in
            #Predicate { a.evaluate($0) && b.evaluate($0) }
        }
    }
    
    func combinedOr<T>() -> Predicate<T> where Element == Predicate<T> {
        reduce(#Predicate<T> { _ in false }) { a, b in
            #Predicate { a.evaluate($0) || b.evaluate($0) }
        }
    }
}
