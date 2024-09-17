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
                }
            }
        )
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
            }
        }
        .onChange(of: showingSettings) { newValue in
            if !newValue {
                viewModel.refreshData()
            }
        }
        .onChange(of: showingAchievements) { newValue in
            if !newValue {
                viewModel.refreshData()
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
        HStack {
            // Image(systemName: "person.circle.fill")
            //     .resizable()
            //     .frame(width: 60, height: 60)
            //     .foregroundColor(Color.customPalette.vibrantTeal)
            //     .background(Circle().fill(Color.customPalette.offWhite))
            //     .overlay(Circle().stroke(Color.customPalette.electricBlue, lineWidth: 2))
            //     .shadow(radius: 5)
            VStack(alignment: .leading) {
                Text(viewModel.currentUser?.name ?? "User")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text("🔥 Longest Streak: \(longestStreak()) days")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(Color.customPalette.gold)
            }
            Spacer()
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.2))
        .cornerRadius(15)
    }
    
        private var calendarView: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Last 14 Days")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
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
                                .foregroundColor(Color.customPalette.electricBlue)
                                .font(.system(size: 12))
                        }
                    }
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(-13...0, id: \.self) { dayOffset in
                                    let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: viewModel.currentDate)!
                                    VStack(spacing: 8) {
                                        Text(dayOfWeekLetter(for: date))
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        ForEach(viewModel.trackers) { tracker in
                                            if viewModel.isScheduledDay(for: tracker, on: date) {
                                                Circle()
                                                    .fill(viewModel.getCompletionStatus(for: tracker, on: date) ? Color.customPalette.vibrantTeal : Color.customPalette.lightGray.opacity(0.3))
                                                    .frame(width: 12, height: 12)
                                            } else {
                                                Circle()
                                                    .fill(Color.clear)
                                                    .frame(width: 12, height: 12)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 5)
                                    .background(dayOffset == 0 ? Color.customPalette.electricBlue.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                                    .id(dayOffset)
                                }
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(0, anchor: .trailing)
                        }
                    }
                }
            }
            .padding()
            .background(Color.customPalette.softPurple.opacity(0.2))
            .cornerRadius(15)
        }
    
    private var trackerListView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Habits")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            ForEach(viewModel.trackers) { tracker in
                HabitCardView(tracker: tracker, viewModel: viewModel)
                    .overlay(
                        Text(viewModel.frequencyText(for: tracker))
                            .font(.caption)
                            .padding(4)
                            .background(Color.customPalette.electricBlue.opacity(0.7))
                            .cornerRadius(5)
                            .foregroundColor(.white)
                            .padding([.trailing, .top], 15)
                            .padding(.trailing, 100), // Added right padding
                        alignment: .topTrailing
                    )
            }
        }
    }
    
    private var achievementsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Achievements")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
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
}

struct HabitCardView: View {
    let tracker: Tracker
    @ObservedObject var viewModel: DashboardViewModel
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button
            Button(action: {
                withAnimation {
                    viewModel.deleteHabit(tracker)
                }
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
            }
            .background(Color.customPalette.brightMagenta)
            .opacity(offset < 0 ? -offset / 50 : 0) // Only show when swiped left
            .clipShape(Circle())
            // Main content
            HStack {
                Image(systemName: tracker.iconName)
                    .foregroundColor(Color.customPalette.electricBlue)
                    .font(.system(size: 24))
                Text(tracker.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("Streak: \(viewModel.calculateCurrentStreak(for: tracker))")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color.customPalette.lightGray)
                Button(action: {
                    viewModel.toggleHabitCompletion(for: tracker, on: viewModel.currentDate)
                }) {
                    Image(systemName: viewModel.getCompletionStatus(for: tracker, on: viewModel.currentDate) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(Color.customPalette.vibrantTeal)
                        .font(.system(size: 24))
                }
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.customPalette.electricBlue.opacity(0.2), Color.customPalette.softPurple.opacity(0.2)]), startPoint: .leading, endPoint: .trailing))
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

struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack {
            Image(systemName: achievement.iconName)
                .font(.system(size: 32))
                .foregroundColor(Color.customPalette.gold)
            Text(achievement.title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .padding()
        .background(Color.customPalette.electricBlue.opacity(0.2))
        .cornerRadius(10)
    }
}


struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}


