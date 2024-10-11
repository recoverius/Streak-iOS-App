//
//  EditHabitView.swift
//  Streak
//
//  Created by Ilya Golubev on 20/09/2024.
//

import Foundation
import SwiftUI

struct EditHabitView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Binding var isPresented: Bool
    let habit: Tracker
    
    @State private var habitName: String
    @State private var selectedIcon: String
    @State private var selectedTarget: HabitTarget
    @State private var customDays: Int
    @State private var startDate: Date
    @State private var selectedColor: String

    init(viewModel: DashboardViewModel, isPresented: Binding<Bool>, habit: Tracker) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        self.habit = habit
        
        // Initialize state variables with current habit values
        _habitName = State(initialValue: habit.name)
        _selectedIcon = State(initialValue: habit.iconName)
        _selectedTarget = State(initialValue: habit.target)
        _customDays = State(initialValue: {
            if case let .custom(days) = habit.target {
                return days
            }
            return 1
        }())
        _startDate = State(initialValue: habit.startDate)
        _selectedColor = State(initialValue: habit.colorName)
    }
    
    let iconOptions = [
        "book.fill", "flame.fill", "heart.fill", "star.fill", "leaf.fill",
        "moon.fill", "sun.max.fill", "drop.fill", "figure.walk", "dumbbell.fill",
        "bed.double.fill", "fork.knife", "cup.and.saucer.fill", "pills.fill",
        "brain.head.profile", "clock.fill", "dollarsign.circle.fill",
        "pencil.and.outline", "music.note", "house.fill", "trash.slash.fill",
        "hand.thumbsup.fill"
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Edit Habit")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.customPalette.brightMagenta)
                        .font(.title2)
                }
            }
            .padding(.bottom)
            
            ScrollView {
                VStack(spacing: 25) {
                    habitDetailsSection
                    targetSection
                    startDateSection
                    saveButton
                }
            }
        }
        .padding()
        .background(Color.customPalette.richBlack)
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var habitDetailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit your habit")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Habit Name")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.customPalette.lightGray)
                
                TextField("Enter habit name", text: $habitName)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Choose an Icon")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.customPalette.lightGray)
                
                iconPicker
            }

            ColorPickerView(selectedColor: $selectedColor)
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.2))
        .cornerRadius(20)
    }
    
    private var iconPicker: some View {
        Grid(horizontalSpacing: 15, verticalSpacing: 15) {
            ForEach(0..<(iconOptions.count + 3) / 4, id: \.self) { row in
                GridRow {
                    ForEach(0..<4) { column in
                        let index = row * 4 + column
                        if index < iconOptions.count {
                            let icon = iconOptions[index]
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedIcon == icon ? .white : Color.customPalette.lightGray)
                                .frame(width: 60, height: 60)
                                .background(selectedIcon == icon ? Color.customPalette.electricBlue : Color.customPalette.softPurple.opacity(0.5))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(selectedIcon == icon ? Color.customPalette.electricBlue : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedIcon = icon
                                    }
                                }
                        } else {
                            Color.clear
                        }
                    }
                }
            }
        }
    }
    
    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Target")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Frequency")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.customPalette.lightGray)
                
                Picker("Frequency", selection: $selectedTarget) {
                    Text("Daily").tag(HabitTarget.daily)
                    Text("Weekly").tag(HabitTarget.weekly)
                    Text("Custom").tag(HabitTarget.custom(days: customDays))
                }
                .onChange(of: selectedTarget) { newValue in
                    if case let .custom(days) = newValue {
                        customDays = days
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.customPalette.electricBlue.opacity(0.2))
                .cornerRadius(10)
            }
            
            if case .custom = selectedTarget {
                HStack {
                    Text("Every")
                        .foregroundColor(Color.customPalette.lightGray)
                    Stepper("\(customDays) days", value: $customDays, in: 1...30)
                        .foregroundColor(.black)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(Color.customPalette.softPurple.opacity(0.3))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.2))
        .cornerRadius(20)
    }
    
    private var startDateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Start Date")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(Color.customPalette.lightGray)
            
            DatePicker("", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .accentColor(Color.customPalette.electricBlue)
                .colorScheme(.dark)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.customPalette.softPurple.opacity(0.3))
                .cornerRadius(10)
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.2))
        .cornerRadius(20)
    }
    
    private var saveButton: some View {
        Button(action: saveHabit) {
            Text("Save Changes")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(habitName.isEmpty ? Color.customPalette.lightGray : Color.customPalette.electricBlue)
                .cornerRadius(15)
                .shadow(color: habitName.isEmpty ? Color.clear : Color.customPalette.electricBlue.opacity(0.5), radius: 5, x: 0, y: 3)
        }
        .disabled(habitName.isEmpty)
    }
    
    private func saveHabit() {
        let target: HabitTarget
        switch selectedTarget {
        case .daily, .weekly:
            target = selectedTarget
        case .custom:
            target = .custom(days: customDays)
        }
        
        viewModel.updateHabit(habit: habit, name: habitName, iconName: selectedIcon, colorName: selectedColor, target: target, startDate: startDate)
        isPresented = false
    }
}