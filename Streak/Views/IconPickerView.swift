
//  IconPicker.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//

import Foundation
import SwiftUI

struct IconPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedIcon: String?
    
    let icons: [String] = [
        "book.fill",
        "flame.fill",
        "heart.fill",
        "star.fill",
        "leaf.fill",
        "moon.fill",
        "sun.max.fill",
        "drop.fill",
        // New habit-related icons
        "figure.walk",
        "dumbbell.fill",
        "bed.double.fill",
        "fork.knife",
        "cup.and.saucer.fill",
        "pills.fill",
        "brain.head.profile",
        "clock.fill",
        "dollarsign.circle.fill",
        "pencil.and.outline",
        "music.note",
        "house.fill",
        "trash.slash.fill",
        "hand.thumbsup.fill"
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 50))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(icons, id: \.self) { iconName in
                        Button(action: {
                            selectedIcon = iconName
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: iconName)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Select Icon", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
