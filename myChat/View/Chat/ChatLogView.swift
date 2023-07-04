//
//  ChatLogView.swift
//  iChat
//
//  Created by Никита Куприянов on 02.07.2023.
//

import SwiftUI

struct ChatLogView: View {
    
    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
        messagesView
            .navigationTitle(vm.chatUser?.username ?? "default email")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                vm.firestoreListener?.remove()
            }
    }
    
    private var messagesView: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(chatMessage: message)
                    }
                    HStack { Spacer() }
                        .id("Empty")
                }
                .onChange(of: vm.count) { newValue in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scrollViewProxy.scrollTo("Empty")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .background(Color(uiColor: .lightGray).opacity(0.2))
            .safeAreaInset(edge:  .bottom) {
                newMessageBar
                .padding(.horizontal)
                .padding(.vertical, 5)
                    .background()
            }
        }
        
    }
    private var newMessageBar: some View {
        HStack(spacing: 16) {
            TextField("Description", text: $vm.chatText, axis: .vertical)
                .lineLimit(5)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
            Button {
                if !vm.chatText.isEmpty {
                    vm.handleSend()
                }
                
            } label: {
                
                    
                ZStack {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                        .frame(width: 35, height: 35)
                        .background(LinearGradient(colors: [.mint, .orange, .pink], startPoint: .bottomLeading, endPoint: .topTrailing).cornerRadius(35))
                }
                    
            }
            .padding(5)
            
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(vm: .init(chatUser: .init(data: [:])))
        }
    }
}
