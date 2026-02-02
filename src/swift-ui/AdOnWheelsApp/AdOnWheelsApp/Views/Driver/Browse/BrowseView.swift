import SwiftUI

struct BrowseView: View {
    @StateObject private var viewModel = BrowseViewModel()
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Spacer()
                Text("Swipe Ads")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
            
            // Card Stack
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
                            Task {
                                await viewModel.loadCampaigns()
                            }
                        }
                        .padding(.top)
                    }
                } else {
                    ForEach(viewModel.campaigns.reversed()) { campaign in
                        ZStack {
                            SwipeCardContainer(campaign: campaign) {
                                withAnimation {
                                    viewModel.removeCard(campaign)
                                }
                            }
                        }
                        .background(
                            NavigationLink(destination: CampaignDetailView(), label: { EmptyView() })
                                .opacity(0)
                        )
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            // Bottom Controls
            HStack(spacing: 40) {
                // Reject Button
                Button(action: {
                    if let topCard = viewModel.campaigns.first {
                         withAnimation {
                             viewModel.removeCard(topCard)
                         }
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.red)
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                
                // Rewind Button
                Button(action: {
                    Task {
                        await viewModel.loadCampaigns()
                    }
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                        .foregroundColor(.yellow)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                
                // Like Button (Apply)
                Button(action: {
                    if let topCard = viewModel.campaigns.first {
                         withAnimation {
                             // TODO: Call apply to campaign API
                             viewModel.removeCard(topCard)
                         }
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .font(.title)
                        .foregroundColor(.green)
                        .frame(width: 60, height: 60)
                        .background(Color.white)
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
    }
}

// Wrapper to handle individual card gestures
struct SwipeCardContainer: View {
    let campaign: Campaign
    let onRemove: () -> Void
    
    @State private var offset: CGSize = .zero
    @State private var color: Color = .black
    
    var body: some View {
        BrowseCardView(campaign: campaign)
            .offset(x: offset.width, y: offset.height * 0.4)
            .rotationEffect(.degrees(Double(offset.width / 40)))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        withAnimation {
                           // Example: Change color based on swipe direction logic could go here
                        }
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
        BrowseView()
    }
}
