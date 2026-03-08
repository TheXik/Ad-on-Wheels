import SwiftUI

struct DashboardHeaderView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    let brandBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            brandBlue
                .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 0) {
                // Extended top area to cover safe area
                Color.clear.frame(height: 0)
                
                // Expanded View
                VStack(spacing: 25) {
                    // Greeting / Title
                    HStack {
                        VStack(alignment: .leading) {
                            Text("👋 Hello \(viewModel.driverName)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Ready for the road?")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal)
                    .padding(.top, 40) 
                    
                    // Main Stats Circle
                    HStack(alignment: .center, spacing: 30) {
                        // Left: Distance
                        VStack(alignment: .trailing) {
                            Label("Driven", systemImage: "speedometer")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(String(format: "%.1f km", viewModel.distanceDriven))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        // Center: Progress
                        ZStack {
                            CircularProgressBar(progress: viewModel.monthlyGoalProgress, lineWidth: 8)
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
                            
                            Text(String(format: "%.1f km", viewModel.distanceRemaining))
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
                            Text(String(format: "%.0f%%", viewModel.monthlyGoalProgress * 100))
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
                                    .frame(width: geometry.size.width * CGFloat(viewModel.monthlyGoalProgress), height: 6)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 6)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.caption2)
                            Text("Drive \(String(format: "%.1f", viewModel.distanceRemaining))km more to reach payout threshold.")
                                .font(.caption2)
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 5)
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 25)
                }
            }
        }
        // Fixed height
        .frame(height: 310)
        .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
        .shadow(color: brandBlue.opacity(0.3), radius: 10, x: 0, y: 10)
    }
}



struct DashboardHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            DashboardHeaderView(viewModel: DashboardViewModel(authService: AuthenticationService()))
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea(.top)
    }
}
