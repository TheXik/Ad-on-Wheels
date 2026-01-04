import SwiftUI

struct RoleSelectionView: View {
    var onRoleSelected: (InitialUserRole) -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundColor1").opacity(0.6),
                    Color("BackgroundColor2").opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Welcome!")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                        .shadow(radius: 5)

                    Text("Please select how you want to use the app:")
                        .font(.title2)
                        .foregroundColor(.primary.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 40)

                VStack(spacing: 20) {
                    Button(action: { onRoleSelected(.driver) }) {
                        HStack {
                            Image(systemName: "car.fill")
                                .font(.title2)
                            Text("I'm a Driver")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color("BrandColor"))
                        .cornerRadius(15)
                        .shadow(radius: 8)
                    }

                    Button(action: { onRoleSelected(.company) }) {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .font(.title2)
                            Text("I'm a Company")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.primary)
                        .background(Color.primary.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.primary.opacity(0.3), lineWidth: 2)
                        )
                        .cornerRadius(15)
                        .shadow(radius: 8)
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}

#Preview {
    RoleSelectionView { role in
        print("Selected role: \(role)")
    }
}
