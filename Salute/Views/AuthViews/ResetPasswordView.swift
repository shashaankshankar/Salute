//
//  ResetPasswordView.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/5/24.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var email: String = ""
    @EnvironmentObject var authModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                }
                Section(footer: Text("Once sent, check your email to reset your password.")) {
                    Button(action: {
                        authModel.resetPassword(email: email) { error in
                            if error == nil {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }) {
                        Text("Send email link").bold()
                    }
                }
            }.navigationTitle("Reset Password")
                .toolbar {
                    ToolbarItemGroup(placement: .confirmationAction) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    ResetPasswordView()
}
