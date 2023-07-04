//
//  NewMessage.swift
//  iChat
//
//  Created by Никита Куприянов on 01.07.2023.
//

import SwiftUI
import Nuke
import NukeUI

struct CreateNewMessageView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    let completion: (ChatUser) -> ()
    
    var body: some View {
        NavigationView {
            ScrollView {
                usersListView
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }

                }
            }
        }
        .interactiveDismissDisabled()
    }
    private var usersListView: some View {
        ForEach(vm.users) { user in
            
            HStack(spacing: 16) {
                LazyImage(url: .init(string: user.profileImageUrl))
                    .processors([
                        ImageProcessors.Resize(width: 100, unit: .pixels),
                        ImageProcessors.Resize(height: 100, unit: .pixels)
                    ])
                    .priority(.veryHigh)
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                Text(user.email)
                Spacer()
            }
            .onTapGesture {
                completion(user)
                dismiss()
            }
            .padding(.horizontal)
            Divider()
                .padding(.vertical, 5)
            
            
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewMessageView { _ in }
    }
}
