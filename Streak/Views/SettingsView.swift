import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingResetConfirmation = false
    @State private var showSaveConfirmation = false
    @State private var saveDebouncer = Debouncer(delay: 0.5)


    var body: some View {
        NavigationView {
            ZStack {
                // Gradient Background
                LinearGradient(gradient: Gradient(colors: [Color.customPalette.richBlack, Color.customPalette.richBlack]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 25) {
                        userInformationSection
                        notificationsSection
                        //appearanceSection
                        dataManagementSection
                        aboutSection
                    }
                    .padding()
                }

                // Save Confirmation Toast
                if showSaveConfirmation {
                    VStack {
                        Spacer()
                        Text("Settings Saved")
                            .font(.headline)
                            .padding()
                            .background(Color.customPalette.electricBlue.opacity(0.4))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .transition(.move(edge: .bottom))
                            .padding(.bottom, 50)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSaveConfirmation = false
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton)
        }
        .accentColor(Color.customPalette.electricBlue)
        .alert(isPresented: $showingResetConfirmation) {
            Alert(
                title: Text("Reset All Data"),
                message: Text("Are you sure you want to reset all data? This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    viewModel.resetAllData()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private var cancelButton: some View {
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(Color.customPalette.brightMagenta)
        }

    private func saveSettings() {
        saveDebouncer.debounce {
            viewModel.saveSettings()
            withAnimation {
                showSaveConfirmation = true
            }
        }
    }

    private var userInformationSection: some View {
        SettingsSection(iconName: "person.circle", title: "User Information") {
            TextField("Name", text: $viewModel.userName)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.black)
                .onChange(of: viewModel.userName) { _ in saveSettings() }
        }
    }

    private var notificationsSection: some View {
        SettingsSection(iconName: "bell.circle", title: "Reminders") {
            ReminderSetupView(
                reminders: $viewModel.reminders,
                remindersEnabled: $viewModel.remindersEnabled
            )
            .onChange(of: viewModel.reminders) { _ in saveSettings() }
            .onChange(of: viewModel.remindersEnabled) { _ in saveSettings() }
        }
    }

    private var appearanceSection: some View {
        SettingsSection(iconName: "paintbrush", title: "Appearance") {
            Picker("Theme", selection: $viewModel.selectedTheme) {
                Text("Light").tag(AppTheme.light)
                Text("Dark").tag(AppTheme.dark)
                Text("System").tag(AppTheme.system)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: viewModel.selectedTheme) { _ in saveSettings() }
        }
    }

    private var dataManagementSection: some View {
        SettingsSection(iconName: "exclamationmark.triangle", title: "Data Management") {
            Button(action: {
                showingResetConfirmation = true
            }) {
                Text("Reset All Data")
                    .foregroundColor(Color.customPalette.brightMagenta)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.customPalette.brightMagenta.opacity(0.2))
                    .cornerRadius(10)
                    //.shadow(radius: 5)
            }
        }
    }

    private var aboutSection: some View {
        SettingsSection(iconName: "info.circle", title: "About") {
            HStack {
                Text("Version")
                    .foregroundColor(Color.customPalette.lightGray)
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                    .foregroundColor(.black)
            }
        }
    }
}

// Custom Toggle Style for Reminders
struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color.customPalette.electricBlue : Color.customPalette.lightGray)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .padding(3)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                )
                .onTapGesture {
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}

// Custom Section View
struct SettingsSection<Content: View>: View {
    let iconName: String
    let title: String
    let content: Content

    init(iconName: String, title: String, @ViewBuilder content: () -> Content) {
        self.iconName = iconName
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.customPalette.electricBlue)
                    .font(.title2)
                Text(title)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
            }
            .padding(.bottom, 5)
            content
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.3))
        .cornerRadius(15)
        //.shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: 5)
    }
}


struct Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    mutating func debounce(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem { action() }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
}
