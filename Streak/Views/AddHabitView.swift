//
//  AddHabitView.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//

import SwiftUI

struct AddHabitView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Binding var isPresented: Bool
    
    @State private var habitName = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedTarget: HabitTarget = .daily
    @State private var customDays = 1
    
    let iconOptions = [
        "book.fill",
        "flame.fill",
        "heart.fill",
        "star.fill",
        "leaf.fill",
        "moon.fill",
        "sun.max.fill",
        "drop.fill",
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
    @State private var popularHabits = [
        PopularHabit(name: "Exercise", icon: "figure.walk", target: .daily),
        PopularHabit(name: "Read", icon: "book.fill", target: .daily),
        PopularHabit(name: "Meditate", icon: "brain.head.profile", target: .daily),
        PopularHabit(name: "Drink Water", icon: "drop.fill", target: .daily),
        PopularHabit(name: "Sleep Early", icon: "moon.fill", target: .daily),
        PopularHabit(name: "Eat Healthy", icon: "leaf.fill", target: .daily),
        PopularHabit(name: "Write Journal", icon: "pencil.and.outline", target: .daily),
        PopularHabit(name: "Practice Instrument", icon: "music.note", target: .daily),
        PopularHabit(name: "Learn Language", icon: "text.bubble.fill", target: .daily),
        PopularHabit(name: "Save Money", icon: "dollarsign.circle.fill", target: .weekly),
        PopularHabit(name: "Declutter", icon: "house.fill", target: .weekly),
        PopularHabit(name: "Call Family", icon: "phone.fill", target: .weekly),
        PopularHabit(name: "Take Vitamins", icon: "pills.fill", target: .daily),
        PopularHabit(name: "Stretch", icon: "figure.walk", target: .daily)
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Add New Habit")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
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
                    popularHabitsSection
                    habitDetailsSection
                    targetSection
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
            Text("Customize your habit")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
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
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.2))
        .cornerRadius(20)
    }
    
    private var iconPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
            ForEach(iconOptions, id: \.self) { icon in
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
            }
        }
    }
    
    private var targetSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Target")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Frequency")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.customPalette.lightGray)
                
                Picker("Frequency", selection: $selectedTarget) {
                    Text("Daily").tag(HabitTarget.daily)
                    Text("Weekly").tag(HabitTarget.weekly)
                    Text("Custom").tag(HabitTarget.custom(days: customDays))
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
                        .foregroundColor(.white)
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
    
    private var saveButton: some View {
        Button(action: saveHabit) {
            Text("Save Habit")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
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
        
        viewModel.addNewHabit(name: habitName, iconName: selectedIcon, target: target)
        isPresented = false
    }
    
    private var popularHabitsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Popular Habits")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(popularHabits) { habit in
                            popularHabitBubble(habit: habit, scrollViewWidth: geometry.size.width)
                        }
                    }
                    .padding(.horizontal, (geometry.size.width - 80) / 2) // Center the first and last items
                }
            }
            .frame(height: 80) // Adjust height as needed
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.2))
        .cornerRadius(20)
    }

    private func popularHabitBubble(habit: PopularHabit, scrollViewWidth: CGFloat) -> some View {
        GeometryReader { geometry in
            let bubbleCenter = geometry.frame(in: .global).midX
            let screenCenter = UIScreen.main.bounds.width / 2
            let distance = abs(screenCenter - bubbleCenter)
            let maxDistance: CGFloat = screenCenter
            let scale = max(1.0 - (distance / maxDistance), 0.7)
            let opacity = max(1.0 - (distance / maxDistance), 0.5)

            Button(action: {
                selectPopularHabit(habit)
            }) {
                VStack(spacing: 5) {
                    Image(systemName: habit.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text(habit.name)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                        .padding(.horizontal, 10)
                }
                .frame(width: 80, height: 80)
                .background(Color.white.opacity(0.3))
                .cornerRadius(40)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .scaleEffect(scale)
                .opacity(opacity)
                .animation(.spring(), value: scale)
            }
            .frame(width: 80, height: 80)
            .onAppear {
                // Ensure values are within expected ranges
                if scale < 0.7 || scale > 1.0 {
                    print("Scale value out of bounds: \(scale)")
                }
                if opacity < 0.5 || opacity > 1.0 {
                    print("Opacity value out of bounds: \(opacity)")
                }
            }
        }
        .frame(width: 80, height: 80)
    }

    private func selectPopularHabit(_ habit: PopularHabit) {
        withAnimation(.spring()) {
            habitName = habit.name
            selectedIcon = habit.icon
            selectedTarget = habit.target
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.customPalette.softPurple.opacity(0.3))
            .cornerRadius(10)
            .foregroundColor(.white)
    }
}

struct PopularHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let target: HabitTarget
}
