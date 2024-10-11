////
////  CloudKitManager.swift
////  Streak
////
////  Created by Ilya Golubev on 21/09/2024.
////
//
//
//import Foundation
//import CloudKit
//import Combine
//import CryptoKit
//
//class CloudKitManager {
//    static let shared = CloudKitManager()
//    private let container: CKContainer
//    private let publicDatabase: CKDatabase
//    
//    // Encryption Key (Same as CoreDataManager)
//    private let encryptionKey: SymmetricKey = {
//        let keyString = "9x2bPm7Lq3Rv8sKt1uWz4yAcEfGhJkNp" // Use a secure, consistent key
//        return SymmetricKey(data: Data(keyString.utf8))
//    }()
//    
//    private init() {
//        container = CKContainer.default()
//        publicDatabase = container.publicCloudDatabase
//    }
//    
//    // Encrypt Phone Number
//    private func encryptPhoneNumber(_ phoneNumber: String) -> String? {
//        guard let data = phoneNumber.data(using: .utf8) else { 
//            print("Failed to convert phone number to data.")
//            return nil 
//        }
//        do {
//            let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
//            return sealedBox.combined?.base64EncodedString()
//        } catch {
//            print("Encryption failed: \(error)")
//            return nil
//        }
//    }
//    
//    // Decrypt Phone Number
//    private func decryptPhoneNumber(_ encryptedPhoneNumber: String) -> String? {
//        guard let data = Data(base64Encoded: encryptedPhoneNumber) else { 
//            print("Failed to decode base64 encrypted phone number.")
//            return nil 
//        }
//        do {
//            let sealedBox = try AES.GCM.SealedBox(combined: data)
//            let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)
//            return String(data: decryptedData, encoding: .utf8)
//        } catch {
//            print("Decryption failed: \(error)")
//            return nil
//        }
//    }
//    
//    // Send Friend Request
//    func sendFriendRequest(from senderName: String, to phoneNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        guard let encryptedPhone = encryptPhoneNumber(phoneNumber) else {
//            completion(.failure(NSError(domain: "EncryptionError", code: -1, userInfo: nil)))
//            return
//        }
//        
//        let record = CKRecord(recordType: "FriendRequest")
//        record["phoneNumber"] = encryptedPhone as CKRecordValue
//        record["status"] = "pending" as CKRecordValue
//        record["senderName"] = senderName as CKRecordValue
//        
//        publicDatabase.save(record) { _, error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }
//    
//    // Accept Friend Request
//    func acceptFriendRequest(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
//        publicDatabase.fetch(withRecordID: recordID) { record, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let record = record else {
//                completion(.failure(NSError(domain: "RecordNotFound", code: -1, userInfo: nil)))
//                return
//            }
//            
//            record["status"] = "accepted" as CKRecordValue
//            self.publicDatabase.save(record) { _, error in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.success(()))
//                }
//            }
//        }
//    }
//    
//    // Reject Friend Request
//    func rejectFriendRequest(recordID: CKRecord.ID, completion: @escaping (Result<Void, Error>) -> Void) {
//        publicDatabase.delete(withRecordID: recordID) { _, error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }
//    
//    // Fetch Pending Friend Requests
//    func fetchPendingFriendRequests(completion: @escaping (Result<[CKRecord], Error>) -> Void) {
//        let predicate = NSPredicate(format: "status == %@", "pending")
//        let query = CKQuery(recordType: "FriendRequest", predicate: predicate)
//        
//        publicDatabase.perform(query, inZoneWith: nil) { records, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            completion(.success(records ?? []))
//        }
//    }
//    
//    // Add Friend Record upon acceptance
//    func addFriendRecord(friend: Friend, completion: @escaping (Result<Void, Error>) -> Void) {
//        let record = CKRecord(recordType: "Friend")
//        record["name"] = friend.name as CKRecordValue
//        record["phoneNumber"] = friend.phoneNumber as CKRecordValue
//        record["status"] = "accepted" as CKRecordValue
//        
//        publicDatabase.save(record) { _, error in
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }
//
//    
//    // Observe Changes (e.g., new friends added)
//    func subscribeToFriendsChanges() {
//        let subscription = CKQuerySubscription(
//            recordType: "Friend",
//            predicate: NSPredicate(value: true),
//            options: [.firesOnRecordCreation]
//        )
//        
//        let notificationInfo = CKSubscription.NotificationInfo()
//        notificationInfo.alertBody = "New friend added!"
//        subscription.notificationInfo = notificationInfo
//        
//        publicDatabase.save(subscription) { subscription, error in
//            if let error = error {
//                print("Error subscribing to friends changes: \(error)")
//            } else {
//                print("Subscribed to friends changes.")
//            }
//        }
//    }
//    
//}
