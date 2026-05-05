import SwiftUI

struct BrowseView: View {
    @ObservedObject var viewModel: BrowseViewModel
    @State private var selectedCampaign: Campaign?
    @State private var hasLoadedOnce = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Discover")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()

            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading campaigns...")
                } else if viewModel.campaigns.isEmpty {
                    VStack(spacing: 12) {
                        if viewModel.errorMessage != nil {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                                .padding()
                            Text(viewModel.errorMessage!)
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        } else if viewModel.allCampaignsSeen {
                            Image(systemName: "eye.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                                .padding()
                            Text("You've seen all available campaigns.")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Text("Check back later for new opportunities!")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.7))
                        } else {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding()
                            Text("No campaigns available right now")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        Button("Refresh") {
                            Task { await viewModel.loadCampaigns() }
                        }
                        .padding(.top)
                    }
                } else {
                    ForEach(viewModel.campaigns.reversed()) { campaign in
                        SwipeCardContainer(
                            campaign: campaign,
                            onSwipeRight: {
                                Task { await viewModel.applyToCampaign(campaign) }
                            },
                            onSwipeLeft: {
                                withAnimation { viewModel.skipCampaign(campaign) }
                            },
                            onTap: {
                                selectedCampaign = campaign
                            }
                        )
                    }
                }

                if viewModel.applySuccess {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("Applied!")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxHeight: .infinity)

            HStack(spacing: 30) {
                Button(action: {
                    if let topCard = viewModel.campaigns.first {
                        withAnimation { viewModel.skipCampaign(topCard) }
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.red)
                        .frame(width: 60, height: 60)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }

                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.undoLastSkip()
                    }
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.title2)
                        .foregroundColor(viewModel.canUndo ? .yellow : .gray.opacity(0.4))
                        .frame(width: 50, height: 50)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .shadow(radius: viewModel.canUndo ? 5 : 0)
                }
                .disabled(!viewModel.canUndo)

                Button(action: {
                    if let topCard = viewModel.campaigns.first {
                        Task { await viewModel.applyToCampaign(topCard) }
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundColor(.green)
                        .frame(width: 60, height: 60)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
            }
            .padding(.bottom, 20)
            .opacity(viewModel.campaigns.isEmpty ? 0 : 1)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .task {
            guard !hasLoadedOnce else { return }
            hasLoadedOnce = true
            await viewModel.loadCampaigns()
        }
        .sheet(item: $selectedCampaign) { campaign in
            CampaignDetailView(campaign: campaign, onApply: {
                Task { await viewModel.applyToCampaign(campaign) }
                selectedCampaign = nil
            })
        }
    }
}

struct SwipeCardContainer: View {
    let campaign: Campaign
    let onSwipeRight: () -> Void
    let onSwipeLeft: () -> Void
    let onTap: () -> Void

    @State private var offset: CGSize = .zero

    /// Normalized drag amount (-1 to 1) for overlay opacity
    private var dragProgress: Double {
        Double(offset.width) / 150.0
    }

    var body: some View {
        BrowseCardView(campaign: campaign)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.green, lineWidth: 4)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.green.opacity(0.05))
                    )
                    .overlay(alignment: .topLeading) {
                        VStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            Text("INTERESTED")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .rotationEffect(.degrees(-15))
                        .padding(.top, 40)
                        .padding(.leading, 20)
                    }
                    .opacity(dragProgress > 0 ? min(dragProgress, 1.0) : 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.red, lineWidth: 4)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.red.opacity(0.05))
                    )
                    .overlay(alignment: .topTrailing) {
                        VStack {
                            Image(systemName: "xmark")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                            Text("SKIP")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .rotationEffect(.degrees(15))
                        .padding(.top, 40)
                        .padding(.trailing, 20)
                    }
                    .opacity(dragProgress < 0 ? min(-dragProgress, 1.0) : 0)
            )
            .padding()
            .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 40)))
        .onTapGesture { onTap() }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    withAnimation {
                        if offset.width > 150 {
                            // Swipe RIGHT → express interest (apply)
                            offset = CGSize(width: 500, height: 0)
                            onSwipeRight()
                        } else if offset.width < -150 {
                            // Swipe LEFT → skip
                            offset = CGSize(width: -500, height: 0)
                            onSwipeLeft()
                        } else {
                            offset = .zero
                        }
                    }
                }
        )
    }
}

struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView(viewModel: BrowseViewModel(driverId: 1))
    }
}
