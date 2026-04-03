import SwiftUI
import PhotosUI

struct OnboardingPhotoStep: View {
    @ObservedObject var viewModel: OnboardingViewModel

    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("Vehicle Photo")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Add a photo of your car")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                        if let image = viewModel.vehicleImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(brandBlue, lineWidth: 2)
                                )
                                .padding(.horizontal, 24)
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(brandBlue)

                                Text("Tap to select a photo")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    .onChange(of: viewModel.selectedPhotoItem) { _ in
                        Task { await viewModel.loadSelectedPhoto() }
                    }

                    if viewModel.vehicleImage != nil {
                        Button {
                            viewModel.vehicleImage = nil
                            viewModel.selectedPhotoItem = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }

                    Text("This helps companies see your vehicle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button {
                    viewModel.previousStep()
                } label: {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                        .frame(width: 50, height: 50)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(14)
                }

                Button {
                    viewModel.nextStep()
                } label: {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(brandBlue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
