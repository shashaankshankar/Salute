//
//  HolderView.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/5/24.
//

import SwiftUI

struct HolderView: View {
    @EnvironmentObject private var authModel: AuthViewModel
    
    var body: some View {
        Group {
            if authModel.user == nil {
                AuthView()
            } else {
                TabBarView()
            }
        }.onAppear(perform: {
            authModel.authState()
        })
    }
}

#Preview {
    HolderView()
}
