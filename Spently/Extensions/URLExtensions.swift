//
//  URLExtensions.swift
//  Spently
//
//  Created by David Wang on 2025/6/30.
//

import Foundation

extension URL: @retroactive Identifiable {
    public var id: String {
        self.absoluteString
    }
}
