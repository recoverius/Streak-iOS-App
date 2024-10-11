////
////  FriendsView.swift
////  Streak
////
////  Created by Ilya Golubev on 21/09/2024.
////
//
//import Foundation
//import SwiftUI
//import ContactsUI
//
//struct FriendsView: View {
//    @StateObject private var viewModel = FriendsViewModel()
//    @State private var showingContacts = false
//    @State private var showingFriendCalendar = false
//    @State private var selectedFriend: Friend?
//    @State private var searchText: String = ""
//    @State private var showingErrorAlert = false
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                if viewModel.friends.isEmpty && viewModel.friendRequests.isEmpty {
//                    Text("No friends or friend requests.")
//                        .foregroundColor(.gray)
//                        .padding()
//                } else {
//                    List {
//                        // Friend Requests Section
//                        if !viewModel.friendRequests.isEmpty {
//                            Section(header: Text("Friend Requests")) {
//                                ForEach(viewModel.friendRequests, id: \.recordID) { request in
//                                    HStack {
//                                        VStack(alignment: .leading) {
//                                            if let senderName = request["senderName"] as? String {
//                                                Text("Friend Request from \(senderName)")
//                                                    .font(.headline)
//                                            } else {
//                                                Text("Friend Request")
//                                                    .font(.headline)
//                                            }
//                                            if let encryptedPhone = request["phoneNumber"] as? String,
//                                            let decryptedPhone = CoreDataManager.shared.decryptPhoneNumber(encryptedPhone) {
//                                                Text(decryptedPhone)
//                                                    .font(.subheadline)
//                                                    .foregroundColor(.gray)
//                                            }
//                                        }
//                                        Spacer()
//                                        HStack {
//                                            Button(action: {
//                                                if let senderName = request["senderName"] as? String,
//                                                let encryptedPhone = request["phoneNumber"] as? String,
//                                                let decryptedPhone = CoreDataManager.shared.decryptPhoneNumber(encryptedPhone) {
//                                                    viewModel.acceptFriendRequest(recordID: request.recordID, friendName: senderName, phoneNumber: decryptedPhone)
//                                                }
//                                            }) {
//                                                Text("Accept")
//                                                    .foregroundColor(.white)
//                                                    .padding(6)
//                                                    .background(Color.green)
//                                                    .cornerRadius(8)
//                                            }
//                                            Button(action: {
//                                                viewModel.rejectFriendRequest(recordID: request.recordID)
//                                            }) {
//                                                Text("Reject")
//                                                    .foregroundColor(.white)
//                                                    .padding(6)
//                                                    .background(Color.red)
//                                                    .cornerRadius(8)
//                                            }
//                                        }
//                                    }
//                                }
//                                .onDelete { indices in
//                                    // Optionally handle swipe to reject
//                                    indices.forEach { index in
//                                        let request = viewModel.friendRequests[index]
//                                        viewModel.rejectFriendRequest(recordID: request.recordID)
//                                    }
//                                }
//                            }
//                        }
//                        
//                        // Friends Section
//                        if !viewModel.friends.isEmpty {
//                            Section(header: Text("Friends")) {
//                                ForEach(filteredFriends) { friend in
//                                    HStack {
//                                        VStack(alignment: .leading) {
//                                            Text(friend.name)
//                                                .font(.headline)
//                                            Text(friend.phoneNumber)
//                                                .font(.subheadline)
//                                                .foregroundColor(.gray)
//                                        }
//                                        Spacer()
//                                        Button(action: {
//                                            selectedFriend = friend
//                                            showingFriendCalendar = true
//                                        }) {
//                                            Image(systemName: "calendar")
//                                                .foregroundColor(.blue)
//                                        }
//                                    }
//                                }
//                                .onDelete(perform: viewModel.deleteFriend)
//                            }
//                        }
//                    }
//                    .listStyle(InsetGroupedListStyle())
//                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
//                }
//            }
//            .navigationTitle("Friends")
//            .navigationBarItems(trailing: Button(action: {
//                showingContacts = true
//            }) {
//                Image(systemName: "person.badge.plus")
//            })
//            .sheet(isPresented: $showingContacts) {
//                ContactsPicker { contact in
//                    if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
//                        viewModel.sendFriendRequest(name: contact.givenName + " " + contact.familyName, phoneNumber: phoneNumber)
//                    }
//                }
//            }
//            .sheet(item: $selectedFriend) { friend in
//                FriendCalendarView(friend: friend)
//            }
//            .alert(isPresented: $showingErrorAlert) {
//                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
//            }
//            .onAppear {
//                viewModel.fetchFriends()
//            }
//            .onReceive(viewModel.$errorMessage) { errorMessage in
//                if errorMessage != nil {
//                    showingErrorAlert = true
//                }
//            }
//        }
//    }
//    
//    private var filteredFriends: [Friend] {
//        if searchText.isEmpty {
//            return viewModel.friends
//        } else {
//            return viewModel.friends.filter {
//                $0.name.lowercased().contains(searchText.lowercased()) ||
//                $0.phoneNumber.contains(searchText)
//            }
//        }
//    }
//}
//
//struct ContactsPicker: UIViewControllerRepresentable {
//    var completion: (CNContact) -> Void
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, completion: completion)
//    }
//    
//    func makeUIViewController(context: Context) -> CNContactPickerViewController {
//        let picker = CNContactPickerViewController()
//        picker.delegate = context.coordinator
//        picker.displayedPropertyKeys = [CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey]
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
//    
//    class Coordinator: NSObject, CNContactPickerDelegate {
//        let parent: ContactsPicker
//        let completion: (CNContact) -> Void
//        
//        init(_ parent: ContactsPicker, completion: @escaping (CNContact) -> Void) {
//            self.parent = parent
//            self.completion = completion
//        }
//        
//        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//            completion(contact)
//        }
//    }
//}
//
//
//struct FriendCalendarView: View {
//    let friend: Friend
//    @State private var calendarEntries: [CalendarEntry] = []
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                Text("\(friend.name)'s Calendar")
//                    .font(.title)
//                    .padding()
//                
//                List {
//                    ForEach(calendarEntries) { entry in
//                        HStack {
//                            Text(entry.date, style: .date)
//                            Spacer()
//                            Text(entry.tracker.name)
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            Image(systemName: "checkmark.circle")
//                                .foregroundColor(entry.tracker.entries.contains { $0.id == entry.id && $0.isCompleted } ? .green : .red)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Calendar")
//            .navigationBarItems(trailing: Button("Done") {
//                // Dismiss the view
//                UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
//            })
//            .onAppear {
//                fetchCalendarEntries()
//            }
//        }
//    }
//    
//    private func fetchCalendarEntries() {
//        // Fetch calendar entries from CloudKit or local CoreData
//        // For simplicity, we'll assume local fetch
//        let manager = CoreDataManager.shared
//        calendarEntries = manager.fetchCalendarEntries(for: friend)
//    }
//}
