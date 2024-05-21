//
//  AuthView.swift
//  Salute
//
//  Created by Shashaank Shankar on 6/5/24.
//

import SwiftUI
import PhotosUI

struct AuthView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject private var authModel: AuthViewModel
    @State private var showingResetPassword = false
    @State private var createAccount = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                welcomeText
                emailTextField
                passwordTextField
                resetPasswordButton
                signInButton
                Spacer()
                registerMessage
            }
            .padding()
            .fullScreenCover(isPresented: $createAccount) {
                RegisterView(viewModel: authModel)
            }
            .overlay(LoadingView(show: $authModel.isLoading))
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Subviews

extension AuthView {
    private var welcomeText: some View {
        Text("Welcome Back")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.blue)
            .padding(.bottom)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var emailTextField: some View {
        TextField("Email", text: $email)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    private var passwordTextField: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    private var resetPasswordButton: some View {
        Button(action: {
            showingResetPassword.toggle()
        }) {
            Text("Forgot Password?")
                .font(.callout)
        }
        .sheet(isPresented: $showingResetPassword) {
            ResetPasswordView().presentationDetents([.large])
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private var signInButton: some View {
        Button(action: {
            authModel.signIn(email: email, password: password)
        }) {
            Text("Sign In")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(email.isEmpty || password.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
        .bold()
        .disabled(email.isEmpty || password.isEmpty)
    }
    
    private var registerMessage: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.gray)
            Button(action: {
                createAccount.toggle()
            }) {
                Text("Register Now")
            }
            .fontWeight(.bold)
        }
    }
}

// MARK: - Register View

struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var username: String = ""
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var profilePhoto: Data?
    @State private var selectedPhoto: [PhotosPickerItem] = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 15) {
            createAccountText
            profilePicturePicker
            nameTextField
            usernameTextField
            emailTextField
            passwordTextField
            createAccountButton
            Spacer()
            signInMessage
        }
        .padding()
        .overlay(LoadingView(show: $viewModel.isLoading))
    }
}

// MARK: - Subviews

extension RegisterView {
    private var createAccountText: some View {
        Text("Create Account")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.blue)
            .padding(.bottom)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var profilePicturePicker: some View {
        ZStack {
            PhotosPicker(
                selection: $selectedPhoto,
                maxSelectionCount: 1,
                selectionBehavior: .default,
                matching: .images,
                preferredItemEncoding: .automatic
            ) {
                if let profilePhoto, let image = UIImage(data: profilePhoto) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("DefaultProfilePicture")
                        .resizable()
                        .scaledToFill()
                }
            }
            .onChange(of: selectedPhoto) { _,_ in loadSelectedPhoto() }
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .contentShape(Circle())
        .background(Circle().stroke(Color.gray, lineWidth: 2))
    }
    
    private var nameTextField: some View {
        TextField("Name", text: $name)
            .padding()
            .textContentType(.name)
            .textInputAutocapitalization(.words)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    private var usernameTextField: some View {
        TextField("Username", text: $username)
            .padding()
            .textContentType(.username)
            .textInputAutocapitalization(.never)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    private var emailTextField: some View {
        TextField("Email", text: $email)
            .padding()
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    private var passwordTextField: some View {
        SecureField("Password", text: $password)
            .padding()
            .textContentType(.password)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
    
    private var createAccountButton: some View {
        Button(action: {
            viewModel.signUp(email: email, password: password, name: name, username: username, profileImage: profilePhoto)
        }) {
            Text("Create Account")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(name.isEmpty || email.isEmpty || password.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
        .bold()
    }
    
    private var signInMessage: some View {
        HStack {
            Text("Already have an account?")
                .foregroundColor(.gray)
            Button(action: {
                dismiss()
            }) {
                Text("Sign In").bold()
            }
            .fontWeight(.bold)
        }
    }
}

// MARK: - Helper Methods

extension RegisterView {
    private func loadSelectedPhoto() {
        guard let item = selectedPhoto.first else { return }
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data {
                    self.profilePhoto = data
                }
            case .failure(let failure):
                print("Error: \(failure.localizedDescription)")
            }
        }
    }
}

// MARK: - Labelled Divider

struct LabelledDivider: View {
    let label: String
    let horizontalPadding: CGFloat
    let color: Color

    init(label: String, horizontalPadding: CGFloat = 8, color: Color = Color(UIColor.separator)) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            line
            Text(label)
                .font(.callout)
                .foregroundColor(color)
                .lineLimit(1)
                .fixedSize()
                .offset(y: -1)
            line
        }
    }

    var line: some View {
        VStack { Divider().frame(height: 1).background(color) }.padding(horizontalPadding)
    }
}
