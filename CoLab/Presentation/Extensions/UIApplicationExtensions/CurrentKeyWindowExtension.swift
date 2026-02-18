//
//  CurrentKeyWindowExtension.swift
//  CoLab
//
//  Created by User on 18.02.2026.
//

import UIKit

// Расширение позволяет легко получать текущее окно
extension UIApplication {
    var currentKeyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return self.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return self.keyWindow
        }
    }
}
