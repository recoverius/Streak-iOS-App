//
//  AchievementsView.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//

import SwiftUI

struct AchievementsView: View {
    let achievements: [Achievement]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.customPalette.richBlack.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(achievements.sorted(by: { $0.dateAchieved > $1.dateAchieved })) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: closeButton)
        }
        .accentColor(Color.customPalette.electricBlue)
    }
    
    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color.customPalette.brightMagenta)
                .font(.title2)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.iconName)
                .font(.system(size: 24))
                .foregroundColor(Color.customPalette.gold)
                .frame(width: 50, height: 50)
                .background(Color.customPalette.electricBlue.opacity(0.2))
                .cornerRadius(25)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text(achievement.description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(Color.customPalette.lightGray)
                Text(formattedDate(achievement.dateAchieved))
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(Color.customPalette.vibrantTeal)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.2))
        .cornerRadius(15)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

