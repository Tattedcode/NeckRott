//
//  SupabaseService.swift
//  ForwardNeckV1
//
//  Service layer for interacting with Supabase backend
//

import Foundation
import Supabase

/// Service for managing Supabase connections and operations
/// Handles all communication with the leaderboard backend
@MainActor
final class SupabaseService {
    // Singleton instance
    static let shared = SupabaseService()
    
    // Supabase client
    private let client: SupabaseClient
    
    // Table name
    private let tableName = "leaderboard_users"
    
    private init() {
        // Initialize Supabase client with credentials
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://zlkndnpjqajahgvrtdyf.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsa25kbnBqcWFqYWhndnJ0ZHlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NTgwMzgsImV4cCI6MjA3NzIzNDAzOH0.-xCNLGrli153XSycp82nEcyivfV_Vh2ITwdhOmxfV-4"
        )
        
        Log.info("SupabaseService initialized")
    }
    
    // MARK: - User Stats Sync
    
    /// Sync user's exercise stats to Supabase
    /// - Parameters:
    ///   - deviceId: Unique device identifier
    ///   - username: User's display name (optional)
    ///   - countryCode: User's country code (optional)
    ///   - totalSessions: Total exercise sessions completed this month
    ///   - monthYear: Current month in "YYYY-MM" format
    func syncUserStats(deviceId: String, username: String?, countryCode: String?, totalSessions: Int, monthYear: String) async throws {
        Log.info("Syncing stats for device \(deviceId): sessions=\(totalSessions), month=\(monthYear)")
        
        // Prepare data for upsert using JSONEncoder
        struct UserStatsData: Codable {
            let device_id: String
            let username: String?
            let country_code: String?
            let total_sessions: Int
            let month_year: String
            let last_updated: String
        }
        
        let userData = UserStatsData(
            device_id: deviceId,
            username: username,
            country_code: countryCode,
            total_sessions: totalSessions,
            month_year: monthYear,
            last_updated: ISO8601DateFormatter().string(from: Date())
        )
        
        do {
            // Use upsert to insert or update
            try await client
                .from(tableName)
                .upsert(userData)
                .execute()
            
            Log.info("Successfully synced stats to Supabase")
        } catch {
            Log.error("Failed to sync stats: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Leaderboard Fetching
    
    /// Fetch top users from the leaderboard
    /// - Parameters:
    ///   - limit: Number of top users to fetch
    ///   - monthYear: Month to fetch leaderboard for
    /// - Returns: Array of LeaderboardUser with ranks assigned
    func fetchLeaderboard(limit: Int = 100, monthYear: String) async throws -> [LeaderboardUser] {
        Log.info("Fetching leaderboard for month \(monthYear), limit: \(limit)")
        
        do {
            // Query leaderboard, ordered by total_sessions descending
            let response: [LeaderboardUser] = try await client
                .from(tableName)
                .select()
                .eq("month_year", value: monthYear)
                .order("total_sessions", ascending: false)
                .limit(limit)
                .execute()
                .value
            
            // Assign ranks based on position
            let rankedUsers = response.enumerated().map { index, user in
                var rankedUser = user
                rankedUser.rank = index + 1
                return rankedUser
            }
            
            Log.info("Fetched \(rankedUsers.count) users from leaderboard")
            return rankedUsers
        } catch {
            Log.error("Failed to fetch leaderboard: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Fetch a specific user's rank and stats
    /// - Parameters:
    ///   - deviceId: User's device ID
    ///   - monthYear: Month to check rank for
    /// - Returns: User's rank (1-indexed) or nil if not found
    func fetchUserRank(deviceId: String, monthYear: String) async throws -> (rank: Int, user: LeaderboardUser)? {
        Log.info("Fetching rank for device \(deviceId) in month \(monthYear)")
        
        do {
            // First, get the user's data
            let userResponse: [LeaderboardUser] = try await client
                .from(tableName)
                .select()
                .eq("device_id", value: deviceId)
                .eq("month_year", value: monthYear)
                .execute()
                .value
            
            guard let user = userResponse.first else {
                Log.info("User not found in leaderboard")
                return nil
            }
            
            // Count how many users have more sessions than this user
            let countResponse: [LeaderboardUser] = try await client
                .from(tableName)
                .select()
                .eq("month_year", value: monthYear)
                .gt("total_sessions", value: user.totalSessions)
                .execute()
                .value
            
            let usersAbove = countResponse.count
            let rank = usersAbove + 1
            
            var rankedUser = user
            rankedUser.rank = rank
            
            Log.info("User rank: \(rank) with \(user.totalSessions) sessions")
            return (rank, rankedUser)
        } catch {
            Log.error("Failed to fetch user rank: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Profile Updates
    
    /// Update user's display name
    /// - Parameters:
    ///   - deviceId: User's device ID
    ///   - username: New username
    ///   - monthYear: Current month
    func updateUsername(deviceId: String, username: String, monthYear: String) async throws {
        Log.info("Updating username for device \(deviceId) to '\(username)'")
        
        do {
            struct UpdateData: Codable {
                let username: String
                let last_updated: String
            }
            
            let updateData = UpdateData(
                username: username,
                last_updated: ISO8601DateFormatter().string(from: Date())
            )
            
            try await client
                .from(tableName)
                .update(updateData)
                .eq("device_id", value: deviceId)
                .eq("month_year", value: monthYear)
                .execute()
            
            Log.info("Successfully updated username")
        } catch {
            Log.error("Failed to update username: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Update user's country code
    /// - Parameters:
    ///   - deviceId: User's device ID
    ///   - countryCode: New country code
    ///   - monthYear: Current month
    func updateCountryCode(deviceId: String, countryCode: String, monthYear: String) async throws {
        Log.info("Updating country code for device \(deviceId) to '\(countryCode)'")
        
        do {
            struct UpdateData: Codable {
                let country_code: String
                let last_updated: String
            }
            
            let updateData = UpdateData(
                country_code: countryCode,
                last_updated: ISO8601DateFormatter().string(from: Date())
            )
            
            try await client
                .from(tableName)
                .update(updateData)
                .eq("device_id", value: deviceId)
                .eq("month_year", value: monthYear)
                .execute()
            
            Log.info("Successfully updated country code")
        } catch {
            Log.error("Failed to update country code: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Testing Helpers
    
    /// Delete all leaderboard entries for a given month (TESTING ONLY)
    func deleteAllForMonth(_ monthYear: String) async throws {
        Log.info("Deleting all leaderboard entries for month: \(monthYear)")
        
        try await client
            .from(tableName)
            .delete()
            .eq("month_year", value: monthYear)
            .execute()
        
        Log.info("Successfully deleted all entries for \(monthYear)")
    }
    
    /// Delete ALL leaderboard entries regardless of month (TESTING ONLY - NUCLEAR OPTION)
    /// NOTE: This requires a DELETE policy in Supabase RLS that allows deleting all rows
    func deleteAllLeaderboardEntries() async throws {
        Log.info("🚨 NUCLEAR DELETE - Removing ALL leaderboard entries from database")
        
        do {
            // Delete all entries by using a WHERE clause that matches everything
            // Using a condition that's always true for all rows
            let response = try await client
                .from(tableName)
                .delete()
                .neq("device_id", value: "DELETE_NOTHING_DUMMY_FILTER")  // Matches everything since no row has this ID
                .execute()
            
            Log.info("✅ Delete response received. Status code: \(response.status)")
            Log.info("✅ Successfully deleted ALL leaderboard entries from Supabase")
        } catch {
            Log.error("❌ Delete failed: \(error.localizedDescription)")
            Log.error("❌ Error details: \(error)")
            throw error
        }
    }
}
