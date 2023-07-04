//
//  MessageView.swift
//  iChat
//
//  Created by Никита Куприянов on 03.07.2023.
//

import SwiftUI

struct MessageView: View {
    let chatMessage: ChatMessage
    private let ownUID: String = FirebaseManager.shared.auth.currentUser?.uid ?? ""
    var body: some View {
        HStack {
            if chatMessage.fromId == ownUID {
                Spacer()
            }
            HStack {
                Text(chatMessage.text)
//                    .foregroundColor(Color(uiColor: .label))
                    .foregroundColor(.white)
            }
            .padding()
            .background(chatMessage.fromId == ownUID ? .blue : .gray)
            .cornerRadius(10)
            .contextMenu {
                Button {
                    UIPasteboard.general.string = chatMessage.text
                } label: {
                    Label("Copy", systemImage: "doc.on.clipboard")
                }

            }
            .transition(.opacity)
            if chatMessage.fromId != ownUID {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(chatMessage: .init(text: "", fromId: "", toId: "", timestamp: .now))
    }
}
