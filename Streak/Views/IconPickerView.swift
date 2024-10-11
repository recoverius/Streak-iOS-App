
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


struct ColorPickerView: View {
    @Binding var selectedColor: String
    
    let colors = [
        "pastelRed", "pastelOrange", "pastelYellow",
        "pastelGreen", "pastelBlue", "pastelPurple", 
        "deepPastelRed", "deepPastelOrange", "deepPastelYellow",
        "deepPastelGreen", "deepPastelBlue", "deepPastelPurple"
    ]

    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose a Color")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(Color.customPalette.lightGray)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 15) {
                ForEach(colors, id: \.self) { colorName in
                    ColorButton(colorName: colorName, isSelected: selectedColor == colorName) {
                        selectedColor = colorName
                    }
                }
            }
        }
    }
}


struct ColorButton: View {
    let colorName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.customPalette[colorName] ?? .gray)
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.black : Color.clear, lineWidth: 3)
                )
        }
    }
}
