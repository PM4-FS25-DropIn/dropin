//
//  Supabase.swift
//  dropin-prototype
//
//  Created by leo on 16.03.2025.
//

import Foundation
import OSLog
import Supabase

//let supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? ""
//let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? ""

let supabaseURL = "http://127.0.0.1:54321"
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"


let supabase = SupabaseClient(
    supabaseURL: URL(string: supabaseURL)!,
    supabaseKey: supabaseKey,
    options: .init(
        global: .init(logger: AppLogger())
    )
)

struct AppLogger: SupabaseLogger {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "supabase")

    func log(message: SupabaseLogMessage) {
      switch message.level {
      case .verbose:
        logger.log(level: .info, "\(message.description)")
      case .debug:
        logger.log(level: .debug, "\(message.description)")
      case .warning, .error:
        logger.log(level: .error, "\(message.description)")
      }
    }
}
