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
    return "http://127.0.0.1:54321"
    #elseif TEST
    return "https://pgdgktaphxujfnduwzqb.supabase.co"
    #else
    return "https://owjhkqoogpvwddoazsto.supabase.co"
    #endif
}

private var getSupabaseKey: String {
    #if DEBUG
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
    #elseif TEST
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnZGdrdGFwaHh1amZuZHV3enFiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0MzIzMjgsImV4cCI6MjA2MzAwODMyOH0.NpsWa-c2nZhD6BOnRYYhzVcoSMN35WVN9V5JM7OwuA0"
    #else
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93amhrcW9vZ3B2d2Rkb2F6c3RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgwMTc4NjQsImV4cCI6MjA2MzU5Mzg2NH0.J8faEbnGt432YOeAFXBWoQzXDEXcf9Clb1INvhg8PUY"
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
