//
//  Supabase.swift
//  dropin-prototype
//
//  Created by leo on 16.03.2025.
//

import Foundation
import OSLog
import Supabase

private var getSupabaseURL: String {
    #if DEBUG
    return ProcessInfo.processInfo.environment["LOCAL_SUPABASE_URL"] ?? ""
    #elseif TEST
    return ProcessInfo.processInfo.environment["TEST_SUPABASE_URL"] ?? ""
    #else
    return "http://160.85.252.162:8080"
    #endif
}

private var getSupabaseKey: String {
    #if DEBUG
    return ProcessInfo.processInfo.environment["LOCAL_SUPABASE_KEY"] ?? ""
    #elseif TEST
    return ProcessInfo.processInfo.environment["TEST_SUPABASE_KEY"] ?? ""
    #else
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzQ0MTQ5NjAwLAogICJleHAiOiAxOTAxOTE2MDAwCn0.8vzFDrqMsw3ebkPVpk4CbwOGccnj5mQ7eXGZ4hVkXkU"
    #endif
}


let supabase = SupabaseClient(
    supabaseURL: URL(string: getSupabaseURL)!,
    supabaseKey: getSupabaseKey,
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
