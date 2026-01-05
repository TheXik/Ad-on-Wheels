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
                if viewModel.campaigns.isEmpty {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                            .padding()
                        Text("No more ads to show")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Button("Refresh") {
                            viewModel.loadCampaigns()
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
                            // Overlay invisible link or button
                            // A simple way is to add an 'Details' button or make it tappable if not swiping.
                            // For this mock, let's just assume tapping content navigates.
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
                    viewModel.loadCampaigns() // Simple logic for now
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                        .foregroundColor(.yellow)
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                
                // Like Button
                Button(action: {
                    if let topCard = viewModel.campaigns.first {
                         withAnimation {
                             // Here you would add logic to 'Apply' for the job
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
    }
}

// Wrapper to handle individual card gestures
struct SwipeCardContainer: View {
    let campaign: AdCampaign
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
