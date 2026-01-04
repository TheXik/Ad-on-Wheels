import SwiftUI

struct DashboardView: View {
    // Custom Blue Color from design (Matches Header)
    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main Background
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                DashboardHeaderView()
                    .zIndex(1) // Keep header above scrolling content visually if we add offset
                
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // Active Campaign Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Campaign")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            DashboardCardView(
                                iconName: "megaphone.fill",
                                title: "Firma XYZ",
                                subtitle: "Current Ad",
                                content: "Duration: 14. 3. - 12. 4.",
                                subContent: "Reward: 100€ / month"
                            )
                        }
                        
                        // Messages Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Messages")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            DashboardCardView(
                                iconName: "envelope.fill",
                                title: "New terms available for April.",
                                subtitle: "System Message",
                                content: "Please check the new terms and conditions before starting your next ride.",
                                subContent: nil
                            )
                        }
                        
                        // Quick Stats Grid (Optional extra details)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Stats")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            HStack(spacing: 12) {
                                DashboardStatItemView(title: "Days Left", value: "12")
                                DashboardStatItemView(title: "Total Paid", value: "300€")
                                DashboardStatItemView(title: "Rating", value: "4.9")
                            }
                        }
                        
                        Spacer().frame(height: 100) // Bottom padding for content
                    }
                    .padding(20)
                }
            }
            
            // FAB (Floating Action Button) - Positioned at bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        print("Start Ride Tapped")
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Ride")
                                .fontWeight(.bold)
                        }
                        .padding()
                        .padding(.horizontal, 8)
                        .background(brandBlue)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .shadow(color: brandBlue.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
