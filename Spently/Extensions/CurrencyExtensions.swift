//
//  CurrencyExtensions.swift
//  Spently
//
//  Created by David Wang on 2025/6/17.
//

import Foundation

extension Locale.Currency: @retroactive Identifiable {
    public var id: String {
        identifier
    }
}
