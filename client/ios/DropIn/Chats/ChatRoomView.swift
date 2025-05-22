//
//  ChatRoomView.swift
//  dropin
//
//  Created by Shpetim Veseli on 24.04.2025.
//
import SwiftUI

struct ChatRoomView: View {
    @Environment(AuthService.self) private var authService
    
    @State private var session: Profile?
    @State private var event: DropInEvent
    @StateObject private var viewModel: ChatService
    @State private var newMessage: String = ""
            
    
    init(event: DropInEvent, authService: AuthService) {
        _event = State(initialValue: event)
        let chatService = ChatService(authService: authService, event: event)
        _viewModel = StateObject(wrappedValue: chatService)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Text("\(event.title)")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground).ignoresSafeArea())
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .bottom
            )
            
            // Chat Messages
            ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(groupedMessages(), id: \.key) { group in
                                        Text(group.key)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 8)
                                        
                                        ForEach(group.value, id: \.timestamp) { message in
                                            ChatBubbleView(message: message)
                                                .id(message.id)
                                        }
                                    }
                                }
                                .padding(.vertical, 12)
                            }
                            .onAppear {
                                if let lastMessage = viewModel.messages.last {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                            .onChange(of: viewModel.messages) { _, _ in
                                if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Field
            ChatTextFieldView(message: $newMessage) {
                Task {
                    do {
                        try await viewModel.sendMessage(newMessage)
                        newMessage = ""
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .onAppear {
            viewModel.subscribeMessages()
        }
        .onDisappear {
            Task {
                await viewModel.unsubscribeMessages()
            }
        }
    }

    
    private func groupedMessages() -> [(key: String, value: [Message])] {
        let grouped: [String: [Message]] = Dictionary(grouping: viewModel.messages) { $0.formattedDate() }

        let sorted: [(key: String, value: [Message])] = grouped.sorted { (firstDate: (key: String, value: [Message]), secondDate: (key: String, value: [Message])) in
            guard
                let firstDate = firstDate.value.first?.timestamp,
                let secondDate = secondDate.value.first?.timestamp
            else {
                return false
            }
            return firstDate < secondDate
        }

        return sorted
    }
    
}


struct ChatRoomPreviewWrapper: View {
    @State private var profile = Profile(id: UUID(), username: "PreviewUser", avatarUrl: nil, emojicode: "", city: "")
    @State private var event: DropInEvent = DropInEvent(
        id: 1,
        createdAt: Date(),
        title: "Pizza Night",
        description: "Join us for free pizza and chill vibes.",
        imagePaths: ["pizza.jpg"],
        userId: UUID(),
        start: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
        end: Calendar.current.date(byAdding: .hour, value: 3, to: Date())!,
        slotLimit: 10,
        slotsTaken: 3,
        ageRestricted: false,
        chatEnabled: true,
        location: .init(type: "Point", coordinates: [0,0])
    )
    
    var body: some View {
        ChatRoomView(event: event, authService: AuthService())
            .environment(AuthService()) // Provide default service for preview
    }
}

