//
//  ChatLogViewModel.swift
//  iChat
//
//  Created by Никита Куприянов on 02.07.2023.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class ChatLogViewModel: ObservableObject {
    
    @Published var count: Int = 0
    
    @Published var chatText: String = ""
    var chatUser: ChatUser?
    @Published var errorMessage: String = ""
    @Published var chatMessages: [ChatMessage] = []
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func handleSend() {
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toID = chatUser?.uid else { return }
        
        let messageData = ["fromId": fromID, "toId": toID, "text": chatText, "timestamp": Timestamp()] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromID)
            .collection(toID)
            .document()
            .setData(messageData) { error in
                if let error {
                    withAnimation {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                }
            }
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(toID)
            .collection(fromID)
            .document()
            .setData(messageData) { error in
                if let error {
                    withAnimation {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                }
            }
        
        self.persistRecentMessage()
        self.chatText = ""
        self.count += 1
        
    }
    
    func fetchMessages() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.count += 1
        }
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toID = chatUser?.uid else { return }
        
        self.firestoreListener?.remove()
        self.chatMessages.removeAll()
        
        self.firestoreListener = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromID)
            .collection(toID)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    withAnimation {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }
                
                querySnapshot?.documentChanges.forEach { change in
                    do {
                        let mess = try change.document.data(as: ChatMessage.self)
                        withAnimation {
                            if change.type == .added {
                                self.chatMessages.append(mess)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
                self.count += 1
            }
    }
    
    private func persistRecentMessage() {
        
        guard let chatUser else { return }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let data: [String: Any] = [
            "timestamp": Timestamp(),
            "text": self.chatText,
            "fromId": uid,
            "toId": toId,
            "profileImageUrl": chatUser.profileImageUrl,
            "email": chatUser.email,
            
        ]
        
        FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
            .setData(data) { error in
                if let error {
                    self.errorMessage = error.localizedDescription
                    print(error.localizedDescription)
                    return
                }
            }
    }
    
}
