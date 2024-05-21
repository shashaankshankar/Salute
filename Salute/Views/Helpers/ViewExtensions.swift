//
//  ViewExtensions.swift
//  Salute
//
//  Created by Shashaank Shankar on 7/19/24.
//

import Foundation
import SwiftUI

extension View {
    // Close all active keyboards
    func closeKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Disable with decreased opacity
    func disableWithOpacity(_ condition: Bool)->some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
}
