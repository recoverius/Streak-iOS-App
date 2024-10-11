//
//  ReminderSetupView.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.
//

import Foundation
import SwiftUI

struct ReminderSetupView: View {
    @Binding var reminders: [Reminder]
    @Binding var remindersEnabled: Bool
    @State private var newReminderTime = Date()
    @State private var newReminderText = ""
    @State private var showingTimePicker = false
    @State private var editingReminder: Reminder?
    @State private var animateList = false
    @State private var isEditingReminder = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                reminderToggle
                
                if remindersEnabled {
                    reminderList
                    addReminderButton
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0), value: remindersEnabled)
            
            if isEditingReminder {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                if let editingReminder = editingReminder {
                    ReminderEditView(reminder: binding(for: editingReminder)) {
                        isEditingReminder = false
                        self.editingReminder = nil
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut, value: isEditingReminder)
    }
    
    private var reminderToggle: some View {
        Toggle(isOn: $remindersEnabled.animation()) {
            Label("Enable Reminders", systemImage: "bell.fill")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
        }
        .toggleStyle(SwitchToggleStyle(tint: Color.customPalette.electricBlue))
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.2))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var reminderList: some View {
        VStack(spacing: 10) {
        ForEach(reminders) { reminder in
            ReminderRow(reminder: reminder) {
                deleteReminder(reminder)
            }
            .onTapGesture {
                showEditView(for: reminder)
            }
            .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .slide))
            .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: animateList)
            }
        }
        .onAppear { animateList = true }
    }


    private func deleteReminder(_ reminder: Reminder) {
        withAnimation {
            reminders.removeAll { $0.id == reminder.id }
            animateList = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateList = true
            }
    }
}
    
    private var addReminderButton: some View {
        Button(action: addReminder) {
            Label("Add Reminder (max 3)", systemImage: "plus.circle.fill")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    reminders.count >= 3 ?
                    Color.customPalette.lightGray :
                    Color.customPalette.electricBlue
                )
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .disabled(reminders.count >= 3)
        .opacity(reminders.count >= 3 ? 0.5 : 1)
        .animation(.easeInOut(duration: 0.2), value: reminders.count)
    }
    
    private func addReminder() {
        withAnimation {
            let newReminder = Reminder(id: UUID(), time: newReminderTime)
            reminders.append(newReminder)
            editingReminder = newReminder
            animateList = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateList = true
            }
        }
    }
    
    private func deleteReminders(at offsets: IndexSet) {
        withAnimation {
            reminders.remove(atOffsets: offsets)
        }
    }
    
    private func binding(for reminder: Reminder) -> Binding<Reminder> {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else {
            fatalError("Can't find reminder in array")
        }
        return $reminders[index]
    }
    
    private func showEditView(for reminder: Reminder) {
        editingReminder = reminder
        isEditingReminder = true
    }
}

struct ReminderRow: View {
    let reminder: Reminder
    let onDelete: () -> Void
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.black)
                    .frame(width: 50, height: 50)
            }
            .background(Color.customPalette.brightMagenta)
            .opacity(offset < 0 ? -offset / 50 : 0) // Only show when swiped left
            .clipShape(Circle())

            // Main content
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.customPalette.electricBlue)
                    .font(.system(size: 20))
                Text(reminder.time, style: .time)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.black)
                Spacer()
                if let customText = reminder.customText {
                    Text(customText)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.customPalette.lightGray)
                        .lineLimit(1)
                }
            }
            .padding()
            .background(Color.customPalette.softPurple.opacity(0.2))
            .cornerRadius(15)
            .offset(x: offset + dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { gesture in
                        withAnimation {
                            let dragThreshold: CGFloat = 50
                            if gesture.translation.width > dragThreshold || (self.isSwiped && gesture.translation.width > 0) {
                                self.offset = 0
                                self.isSwiped = false
                            } else if gesture.translation.width < -dragThreshold {
                                self.offset = -dragThreshold
                                self.isSwiped = true
                            } else {
                                self.offset = self.isSwiped ? -dragThreshold : 0
                            }
                        }
                    }
            )
        }
        .frame(height: 50) // Ensure consistent height
        .clipped() // This will hide the delete button when not swiped
    }
}

struct ReminderEditView: View {
    @Binding var reminder: Reminder
    @State private var tempTime: Date
    @State private var tempCustomText: String
    var onDismiss: () -> Void
    
    init(reminder: Binding<Reminder>, onDismiss: @escaping () -> Void) {
        self._reminder = reminder
        self._tempTime = State(initialValue: reminder.wrappedValue.time)
        self._tempCustomText = State(initialValue: reminder.wrappedValue.customText ?? "")
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Reminder")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            
            VStack(spacing: 15) {
                DatePicker("Time", selection: $tempTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .accentColor(.customPalette.electricBlue)
                
                TextField("", text: $tempCustomText)
                    .placeholder(when: tempCustomText.isEmpty) {
                        Text("Custom Text (Optional)")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(Color.customPalette.softPurple.opacity(0.5))
                    .cornerRadius(10)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.customPalette.softPurple.opacity(0.3))
            .cornerRadius(15)
            
            HStack(spacing: 20) {
                Button("Cancel") {
                    onDismiss()
                }
                .buttonStyle(ReminderEditButtonStyle(color: .customPalette.lightGray))
                
                Button("Save") {
                    reminder.time = tempTime
                    reminder.customText = tempCustomText.isEmpty ? nil : tempCustomText
                    onDismiss()
                }
                .buttonStyle(ReminderEditButtonStyle(color: .customPalette.electricBlue))
            }
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.8))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .frame(maxWidth: 300)
        .padding(.horizontal, 20)
    }
}

struct ReminderEditButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 30)
            .background(color)
            .foregroundColor(.black)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}