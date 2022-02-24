//
//  Extentions.swift
//  Netflix
//
//  Created by ziad on 16/02/2022.
//

import Foundation
extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
