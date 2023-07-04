//
//  CreateNewMessageViewModel.swift
//  iChat
//
//  Created by Никита Куприянов on 01.07.2023.
//

import SwiftUI

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users: [ChatUser] = []
    @Published var errorMessage: String = ""
    
    init() {
        fetchAllUsers()
    }
    
    func fetchAllUsers() {
        FirebaseManager.shared.firestore
            .collection("users")
            .getDocuments { docSnapshot, error in
                if let error {
                    print(error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                    return
                }
                docSnapshot?.documents.forEach {
                    let user: ChatUser = .init(data: $0.data())
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(user)
                    }
                    
                }
            }
    }
    
}
