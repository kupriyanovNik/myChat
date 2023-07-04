//
//  MainMessagesView.swift
//  myChat
//
//  Created by Никита Куприянов on 05.07.2023.
//


import SwiftUI
import Foundation
import Nuke
import NukeUI

struct MainMessagesView: View {
    
    @State private var shouldLogOutOptions: Bool = false
    @State private var shouldShowNewMessageScreen: Bool = false
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    
    @State private var chatUser: ChatUser?
    @State private var shouldNavigateToChatLogView = false
    
    var body: some View {
        NavigationView {
            
            VStack {
                customNavBar
                messagesView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(vm: chatLogViewModel)
                }
                
            }
            .navigationBarHidden(true)
        }
    }
    private var customNavBar: some View {
        HStack(spacing: 16) {
            LazyImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .processors([
                    ImageProcessors.Resize(width: 100, unit: .pixels),
                    ImageProcessors.Resize(height: 100, unit: .pixels)
                ])
                .priority(.veryHigh)
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .shadow(radius: 5)
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.chatUser?.username ?? "")
                    .font(.system(size: 24, weight: .bold))
                Text(vm.chatUser?.email ?? "")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .onTapGesture {
                self.shouldLogOutOptions.toggle()
            }
            
            Spacer()
            Button {
                self.shouldShowNewMessageScreen.toggle()
            } label: {
                Image(systemName: "plus.circle")
                    .font(.system(size: 24, weight: .bold))
            }.buttonStyle(.plain)
                .sheet(isPresented: $shouldShowNewMessageScreen) {
                    CreateNewMessageView { user in
                        print(user.email)
                        self.shouldNavigateToChatLogView.toggle()
                        self.chatUser = user
                        self.chatLogViewModel.chatUser = user
                        self.chatLogViewModel.fetchMessages()
                    }
                }
        }
        .padding()
        .actionSheet(isPresented: $shouldLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [.default(Text("Log Out"), action: {
                vm.handleSignOut()
            }), .cancel()])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut) {
            AuthView {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
                self.vm.fetchRecentMessages()
            }
        }
    }
    private var messagesView: some View {
        ScrollView {
            
            ForEach(vm.recentMessages) { recentMessage in
                
                VStack {
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                        self.chatUser = .init(data: [
                            "email": recentMessage.email,
                            "profileImageUr1": recentMessage.profileImageUrl,
                            "uid": uid
                        ])
                        self.chatLogViewModel.chatUser = self.chatUser
                        self.chatLogViewModel.fetchMessages()
                        self.shouldNavigateToChatLogView.toggle()
                    } label: {
                        HStack(spacing: 16) {
                            LazyImage(url: URL(string: recentMessage.profileImageUrl))
                                .processors([
                                    ImageProcessors.Resize(width: 128, unit: .pixels),
                                    ImageProcessors.Resize(height: 128, unit: .pixels)
                                ])
                                .priority(.normal)
                                .scaledToFill()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                                .padding(5)
                                .shadow(radius: 5)
                            
                            VStack(alignment: .leading) {
                                Text(recentMessage.username)
                                    .font(.system(size: 16, weight: .bold))
                                Text(recentMessage.text)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Text("\(recentMessage.when)")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .buttonStyle(.plain)
                    .accentColor(Color(uiColor: .label))
                    Divider()
                }
                .padding(.horizontal)
                
            }
            .padding(.bottom, 50)
//            .onChange(of: self.shouldNavigateToChatLogView) { _ in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.chatLogViewModel.count += 1
//                }
//            }
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}

