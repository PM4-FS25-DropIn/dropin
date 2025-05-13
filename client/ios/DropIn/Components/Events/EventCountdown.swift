import SwiftUI

struct EventCountdown: View {
    @State private var timeRemaining: TimeInterval = 0
    let eventStartDate: Date
    @Binding var isFinished: Bool
    var formatter: DateComponentsFormatter?
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(formatted(timeRemaining))
            .font(.caption)
            .bold()
            .foregroundColor(timeRemaining <= 1_800 ? .red : .primary)
            .onAppear {
                timeRemaining = eventStartDate.timeIntervalSinceNow
            }
            .onReceive(timer) { time in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    isFinished = true
                }
            }
    }
    
    private func formatted(_ interval: TimeInterval) -> String {
        guard let formatter else {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            return formatter.string(from: interval) ?? "0s"
        }
        return formatter.string(from: interval) ?? "0s"
    }
}

#Preview {
    EventCountdown(eventStartDate: .now + 4_000, isFinished: .constant(false))
}
