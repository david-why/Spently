//
//  StringExtensions.swift
//  Spently
//
//  Created by David Wang on 2025/6/22.
//

import Foundation
import UIKit

extension String {
    var image: UIImage {
        let font = UIFont.systemFont(ofSize: 30)
        let emojiSize = self.size(withAttributes: [.font: font])

        return UIGraphicsImageRenderer(size: emojiSize).image { context in
//            UIColor.clear.setFill()
//            context.fill(CGRect(origin: .zero, size: emojiSize))
            self.draw(at: .zero, withAttributes: [.font: font])
        }

    }
}
