import SwiftUI

struct BrowseView: View {
    @StateObject private var viewModel: BrowseViewModel
    @State private var selectedCampaign: Campaign?

    init(driverId: Int) {
        _viewModel = StateObject(wrappedValue: BrowseViewModel(driverId: driverId))
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Swipe Ads")
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
                    VStack {
                        Image(systemName: viewModel.errorMessage != nil ? "exclamationmark.triangle" : "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(viewModel.errorMessage != nil ? .orange : .green)
                            .padding()
                        Text(viewModel.errorMessage ?? "No campaigns available")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Refresh") {
                            Task { await viewModel.loadCampaigns() }
                        }
                        .padding(.top)
                    }
                } else {
                    ForEach(viewModel.campaigns.reversed()) { campaign in
                        SwipeCardContainer(
                            campaign: campaign,
                            onRemove: {
                                withAnimation { viewModel.removeCard(campaign) }
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

            HStack(spacing: 40) {
                Button(action: {
                    if let topCard = viewModel.campaigns.first {
                        withAnimation { viewModel.removeCard(topCard) }
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
                    Task { await viewModel.loadCampaigns() }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                        .foregroundColor(.yellow)
                        .frame(width: 50, height: 50)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }

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
            await viewModel.loadCampaigns()
        }
        .sheet(item: $selectedCampaign) { campaign in
            CampaignDetailView(campaign: campaign) {
                Task { await viewModel.applyToCampaign(campaign) }
                selectedCampaign = nil
            }
        }
    }
}

struct SwipeCardContainer: View {
    let campaign: Campaign
    let onRemove: () -> Void
    let onTap: () -> Void

    @State private var offset: CGSize = .zero

    var body: some View {
        BrowseCardView(campaign: campaign)
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
                                offset = CGSize(width: 500, height: 0)
                                onRemove()
                            } else if offset.width < -150 {
                                offset = CGSize(width: -500, height: 0)
                                onRemove()
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
        BrowseView(driverId: 1)
    }
}
