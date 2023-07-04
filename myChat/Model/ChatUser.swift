//
//  ChatUsey.swift
//  iChat
//
//  Created by Никита Куприянов on 01.07.2023.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid: String
    let email: String
    let profileImageUrl: String
    init(data: [String : Any]) {
        self.uid = data["uid"] as? String ?? "default uid"
        self.email = data["email"] as? String ?? "default email"
        self.profileImageUrl = data["profileImageUrl"] as? String ?? "default url"
    }
    var username: String  {
        email.components(separatedBy: "@").first ?? email
    }
}
