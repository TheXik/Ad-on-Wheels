import SwiftUI

struct InboxView: View {
    var body: some View {
        List {
            InboxRow(
                title: "New terms available",
                preview: "We have updated our terms of service...",
                date: "Today",
                isUnread: true
            )
            InboxRow(
                title: "Payment Processed",
                preview: "Your payout for March has been sent.",
                date: "Yesterday",
                isUnread: false
            )
            InboxRow(
                title: "Campaign Bonus",
                preview: "Congratulations! You earned a bonus...",
                date: "Mon",
                isUnread: false
            )
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Inbox")
    }
}

struct InboxRow: View {
    let title: String
    let preview: String
    let date: String
    let isUnread: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(isUnread ? Color.blue : Color.clear)
                .frame(width: 10, height: 10)
                .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(isUnread ? .bold : .regular)
                    Spacer()
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(preview)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 5)
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InboxView()
        }
    }
}
