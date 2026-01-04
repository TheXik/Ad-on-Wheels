import SwiftUI

struct CircularProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var lineWidth: CGFloat = 10.0
    var backgroundColor: Color = Color.white.opacity(0.3)
    var foregroundColor: Color = .white
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(foregroundColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}

struct CircularProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            CircularProgressBar(progress: 0.65)
                .frame(width: 100, height: 100)
                .padding()
        }
    }
}
