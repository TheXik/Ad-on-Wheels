import SwiftUI

struct DashboardStatItemView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct DashboardStatItemView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 15) {
            DashboardStatItemView(title: "Dni Do Konca", value: "264")
            DashboardStatItemView(title: "Celkovo najazdené", value: "363km")
            DashboardStatItemView(title: "Money Earned", value: "300€")
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}
