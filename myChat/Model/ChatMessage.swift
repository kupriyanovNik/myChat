//
//  ChatMessage.swift
//  iChat
//
//  Created by Никита Куприянов on 03.07.2023.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let text: String
    let fromId: String
    let toId: String
    let timestamp: Date
}
