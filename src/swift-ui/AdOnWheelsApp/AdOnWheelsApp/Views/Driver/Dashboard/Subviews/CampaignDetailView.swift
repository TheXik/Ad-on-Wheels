import SwiftUI

struct CampaignDetailView: View {
    // Mock Data (Ideally passed in)
    var companyName: String = "Firma XYZ"
    var campaignTitle: String = "Brand Awareness Spg 24"
    @State private var showApplyAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(60)
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title Header
                    VStack(alignment: .leading, spacing: 5) {
                        Text(companyName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                        
                        Text(campaignTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    Divider()
                    
                    // Info Grid
                    HStack(spacing: 20) {
                        DetailInfoBox(label: "Duration", value: "3 Months", icon: "calendar")
                        DetailInfoBox(label: "Pay", value: "€120/mo", icon: "eurosign.circle")
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About Campaign")
                            .font(.headline)
                        Text("Drive your daily route with our brand branding on your side doors. Requires minimum 500km monthly driving in city center.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // Requirements
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Requirements")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("Sedan or SUV (2018+)")
                        }
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("Clean Driving Record")
                        }
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            Text("Bratislava Region")
                        }
                    }
                    
                    Spacer().frame(height: 20)
                    
                    Button(action: {
                        showApplyAlert = true
                    }) {
                        Text("Apply Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                }
                .padding(25)
                .background(Color.white)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .offset(y: -30)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(UIColor.systemGroupedBackground))
        .alert(isPresented: $showApplyAlert) {
            Alert(
                title: Text("Coming Soon"),
                message: Text("Campaign applications will be available in a future update."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct DetailInfoBox: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct CampaignDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CampaignDetailView()
    }
}
