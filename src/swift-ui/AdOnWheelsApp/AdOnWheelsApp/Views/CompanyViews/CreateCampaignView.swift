import SwiftUI

struct CreateCampaignView: View {
    @StateObject private var viewModel: CreateCampaignViewModel
    @Environment(\.dismiss) private var dismiss
    let onCreated: () -> Void

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    init(companyId: Int, onCreated: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: CreateCampaignViewModel(companyId: companyId))
        self.onCreated = onCreated
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Campaign Details")) {
                    TextField("Campaign Name", text: $viewModel.name)

                    ZStack(alignment: .topLeading) {
                        if viewModel.description.isEmpty {
                            Text("Describe what drivers should know...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 8)
                        }
                        TextEditor(text: $viewModel.description)
                            .frame(minHeight: 100)
                    }
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button(action: {
                        Task {
                            await viewModel.createCampaign()
                        }
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.isSubmitting {
                                ProgressView()
                            } else {
                                Text("Create Campaign")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isSubmitting)
                    .foregroundColor(viewModel.isValid ? brandBlue : .gray)
                }
            }
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
}
