import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingResetConfirmation = false
    @State private var hasChanges = false
    @State private var showSaveConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient Background
                LinearGradient(gradient: Gradient(colors: [Color.customPalette.richBlack, Color.customPalette.darkGray]), startPoint: .top, endPoint: .bottom)
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
                            .background(Color.customPalette.electricBlue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .transition(.move(edge: .bottom))
                            .padding(.bottom, 50)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSaveConfirmation = false
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
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
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(Color.customPalette.brightMagenta)
    }

    private var saveButton: some View {
        Button("Save") {
            viewModel.saveSettings()
            withAnimation {
                showSaveConfirmation = true
            }
            hasChanges = false
            
            // Dismiss the view after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .disabled(!hasChanges)
        .foregroundColor(hasChanges ? Color.customPalette.electricBlue : Color.customPalette.lightGray)
    }

    private var userInformationSection: some View {
        SettingsSection(iconName: "person.circle", title: "User Information") {
            TextField("Name", text: $viewModel.userName)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
                .onChange(of: viewModel.userName) { _ in hasChanges = true }
        }
    }

    private var notificationsSection: some View {
            SettingsSection(iconName: "bell.circle", title: "Reminders") {
                ReminderSetupView(
                    reminders: $viewModel.reminders,
                    remindersEnabled: $viewModel.remindersEnabled
                )
                .onChange(of: viewModel.reminders) { _ in hasChanges = true }
                .onChange(of: viewModel.remindersEnabled) { _ in hasChanges = true }
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
            .onChange(of: viewModel.selectedTheme) { _ in hasChanges = true }
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
                    .shadow(radius: 5)
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
                    .foregroundColor(.white)
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
                    .foregroundColor(.white)
            }
            .padding(.bottom, 5)
            content
        }
        .padding()
        .background(Color.customPalette.softPurple.opacity(0.3))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.25), radius: 5, x: 0, y: 5)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel())
    }
}
