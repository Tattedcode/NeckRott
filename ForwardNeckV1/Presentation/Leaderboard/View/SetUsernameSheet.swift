//
//  SetUsernameSheet.swift
//  ForwardNeckV1
//
//  Sheet for setting up username and joining the leaderboard
//

import SwiftUI

/// Sheet for user to set their leaderboard display name
struct SetUsernameSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let onSave: (String, String?) -> Void
    
    @State private var username: String = ""
    @State private var selectedCountryCode: String
    @State private var showingCountryPicker: Bool = false
    @State private var validationError: String?
    
    // Get current country code on init
    init(currentCountryCode: String? = nil, onSave: @escaping (String, String?) -> Void) {
        self.onSave = onSave
        self._selectedCountryCode = State(initialValue: currentCountryCode ?? Locale.current.region?.identifier ?? "US")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "trophy.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.yellow)
                            
                            Text("Join the Leaderboard")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Compete with users worldwide and track your progress")
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Username input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Display Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("Enter your name", text: $username)
                                .textFieldStyle(.plain)
                                .foregroundColor(.black)
                                .accentColor(.black)
                                .padding()
                                .background(Color(red: 0.82, green: 0.78, blue: 0.70).opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(validationError != nil ? Color.red : Color.black.opacity(0.1), lineWidth: 1)
                                )
                                .autocapitalization(.words)
                                .disableAutocorrection(true)
                                .keyboardType(.asciiCapable)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .onAppear {
                                    // Force text field to use light appearance
                                    UITextField.appearance(whenContainedInInstancesOf: [UIScrollView.self]).keyboardAppearance = .light
                                }
                            
                            if let error = validationError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            } else {
                                Text("3-20 characters, letters and spaces only")
                                    .font(.caption)
                                    .foregroundColor(.black.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Country selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Country")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Button(action: {
                                showingCountryPicker.toggle()
                            }) {
                                HStack {
                                    Text(countryFlag(for: selectedCountryCode))
                                        .font(.system(size: 32))
                                    
                                    Text(countryName(for: selectedCountryCode))
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.black.opacity(0.6))
                                }
                                .padding()
                                .background(Color(red: 0.82, green: 0.78, blue: 0.70).opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        
                        // Privacy notice
                        VStack(spacing: 12) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16))
                                
                                Text("Your display name and country will be visible to all users on the global leaderboard. Your exercise stats are synced monthly.")
                                    .font(.caption)
                                    .foregroundColor(.black.opacity(0.7))
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 20)
                        
                        // Save button
                        Button(action: saveAndJoin) {
                            Text("Join Leaderboard")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isValid ? Color.green : Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!isValid)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
            }
            .sheet(isPresented: $showingCountryPicker) {
                CountryPickerView(selectedCountryCode: $selectedCountryCode)
            }
        }
    }
    
    // MARK: - Validation
    
    private var isValid: Bool {
        validateUsername() == nil
    }
    
    private func validateUsername() -> String? {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Name is required"
        }
        
        if trimmed.count < 3 {
            return "Name must be at least 3 characters"
        }
        
        if trimmed.count > 20 {
            return "Name must be 20 characters or less"
        }
        
        // Allow only letters, numbers, and spaces
        let allowedCharacters = CharacterSet.alphanumerics.union(.whitespaces)
        if trimmed.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return "Name can only contain letters, numbers, and spaces"
        }
        
        return nil
    }
    
    // MARK: - Actions
    
    private func saveAndJoin() {
        validationError = validateUsername()
        
        guard validationError == nil else {
            return
        }
        
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(trimmedUsername, selectedCountryCode)
        dismiss()
    }
    
    // MARK: - Helpers
    
    private func countryFlag(for code: String) -> String {
        code.unicodeScalars
            .map { 127397 + $0.value }
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    
    private func countryName(for code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}

/// Simple country picker view
struct CountryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCountryCode: String
    @State private var searchText: String = ""
    
    // Filter to only include actual countries (2-letter codes), not regions
    private let countries = Locale.Region.isoRegions
        .map { $0.identifier }
        .filter { $0.count == 2 } // Only 2-letter country codes (US, GB, etc), not 3-letter region codes
        .sorted()
    
    private var filteredCountries: [String] {
        if searchText.isEmpty {
            return countries
        } else {
            return countries.filter {
                countryName(for: $0).localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredCountries, id: \.self) { code in
                Button(action: {
                    selectedCountryCode = code
                    dismiss()
                }) {
                    HStack {
                        Text(countryFlag(for: code))
                            .font(.system(size: 32))
                        
                        Text(countryName(for: code))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        if code == selectedCountryCode {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search countries")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func countryFlag(for code: String) -> String {
        code.unicodeScalars
            .map { 127397 + $0.value }
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    
    private func countryName(for code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }
}

#Preview {
    SetUsernameSheet { username, country in
        print("Saved: \(username), \(country ?? "nil")")
    }
}

