import SwiftUI

enum AuthHeaderMode {
    case login(role: String)
    case register(role: String)
}

struct AuthScaffold<Fields: View, BottomLinks: View>: View {
    let headerMode: AuthHeaderMode
    let subtitle: String
    let isLoading: Bool
    let errorMessage: String?
    let primaryButtonTitle: String
    let primaryAction: () -> Void

    @ViewBuilder var fields: () -> Fields
    @ViewBuilder var bottomLinks: () -> BottomLinks

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

            VStack(spacing: 20) {
                Spacer()

                header

                Text(subtitle)
                    .font(.headline)
                    .foregroundColor(.primary.opacity(0.8))
                    .padding(.bottom, 30)

                VStack(spacing: 15) {
                    fields()
                }
                .padding(.horizontal)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .padding(.vertical, 20)
                } else {
                    Button(action: primaryAction) {
                        Text(primaryButtonTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("BrandColor"))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                VStack(spacing: 15) {
                    bottomLinks()
                }
                .padding(.bottom, 40)
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        VStack(spacing: 5) {
            Text(titleLine1)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.primary)
                .shadow(radius: 5)
                .padding(.top, 40)

            Text(roleText)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundStyle(Color("BrandColor"))
                .shadow(radius: 5)
                .shadow(color: Color("BrandColor").opacity(0.9), radius: 25, x: 0, y: 0)
                .padding(.bottom, 30)
        }
    }

    private var titleLine1: String {
        switch headerMode {
        case .login: return "You are logging in as"
        case .register: return "You are registering as"
        }
    }

    private var roleText: String {
        switch headerMode {
        case .login(let role), .register(let role):
            return role
        }
    }
}

private struct AuthFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.primary.opacity(0.1))
            .cornerRadius(10)
            .foregroundColor(.primary.opacity(0.8))
            .accentColor(Color("BrandColor"))
    }
}

extension View {
    func authFieldStyle() -> some View {
        modifier(AuthFieldStyle())
    }
}
