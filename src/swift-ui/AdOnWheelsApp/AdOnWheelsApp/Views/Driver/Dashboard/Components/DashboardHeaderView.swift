import SwiftUI

struct DashboardHeaderView: View {
    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    
    var body: some View {
        ZStack {
            brandBlue
                .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 25) {
                // Greeting / Title
                HStack {
                    VStack(alignment: .leading) {
                        Text("👋 Hello Driver")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Ready for the road?")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    // Profile Image or Icon
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal)
                .padding(.top, 40) // Status bar padding
                
                // Main Stats Circle
                HStack(alignment: .center, spacing: 30) {
                    
                    // Left: Distance
                    VStack(alignment: .trailing) {
                        Label("Driven", systemImage: "speedometer")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("45.2 km")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Center: Progress
                    ZStack {
                        CircularProgressBar(progress: 0.51, lineWidth: 8)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "car.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    // Right: Remaining
                    VStack(alignment: .leading) {
                        Label("To Go", systemImage: "flag.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("44.8 km")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                // Progress Bar (Monthly Goal)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Monthly Goal")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Spacer()
                        Text("51%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: geometry.size.width, height: 6)
                                .opacity(0.3)
                                .foregroundColor(.white)
                            
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: geometry.size.width * 0.51, height: 6)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 6)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                            .font(.caption2)
                        Text("Drive 44.8km more to reach payout threshold.")
                            .font(.caption2)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 5)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 25)
            }
        }
        // Fixed height for the header container
        .frame(height: 340)
        .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
        .shadow(color: brandBlue.opacity(0.3), radius: 10, x: 0, y: 10)
    }
}



struct DashboardHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DashboardHeaderView()
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea(.top)
    }
}
