//
//  Untitled.swift
//  dropin
//
//  Created by Shpetim Veseli on 24.04.2025.
//

import SwiftUI

struct ChatBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isCurrentSession {
                Spacer()
            }
            
            VStack(alignment: message.isCurrentSession ? .trailing : .leading, spacing: 4) {
                if !message.isCurrentSession {
                    Text(message.username)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(12)
                        .background(message.isCurrentSession ? .accent : Color.gray.opacity(0.2))
                        .foregroundColor(message.isCurrentSession ? .white : .black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Text(message.formattedTimestamp())
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                }
                .padding(message.isCurrentSession ? .leading : .trailing, 60)
            }
            
            if !message.isCurrentSession {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    ChatBubbleView(message: .init(chatRoomId: 1, username: "Shpetim", content: "Hello, I am looking forward to this DropIn!", isCurrentSession: true, timestamp: Date()))
}
