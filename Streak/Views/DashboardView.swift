//
//  DashboardView.swift
//  Streak
//
//  Created by Ilya Golubev on 17/09/2024.

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showingAddHabit = false
    @State private var showingSettings = false
    @State private var showingAchievements = false
    @State private var showingEditHabit = false
    @State private var habitToEdit: Tracker?
    @State private var dayAnimations: [Bool] = Array(repeating: false, count: 14)
    @State private var isAnimating: Bool = true
    @State private var selectedDate: Date = Date()
    @State private var refreshTrigger = false
//    @State private var showingFriends = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.customPalette.richBlack
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        userInfoView
                        calendarView
                        trackerListView
                        achievementsView
                    }
                    .padding()
                }
//                Button(action: {
//                                    showingFriends = true
//                                }) {
//                                    Image(systemName: "person.2.fill")
//                                        .font(.title2)
//                                        .foregroundColor(.white)
//                                        .padding(12)
//                                        .background(Color.customPalette.electricBlue)
//                                        .clipShape(Circle())
//                                }
                            
                     
                    
            }
            .navigationTitle("Streak")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: settingsButton, trailing: addButton)
        }
        .overlay(
            Group {
                if showingAddHabit {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showingAddHabit = false
                        }
                    
                    AddHabitView(viewModel: viewModel, isPresented: $showingAddHabit)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut)
                } else if showingEditHabit, let habit = habitToEdit {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showingEditHabit = false
                        }
                    
                    EditHabitView(viewModel: viewModel, isPresented: $showingEditHabit, habit: habit)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut)
                }
            }
        )
//        .sheet(isPresented: $showingFriends) {
//            FriendsView()
//        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: settingsViewModel)
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView(achievements: viewModel.currentUser?.achievements ?? [])
        }
        .alert(item: $viewModel.currentNewAchievement) { achievement in
            Alert(
                title: Text("New Achievement!"),
                message: Text("You've earned the '\(achievement.title)' achievement!"),
                dismissButton: .default(Text("Awesome!")) {
                    viewModel.dismissCurrentAchievement()
                }
            )
        }
        .onAppear {
            viewModel.refreshData()
        }
        .onChange(of: showingAddHabit) { newValue in
            if !newValue {
                viewModel.refreshData()
                refreshTrigger.toggle()
            }
        }
        .onChange(of: showingEditHabit) { newValue in
            if !newValue {
                refreshDashboard()
                habitToEdit = nil
            }
        }
        .onChange(of: showingSettings) { newValue in
            if !newValue {
                refreshDashboard()
            }
        }
        .onChange(of: showingAchievements) { newValue in
            if !newValue {
                refreshDashboard()
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            Image(systemName: "gear")
                .font(.title2)
                .foregroundColor(Color.customPalette.electricBlue)
        }
    }
    
    private var addButton: some View {
        Button(action: {
            showingAddHabit = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.customPalette.electricBlue)
                .clipShape(Circle())
        }
    }
    
    private var userInfoView: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.currentUser?.name ?? "User")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                    Text("Longest Streak: \(viewModel.longestStreak) days")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(Color.customPalette.electricBlue)
                }
                Spacer()
            }
            .padding()
            .background(Color.customPalette.softPurple.opacity(0.2))
            .cornerRadius(15)
            
            CampfireViewWrapper(longestStreak: viewModel.longestStreak)
                .frame(width: 100, height: 100)
                .position(x: UIScreen.main.bounds.width - 83, y: 91)
                .opacity(viewModel.longestStreak < 1 ? 0 : 1)
        }
    }
    
    private var calendarView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Last 14 Days")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
            Text(dateRangeString)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(Color.customPalette.lightGray)
            HStack(alignment: .top, spacing: 8) {
                VStack(spacing: 8) {
                    Text(" ")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.clear)
                        .padding(.bottom, 5)
                    ForEach(viewModel.trackers) { tracker in
                        Image(systemName: tracker.iconName)
                            .foregroundColor(Color.customPalette[tracker.colorName])
                            .font(.system(size: 12))
                    }
                }
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(-13...0, id: \.self) { dayOffset in
                                let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: viewModel.currentDate)!
                                DayView(date: date, trackers: viewModel.trackers, viewModel: viewModel, isSelected: selectedDate == date)
                                    .id(dayOffset)
                                    .offset(y: dayAnimations[dayOffset + 13] ? 0 : 50)
                                    .opacity(dayAnimations[dayOffset + 13] ? 1 : 0)
                                    .scaleEffect(dayAnimations[dayOffset + 13] ? 1 : 0.95)
                                    .animation(.easeInOut(duration: 0.15).delay(Double(dayOffset + 13) * 0.05), value: dayAnimations[dayOffset + 13])
                                    .onTapGesture {
                                        selectedDate = date
                                    }
                            }
                        }
                    }
                    .disabled(isAnimating)
                    .onAppear {
                        proxy.scrollTo(0, anchor: .trailing)
                        animateDays()
                    }
                }
            }
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.2))
        .cornerRadius(15)
        .id(refreshTrigger)
    }

    private func animateDays() {
        for index in 0..<14 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.001) {
                withAnimation {
                    self.dayAnimations[index] = true
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isAnimating = false
        }
    }
    
    private var trackerListView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(selectedDate == viewModel.currentDate ? "Today's Habits" : "Habits for \(formattedSelectedDate)")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
            ForEach(viewModel.trackers.filter { viewModel.isScheduledDay(for: $0, on: selectedDate) }) { tracker in
                HabitCardView(tracker: tracker, viewModel: viewModel, showEditHabit: $showingEditHabit, habitToEdit: $habitToEdit, selectedDate: selectedDate)
            }
        }
        .id(refreshTrigger)
    }

    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var achievementsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Achievements")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                Spacer()
                Button("See All") {
                    showingAchievements = true
                }
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(Color.customPalette.electricBlue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.currentUser?.achievements.prefix(3) ?? [], id: \.id) { achievement in
                        AchievementCardView(achievement: achievement)
                    }
                }
            }
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.2))
        .cornerRadius(15)
        .id(refreshTrigger)
    }
    
    private var dateRangeString: String {
        let calendar = Calendar.current
        let endDate = viewModel.currentDate
        guard let startDate = calendar.date(byAdding: .day, value: -13, to: endDate) else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
    }
    
    private func dayOfWeekLetter(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: date).uppercased()
    }
    
    private func longestStreak() -> Int {
        viewModel.trackers.map { viewModel.calculateCurrentStreak(for: $0) }.max() ?? 0
    }

    private func refreshDashboard() {
        viewModel.refreshData()
        refreshTrigger.toggle()
    }
}

