////
////  FriendsCalendarViewModel.swift
////  Streak
////
////  Created by Ilya Golubev on 21/09/2024.
////
//
//
//import Foundation
//import Combine
//import CloudKit
//
//class FriendsViewModel: ObservableObject {
//    @Published var friends: [Friend] = []
//    @Published var friendRequests: [CKRecord] = []
//    @Published var errorMessage: String?
//    
//    private let coreDataManager = CoreDataManager.shared
//    private let cloudKitManager = CloudKitManager.shared
//    private var cancellables = Set<AnyCancellable>()
//    
//    func fetchFriends() {
//        // Fetch from local CoreData
//        if let user = coreDataManager.fetchUser() {
//            friends = coreDataManager.fetchFriends(for: user)
//        }
//        
//        // Fetch pending friend requests
//        cloudKitManager.fetchPendingFriendRequests { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let requests):
//                    self?.friendRequests = requests
//                case .failure(let error):
//                    print("Error fetching friend requests: \(error)")
//                }
//            }
//        }
//    }
//    
//    func sendFriendRequest(name: String, phoneNumber: String) {
//        guard let currentUser = coreDataManager.fetchUser() else {
//            self.errorMessage = "Failed to fetch current user"
//            return
//        }
//        cloudKitManager.sendFriendRequest(from: currentUser.name, to: phoneNumber) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success():
//                    // Optionally notify the user that the request was sent
//                    break
//                case .failure(let error):
//                    self?.errorMessage = "Failed to send friend request: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
//    
//    func acceptFriendRequest(recordID: CKRecord.ID, friendName: String, phoneNumber: String) {
//        cloudKitManager.acceptFriendRequest(recordID: recordID) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success():
//                    // Add to local CoreData as accepted
//                    if let user = self?.coreDataManager.fetchUser(),
//                       let newFriend = self?.coreDataManager.addFriend(name: friendName, phoneNumber: phoneNumber, status: .accepted, for: user) {
//                        self?.friends.append(newFriend)
//                        self?.cloudKitManager.addFriendRecord(friend: newFriend) { result in
//                            switch result {
//                            case .success():
//                                break
//                            case .failure(let error):
//                                self?.errorMessage = "Failed to sync with CloudKit: \(error.localizedDescription)"
//                            }
//                        }
//                    }
//                case .failure(let error):
//                    self?.errorMessage = "Failed to accept friend request: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
//    
//    func rejectFriendRequest(recordID: CKRecord.ID) {
//        cloudKitManager.rejectFriendRequest(recordID: recordID) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success():
//                    // Optionally notify the user that the request was rejected
//                    self?.friendRequests.removeAll { $0.recordID == recordID }
//                case .failure(let error):
//                    self?.errorMessage = "Failed to reject friend request: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
//    
//    func deleteFriend(at offsets: IndexSet) {
//        offsets.forEach { index in
//            let friend = friends[index]
//            coreDataManager.removeFriend(friend)
//            friends.remove(at: index)
//            // Optionally remove from CloudKit
//        }
//    }
//    
//    private func syncFriends(_ cloudFriends: [Friend]) {
//        // Sync cloud friends with local CoreData
//        // This can include adding new friends, updating existing ones, etc.
//        for cloudFriend in cloudFriends {
//            if !friends.contains(where: { $0.id == cloudFriend.id }) {
//                if let user = coreDataManager.fetchUser() {
//                    _ = coreDataManager.addFriend(name: cloudFriend.name, phoneNumber: cloudFriend.phoneNumber, for: user)
//                }
//            }
//        }
//        // Update the published friends list
//        if let user = coreDataManager.fetchUser() {
//            friends = coreDataManager.fetchFriends(for: user)
//        }
//    }
//}
