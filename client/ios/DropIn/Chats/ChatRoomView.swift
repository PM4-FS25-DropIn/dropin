//
//  ChatRoomView.swift
//  dropin
//
//  Created by Shpetim Veseli on 24.04.2025.
//
import SwiftUI
import MapKit

/// Defines the view of a chatroom.
struct ChatRoomView: View {
    @Environment(AuthService.self) private var authService
    @Environment(EventStore.self) private var eventStore
    
    @State private var session: Profile?
    @State private var event: DropInEvent
    @State private var viewModel: ChatService
    @State private var newMessage: String = ""
    @State var showingDetailsSheet: Bool = false
    @State private var participants: [Profile] = []
            
    
    init(event: DropInEvent, authService: AuthService) {
        _event = State(initialValue: event)
        let chatService = ChatService(authService: authService, event: event)
        _viewModel = State(wrappedValue: chatService)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(event.title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)

                Spacer()

                Button(action: {
                    showingDetailsSheet.toggle()
                }) {
                    Text("Details")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
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
        .sheet(isPresented: $showingDetailsSheet) {
            VStack {
                ChatRoomDetailsView
            }
        }
    }

    private var ChatRoomDetailsView: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text("Details")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                Text(event.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()

                EventQuickInfo(event: event)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                
                Group {
                    MiniMap(event: event)
                    OpenInMapsButton(event: event)
                }
                .padding(.horizontal)
                
                participantsView
            }
            .padding(.bottom)
        }
        .onAppear {
            Task {
                do {
                    if let eventId = event.id {
                        participants = try await eventStore.getAllParticipants(of: eventId)
                    }
                } catch {
                    print("Failed to load participants: \(error)")
                }
            }
        }
    }
    
    private var participantsView: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Participants")
                .font(.title2)
                .bold()

            VStack(spacing: 8) {
                ForEach(participants) { participant in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                        Text(participant.username)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
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
