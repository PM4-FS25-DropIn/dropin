//
//  Supabase.swift
//  dropin-prototype
//
//  Created by leo on 16.03.2025.
//

import Foundation
import OSLog
import Supabase

let supabaseURL = "http://160.85.252.162:8080/"
let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? ""


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
