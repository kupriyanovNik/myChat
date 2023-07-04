//
//  MainMessagesViewModel.swift
//  iChat
//
//  Created by Никита Куприянов on 01.07.2023.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage: String = ""
    @Published var chatUser: ChatUser?
    
    @Published var isUserCurrentlyLoggedOut: Bool = false
    
    @Published var recentMessages: [RecentMessage] = []
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = (FirebaseManager.shared.auth.currentUser?.uid == nil)
        }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    private var firestoreListener: ListenerRegistration?
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        FirebaseManager.shared.firestore
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                if let error {
                    print(error)
                    return
                }
                guard let data = snapshot?.data() else { return }
                print(data)
                self.chatUser = .init(data: data)
            }
    }
    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        self.firestoreListener?.remove()
        self.recentMessages.removeAll()
        
        self.firestoreListener = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    self.errorMessage = error.localizedDescription
                    print(error.localizedDescription)
                    return
                }
                querySnapshot?.documentChanges.forEach { change in
                    let docId = change.document.documentID
                    if let index = self.recentMessages.firstIndex(where: { $0.id == docId }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    do {
                        let rm = try change.document.data(as: RecentMessage.self)
                        print(rm)
                        self.recentMessages.insert(rm, at: 0)
                    } catch {
                        print(error)
                    }
                    
                    
                }
                
            }
    }
    
    func handleSignOut() {
        self.isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
}
