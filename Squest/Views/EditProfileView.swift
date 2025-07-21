import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @StateObject private var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingImagePicker = false
    @State private var showingUnsavedChangesAlert = false
    @State private var selectedItem: PhotosPickerItem?
    
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(userProfile: userProfile))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Avatar Section
                avatarSection
                    .padding(.top, 32)
                
                // Display Name Section
                displayNameSection
                
                // Username Section (Read-only)
                usernameSection
                
                // Action Buttons
                actionButtons
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 24)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
        .onAppear {
            viewModel.loadProfileForEditing()
        }
        .alert("Unsaved Changes", isPresented: $showingUnsavedChangesAlert) {
            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
            Button("Continue Editing", role: .cancel) { }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
        .alert("Error", isPresented: .constant(!viewModel.errorMessage.isEmpty)) {
            Button("OK") {
                viewModel.errorMessage = ""
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - View Components
    
    private var avatarSection: some View {
        VStack(spacing: 16) {
            ZStack {
                if let tempImage = viewModel.tempAvatarImage {
                    Image(uiImage: tempImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                } else {
                    AsyncImage(url: URL(string: viewModel.userProfile.avatarUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 160, height: 160)
                            .foregroundColor(.gray.opacity(0.4))
                    }
                }
            }
            
            VStack(spacing: 12) {
                Button {
                    showingImagePicker = true
                } label: {
                    Label("Change Photo", systemImage: "photo")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                }
                
                if viewModel.tempAvatarImage != nil || viewModel.userProfile.avatarUrl != nil {
                    Button {
                        viewModel.tempAvatarImage = nil
                        viewModel.hasUnsavedChanges = true
                    } label: {
                        Label("Remove Photo", systemImage: "trash")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.12))
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.tempAvatarImage = image
                    viewModel.hasUnsavedChanges = true
                }
            }
        }
    }
    
    private var displayNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Display Name")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            HStack {
                TextField("Enter display name", text: $viewModel.tempDisplayedName)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(viewModel.tempDisplayedName.count)/50")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(viewModel.tempDisplayedName.count > 50 ? .red : .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .cornerRadius(10)
            .onChange(of: viewModel.tempDisplayedName) { _, _ in
                viewModel.hasUnsavedChanges = true
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var usernameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Username")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            HStack {
                Text(viewModel.userProfile.username ?? "")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            
            Text("Username cannot be changed")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                if viewModel.hasUnsavedChanges {
                    showingUnsavedChangesAlert = true
                } else {
                    dismiss()
                }
            }) {
                Text("Cancel")
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }
            
            Button(action: {
                Task {
                    let success = await viewModel.saveProfileChanges()
                    if success {
                        dismiss()
                    }
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                } else {
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .background(viewModel.isLoading ? Color(.systemGray4) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(viewModel.isLoading)
        }
    }
}

#Preview {
    EditProfileView(userProfile: UserProfile(displayedName: "John Doe", username: "johndoe", avatarUrl: "https://via.placeholder.com/150"))
} 
