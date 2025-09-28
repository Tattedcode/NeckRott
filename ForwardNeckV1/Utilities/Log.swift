//
//  Log.swift
//  ForwardNeckV1
//
//  Simple logging helper to unify debug prints.
//

import Foundation

enum Log {
    static func debug(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {
        print("[DEBUG] \(file):\(line) \(function) – \(message)")
    }

    static func info(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {
        print("[INFO] \(file):\(line) \(function) – \(message)")
    }

    static func error(_ message: String, file: String = #fileID, function: String = #function, line: Int = #line) {
        print("❌[ERROR] \(file):\(line) \(function) – \(message)")
    }
}


