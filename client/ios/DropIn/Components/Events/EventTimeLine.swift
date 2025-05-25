//
//  FriendAvatarCarousel.swift
//  dropin
//
//  Created by leo on 02.04.2025.
//

import SwiftUI

struct EventTimeLine: View {
    @Environment(EventStore.self) private var eventStore
    
    @State private var countdownIsFinished = false
    @State private var highlightedEvent: DropInEvent?
    @State private var sortedEvents: [DropInEvent] = []
    @State private var highlightedEventStatus: EventStatus = .upcoming
    
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            if sortedEvents.isEmpty {
                placeholder
            } else {
                banner
                Spacer()
                eventBubbleStack
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .onAppear {
            sortedEvents = eventStore.joinedEvents.sorted { $0.start < $1.start }
            highlightedEvent = sortedEvents.first
            if let highlightedEvent {
                highlightedEventStatus = highlightedEvent.status
            }
        }
        .onChange(of: eventStore.joinedEvents) {
            sortedEvents = eventStore.joinedEvents.sorted { $0.start < $1.start }
            highlightedEvent = sortedEvents.first
            countdownIsFinished = false
        }
        .onReceive(timer) { time in
            if let highlightedEvent {
                highlightedEventStatus = highlightedEvent.status
            }
        }
    }
    
    private var eventBubbleStack: some View {
        let maxBubbles = 5
        let visibleBubbles = sortedEvents.indices.dropFirst().prefix(maxBubbles)
        let bubbleOffset: CGFloat = 10
        let bubbleSize: CGFloat = 70
        let totalWidth = CGFloat(visibleBubbles.count - 1) * bubbleOffset + bubbleSize

        return ZStack(alignment: .leading) {
            ForEach(Array(visibleBubbles), id: \.self) { index in
                let event = sortedEvents[index]
                let offsetIndex = index - 1

                EventBubble(event: event, ringColor: getEventStatusColorGradient(event.status))
                    .frame(width: bubbleSize, height: bubbleSize)
                    .scaleEffect(1.0 - CGFloat(offsetIndex) * 0.05)
                    .offset(x: CGFloat(offsetIndex) * bubbleOffset)
                    .zIndex(Double(maxBubbles - offsetIndex))
            }
        }
        .frame(width: totalWidth, alignment: .leading)
    }
    
    private var placeholder: some View {
        HStack {
            Label("Join nearby events", systemImage: "drop.fill")
        }
        .foregroundStyle(.white)
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [.accent, .pacificCyan.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
    
    private var banner: some View {
        HStack {
            if let highlightedEvent {
                EventBubble(event: highlightedEvent, ringColor: getEventStatusColorGradient(highlightedEventStatus))
                VStack(alignment: .leading) {
                    Text(highlightedEvent.title)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .bold()
                        .lineLimit(1)
                    HStack {
                        statusMessage
                        EventCountdown(eventStartDate: highlightedEvent.start, isFinished: $countdownIsFinished, timer: self.timer)
                            .opacity(countdownIsFinished ? 0 : 1)
                            .id(highlightedEvent.id)
                    }
                    .font(.footnote)
                }
                Spacer()
            }
        }
        .padding(5)
        .containerRelativeFrame([.horizontal], count: 8, span: 5, spacing: 0)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 100))
        .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(getEventStatusColorGradient(highlightedEventStatus), lineWidth: 0.8)
            )
    }
    
    private var statusMessage: some View {
        switch(highlightedEventStatus) {
        case .upcoming:
            return Text("Starts in")
                .font(.caption)
                .foregroundStyle(getEventStatusColor(highlightedEventStatus))
        case .live:
            return Text("Live")
                .font(.caption)
                .foregroundStyle(getEventStatusColor(highlightedEventStatus))
        case .closing:
            return Text("Closing")
                .font(.caption)
                .foregroundStyle(getEventStatusColor(highlightedEventStatus))
        case .closed:
            return Text("Ended")
                .font(.caption)
                .foregroundStyle(getEventStatusColor(highlightedEventStatus))
        }
    }
    
}

#Preview {
    EventTimeLine()
        .environment(EventStore())
}
