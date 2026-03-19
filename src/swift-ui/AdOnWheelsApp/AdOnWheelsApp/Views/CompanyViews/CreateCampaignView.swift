import SwiftUI

struct CreateCampaignView: View {
    @StateObject private var viewModel: CreateCampaignViewModel
    @Environment(\.dismiss) private var dismiss
    let onCreated: () -> Void

    init(companyId: Int, onCreated: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: CreateCampaignViewModel(companyId: companyId))
        self.onCreated = onCreated
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    formSection(title: "Campaign Details") {
                        VStack(spacing: 14) {
                            FormField(icon: "megaphone", placeholder: "Campaign Name", text: $viewModel.name)

                            VStack(alignment: .leading, spacing: 6) {
                                Label("Description", systemImage: "text.alignleft")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextEditor(text: $viewModel.description)
                                    .frame(minHeight: 80)
                                    .padding(10)
                                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                                    .cornerRadius(12)
                                    .overlay(
                                        Group {
                                            if viewModel.description.isEmpty {
                                                Text("Describe what drivers should know...")
                                                    .foregroundColor(.gray.opacity(0.5))
                                                    .padding(.leading, 14)
                                                    .padding(.top, 18)
                                            }
                                        },
                                        alignment: .topLeading
                                    )
                            }
                        }
                    }

                    formSection(title: "Schedule") {
                        VStack(spacing: 14) {
                            DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                                .font(.subheadline)
                            Divider()
                            DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
                                .font(.subheadline)
                        }
                    }

                    formSection(title: "Budget & Drivers") {
                        VStack(spacing: 14) {
                            FormField(icon: "eurosign.circle", placeholder: "Total Budget", text: $viewModel.budget, keyboardType: .decimalPad)
                            FormField(icon: "person.2", placeholder: "Max Drivers", text: $viewModel.maxDrivers, keyboardType: .numberPad)
                            FormField(icon: "eye", placeholder: "Estimated Reach (optional)", text: $viewModel.estimatedReach, keyboardType: .numberPad)
                        }
                    }

                    if let error = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.06))
                        .cornerRadius(12)
                    }

                    Button(action: {
                        Task { await viewModel.createCampaign() }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create Campaign")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(viewModel.isValid ? Color.accentBlue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                    .disabled(!viewModel.isValid || viewModel.isSubmitting)
                }
                .padding(20)
            }
            .background(Color.pageBackground)
            .navigationTitle("New Campaign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: viewModel.didCreate) { created in
                if created { onCreated() }
            }
        }
    }

    func formSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.leading, 4)
            VStack(spacing: 0) {
                content()
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }
}

struct FormField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .font(.subheadline)
        }
        .padding(12)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
