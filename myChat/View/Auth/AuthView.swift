//
//  ContentView.swift
//  myChat
//
//  Created by Никита Куприянов on 04.07.2023.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    
    @State private var isLoginMode: Bool = false
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirmation: String = ""
    
    @State private var showImagePicker: Bool = false
    @State private var profileImage: UIImage?
    
    @State private var errorMessage: String = ""
    
    @State private var isLoading: Bool = false
    
    let didCompleteLoginProcess: () -> ()
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradient(colors: [.cyan, .pink, .purple, .green])
                    .ignoresSafeArea()
                    .opacity(0.3)
                
                informationView
                
                if isLoading {
                    loader
                }
            }
            .onChange(of: isLoginMode) { _ in
                withAnimation {
                    self.errorMessage = ""
                }
            }
            .onChange(of: self.errorMessage) { newValue in
                if newValue == "Profile image successfully stored" || newValue == "Successfully created account" || newValue == "" {
                    print(newValue)
                } else {
                    withAnimation {
                        self.isLoading = false
                    }
                }
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create account")
        }
    }
    
    private var informationView: some View {
        ScrollView {
            VStack {
                Picker("", selection: $isLoginMode) {
                    Text("Log In")
                        .tag(true)
                    Text("Create account")
                        .tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.bottom)
                
                TextField("email", text: $email, axis: .horizontal)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.none)
                    .padding(12)
                    .background(colorScheme == .dark ? .black : .white)
                    .cornerRadius(5)
                
                HStack(spacing: 16) {
                    
                    if !isLoginMode {
                        Button {
                            self.showImagePicker.toggle()
                        } label: {
                            if let profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                                    .clipShape(Circle())
                                    .frame(width: 100, height: 100)
                            } else {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .clipped()
                                    .frame(width: 100, height: 100)
                            }
                        }
                        .buttonStyle(.plain)
                        .transition(.move(edge: .leading))
                    }
                    
                    VStack(spacing: 16) {
                        SecureField("password", text: $password)
                            .textInputAutocapitalization(.none)
                            .padding(12)
                            .background(colorScheme == .dark ? .black : .white)
                            .cornerRadius(5)
                        if !isLoginMode {
                            SecureField("confirm password", text: $passwordConfirmation)
                                .textInputAutocapitalization(.none)
                                .padding(12)
                                .background(colorScheme == .dark ? .black : .white)
                                .cornerRadius(5)
                                .transition(.move(edge: .trailing))
                        }
                    }
                    .padding(.top)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(errorMessage.lowercased().contains("success") ? .green : .red)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .transition(.scale)
                        .font(.headline)
                        .padding(.top, 16)
                }
                
                Button {
                    handleAuth()
                } label: {
                    HStack {
                        Spacer()
                        Text(isLoginMode ? "Log In" : "Create account")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(.blue)
                    .cornerRadius(5)
                    .transition(.slide)
                    .opacity(errorMessage == "" ? 1 : errorMessage.lowercased().contains("success") ? 1 : 0.5)
                }
                .padding(.top, 16)
                
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage)
                .interactiveDismissDisabled()
        }
        .animation(.linear(duration: 0.2), value: isLoginMode)
    }
    private var loader: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .overlay {
                ProgressView()
                    .scaleEffect(2)
                    .offset(y: 100)
            }
    }
    
    private func handleAuth() {
        hideKeyboard()
        withAnimation {
            self.errorMessage = ""
            self.isLoading = true
        }
        if isLoginMode {
            logInUser()
        } else {
            createNewAccount()
        }
    }
    
    private func logInUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error {
                withAnimation {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            withAnimation {
                self.errorMessage = "Successfully signed in"
            }
            didCompleteLoginProcess()
        }
        
    }
    
    private func createNewAccount() {
        if let _ = profileImage {
            if password == passwordConfirmation {
                FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
                    if let error {
                        withAnimation {
                            self.errorMessage = error.localizedDescription
                        }
                        return
                    }
                    withAnimation {
                        self.errorMessage = "Successfully created account"
                        self.isLoading = true
                    }
                    self.persistImageToStorage()
                }
            } else {
                withAnimation {
                    self.errorMessage = "Password is not equal to password confirmation"
                }
            }
        } else {
            withAnimation {
                self.errorMessage = "Please select your profile image"
            }
        }
        
    }
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.profileImage?.jpegData(compressionQuality: 0.5) else {
            withAnimation {
                self.errorMessage = "Failed to load image"
            }
            return
        }
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error {
                withAnimation {
                    self.errorMessage = error.localizedDescription
                }
            }
            ref.downloadURL { url, error in
                if let error {
                    withAnimation {
                        self.errorMessage = error.localizedDescription
                    }

                    return
                }
                withAnimation {
                    self.errorMessage = "Profile image successfully stored"
                }
                guard let url = url else { return }
                self.storeUserInformation(imageProfileURL: url)
            }
        }
    }
    private func storeUserInformation(imageProfileURL: URL) {
        let manager = FirebaseManager.shared
        guard let uid = manager.auth.currentUser?.uid else { return }
        let userData = ["email" : self.email, "uid" : uid, "profileImageUrl" : imageProfileURL.absoluteString]
        manager.firestore
            .collection("users")
            .document(uid)
            .setData(userData) { error in
                if let error {
                    print(error)
                    withAnimation {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }
                withAnimation {
                    self.errorMessage = "User created successfully"
                }
                didCompleteLoginProcess()
            }
    }
    
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView {
            
        }
    }
}