struct HabitCardView: View {
    let tracker: Tracker
    @ObservedObject var viewModel: DashboardViewModel
    @Binding var showEditHabit: Bool
    @Binding var habitToEdit: Tracker?
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    @GestureState private var dragOffset: CGFloat = 0
    let selectedDate: Date

    var body: some View {
        ZStack(alignment: .trailing) {
            // Edit button
            HStack {
                Button(action: {
                    habitToEdit = tracker
                    showEditHabit = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                }
                .background(Color.customPalette.electricBlue)
                .clipShape(Circle())
                .opacity(offset < 0 ? -offset / 50 : 0) // Only show when swiped left

                // Delete button
                Button(action: {
                    withAnimation {
                        viewModel.deleteHabit(tracker)
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.black)
                        .frame(width: 50, height: 50)
                }
                .background(Color.customPalette.brightMagenta)
                .clipShape(Circle())
                .opacity(offset < 0 ? -offset / 50 : 0) // Only show when swiped left
            }
            // Main content
            ZStack(alignment: .topTrailing) {
                HStack {
                    Image(systemName: tracker.iconName)
                        .foregroundColor(Color.customPalette[tracker.colorName])
                        .font(.system(size: 24))
                        .frame(width: 40, height: 40)
                        .background(Color.customPalette[tracker.colorName].opacity(0.2))
                        .clipShape(Circle())
                    Text(tracker.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.black)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(viewModel.frequencyText(for: tracker))
                            .font(.caption)
                            .padding(4)
                            .background(Color.customPalette.electricBlue.opacity(0.25))
                            .cornerRadius(5)
                            .foregroundColor(.black)
                        Text("Streak: \(viewModel.calculateCurrentStreak(for: tracker))")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color.customPalette.lightGray)
                        
                            
                    }
                    Button(action: {
                        viewModel.toggleHabitCompletion(for: tracker, on: selectedDate)
                    }) {
                        Image(systemName: viewModel.getCompletionStatus(for: tracker, on: selectedDate) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(Color.customPalette.vibrantTeal)
                            .font(.system(size: 24))
                    }
                }
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.customPalette.softPurple.opacity(0.23), Color.customPalette[tracker.colorName].opacity(0.2)]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(15)

                
            }
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
                                self.offset = -dragThreshold - 50
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

struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack {
            Image(systemName: achievement.iconName)
                .font(.system(size: 32))
                .foregroundColor(Color.customPalette.gold)
            Text(achievement.title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .padding()
        .background(Color.customPalette.electricBlue.opacity(0.2))
        .cornerRadius(10)
    }
}


struct DayView: View {
    let date: Date
    let trackers: [Tracker]
    @ObservedObject var viewModel: DashboardViewModel
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 9) {
            Text(dayOfWeekLetter(for: date))
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            ForEach(trackers) { tracker in
                Circle()
                    .fill(fillColor(for: tracker))
                    .frame(width: 12, height: 12)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 5)
        .background(backgroundColor)
        .cornerRadius(8)
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.customPalette.electricBlue.opacity(0.4)
        } else if date == viewModel.currentDate {
            return Color.customPalette.electricBlue.opacity(0.2)
        } else {
            return Color.clear
        }
    }

    private func fillColor(for tracker: Tracker) -> Color {
        if viewModel.isScheduledDay(for: tracker, on: date) {
            return viewModel.getCompletionStatus(for: tracker, on: date) ? Color.customPalette.vibrantTeal : Color.customPalette.lightGray.opacity(0.3)
        } else {
            return Color.clear
        }
    }

    private func dayOfWeekLetter(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: date).uppercased()
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}


