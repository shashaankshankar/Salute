//
//  SignUpView.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/5/24.
//

import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject private var authModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                }
                Section {
                    Button(action: {
                        // Firebase Sign Up
                        authModel.signUp(email: email, password: password, name: name)
                    }, label: {
                        Text("Sign Up").bold()
                    })
                }
            }.navigationTitle("Create an Account")                
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
    SignUpView()
}
