//
//  SupabaseService.swift
//  NeckRotV1
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
        // NOTE: If your Supabase project was paused and re-enabled, verify these credentials:
        // 1. Go to Supabase Dashboard → Project Settings → API
        // 2. Copy the "Project URL" (should match supabaseURL below)
        // 3. Copy the "anon public" key (should match supabaseKey below)
        // 4. If keys don't match, update them here
        let supabaseURLString = "https://zlkndnpjqajahgvrtdyf.supabase.co"
        let supabaseKeyString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpsa25kbnBqcWFqYWhndnJ0ZHlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NTgwMzgsImV4cCI6MjA3NzIzNDAzOH0.-xCNLGrli153XSycp82nEcyivfV_Vh2ITwdhOmxfV-4"
        
        guard let url = URL(string: supabaseURLString) else {
            fatalError("Invalid Supabase URL: \(supabaseURLString)")
        }
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKeyString
        )
        
        Log.info("SupabaseService initialized with URL: \(supabaseURLString)")
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
        Log.info("Syncing stats for device \(deviceId): username=\(username ?? "nil"), country=\(countryCode ?? "nil"), sessions=\(totalSessions), month=\(monthYear)")
        
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
            // Note: Upsert requires a unique constraint on (device_id, month_year) in Supabase
            // The upsert will insert if new, or update if the combination already exists
            let response = try await client
                .from(tableName)
                .upsert(userData)
                .execute()
            
            Log.info("Successfully synced stats to Supabase. Response status: \(response.status)")
            Log.info("Synced data: device_id=\(deviceId), username=\(username ?? "nil"), sessions=\(totalSessions), month=\(monthYear)")
        } catch {
            Log.error("Failed to sync stats: \(error.localizedDescription)")
            Log.error("Error details: \(error)")
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
        Log.info("🔍 Fetching leaderboard for month '\(monthYear)', limit: \(limit)")
        Log.info("🔍 Table name: \(tableName)")
        
        do {
            // Query leaderboard, ordered by total_sessions descending
            // Select all columns - this should return all users for the month
            // IMPORTANT: Make sure month_year format matches exactly (YYYY-MM)
            let response: [LeaderboardUser] = try await client
                .from(tableName)
                .select()
                .eq("month_year", value: monthYear)
                .order("total_sessions", ascending: false)
                .limit(limit)
                .execute()
                .value
            
            // Log detailed info about what was fetched
            Log.info("✅ Raw response count: \(response.count) users")
            if response.isEmpty {
                Log.info("⚠️ No users found in leaderboard for month \(monthYear)")
                Log.info("⚠️ This could mean:")
                Log.info("   1. No users have synced data for this month")
                Log.info("   2. RLS policies are filtering results")
                Log.info("   3. Month format mismatch (expected: \(monthYear))")
            } else {
                for (index, user) in response.enumerated() {
                    Log.info("   User \(index + 1): device_id=\(user.id), username=\(user.username ?? "nil"), sessions=\(user.totalSessions), month=\(user.monthYear)")
                }
            }
            
            // Assign ranks based on position
            let rankedUsers = response.enumerated().map { index, user in
                var rankedUser = user
                rankedUser.rank = index + 1
                return rankedUser
            }
            
            Log.info("✅ Successfully fetched \(rankedUsers.count) users from leaderboard for month \(monthYear)")
            return rankedUsers
        } catch {
            Log.error("❌ Failed to fetch leaderboard: \(error.localizedDescription)")
            Log.error("❌ Error details: \(error)")
            Log.error("❌ Month being queried: \(monthYear)")
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
    
    // MARK: - User Deletion
    
    /// Delete a specific user from the leaderboard by device ID
    /// - Parameters:
    ///   - deviceId: The device ID of the user to delete
    ///   - monthYear: Optional month to delete from. If nil, deletes from all months
    func deleteUser(deviceId: String, monthYear: String? = nil) async throws {
        Log.info("Deleting user with device_id: \(deviceId), month: \(monthYear ?? "all")")
        
        var query = client
            .from(tableName)
            .delete()
            .eq("device_id", value: deviceId)
        
        if let monthYear = monthYear {
            query = query.eq("month_year", value: monthYear)
        }
        
        try await query.execute()
        
        Log.info("Successfully deleted user \(deviceId)")
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
    
    // MARK: - Connect 4 Methods
    
    /// Create a new Connect 4 match waiting for an opponent
    /// - Parameter deviceId: Device ID of the player creating the match
    /// - Returns: The created match
    func createConnect4Match(deviceId: String) async throws -> Connect4Match {
        Log.info("Creating Connect 4 match for device: \(deviceId)")
        
        struct MatchData: Codable {
            let player1_device_id: String
            let status: String
            let current_turn_device_id: String
        }
        
        let matchData = MatchData(
            player1_device_id: deviceId,
            status: Connect4MatchStatus.waiting.rawValue,
            current_turn_device_id: deviceId
        )
        
        do {
            let response: Connect4Match = try await client
                .from("connect4_matches")
                .insert(matchData)
                .select()
                .single()
                .execute()
                .value
            
            Log.info("Successfully created Connect 4 match: \(response.id)")
            return response
        } catch {
            Log.error("Failed to create Connect 4 match: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Find a waiting match to join (random matchmaking)
    /// - Parameter excludingDeviceId: Device ID to exclude from search
    /// - Returns: A waiting match if found, nil otherwise
    func findWaitingConnect4Match(excludingDeviceId: String) async throws -> Connect4Match? {
        Log.info("Finding waiting Connect 4 match (excluding: \(excludingDeviceId))")
        
        do {
            let response: [Connect4Match] = try await client
                .from("connect4_matches")
                .select()
                .eq("status", value: Connect4MatchStatus.waiting.rawValue)
                .neq("player1_device_id", value: excludingDeviceId)
                .is("player2_device_id", value: nil)
                .order("created_at", ascending: true)
                .limit(1)
                .execute()
                .value
            
            if let match = response.first {
                Log.info("Found waiting match: \(match.id)")
                return match
            } else {
                Log.info("No waiting matches found")
                return nil
            }
        } catch {
            Log.error("Failed to find waiting match: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Join an existing match as player 2
    /// - Parameters:
    ///   - matchId: ID of the match to join
    ///   - deviceId: Device ID of the player joining
    /// - Returns: Updated match
    func joinConnect4Match(matchId: UUID, deviceId: String) async throws -> Connect4Match {
        Log.info("Joining Connect 4 match \(matchId) as device: \(deviceId)")
        
        struct UpdateData: Codable {
            let player2_device_id: String
            let status: String
            let current_turn_device_id: String
            let updated_at: String
        }
        
        let updateData = UpdateData(
            player2_device_id: deviceId,
            status: Connect4MatchStatus.inProgress.rawValue,
            current_turn_device_id: deviceId, // Player 2 goes first after joining
            updated_at: ISO8601DateFormatter().string(from: Date())
        )
        
        do {
            let response: Connect4Match = try await client
                .from("connect4_matches")
                .update(updateData)
                .eq("id", value: matchId)
                .select()
                .single()
                .execute()
                .value
            
            Log.info("Successfully joined match: \(matchId)")
            return response
        } catch {
            Log.error("Failed to join match: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Get match state by ID
    /// - Parameter matchId: ID of the match
    /// - Returns: The match
    func getConnect4Match(matchId: UUID) async throws -> Connect4Match {
        Log.info("Fetching Connect 4 match: \(matchId)")
        
        do {
            let response: Connect4Match = try await client
                .from("connect4_matches")
                .select()
                .eq("id", value: matchId)
                .single()
                .execute()
                .value
            
            Log.info("Successfully fetched match: \(matchId)")
            return response
        } catch {
            Log.error("Failed to fetch match: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Get all moves for a match
    /// - Parameter matchId: ID of the match
    /// - Returns: Array of moves sorted by move number
    func getConnect4Moves(matchId: UUID) async throws -> [Connect4Move] {
        Log.info("Fetching moves for match: \(matchId)")
        
        do {
            let response: [Connect4Move] = try await client
                .from("connect4_moves")
                .select()
                .eq("match_id", value: matchId)
                .order("move_number", ascending: true)
                .execute()
                .value
            
            Log.info("Successfully fetched \(response.count) moves for match: \(matchId)")
            return response
        } catch {
            Log.error("Failed to fetch moves: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Submit a move to the match
    /// - Parameters:
    ///   - matchId: ID of the match
    ///   - deviceId: Device ID of the player making the move
    ///   - column: Column index (0-6)
    ///   - row: Row index (0-5)
    ///   - moveNumber: Sequential move number
    /// - Returns: The created move
    func submitConnect4Move(matchId: UUID, deviceId: String, column: Int, row: Int, moveNumber: Int) async throws -> Connect4Move {
        Log.info("Submitting move for match \(matchId): column=\(column), row=\(row), moveNumber=\(moveNumber)")
        
        struct MoveData: Codable {
            let match_id: UUID
            let player_device_id: String
            let column_index: Int
            let row_index: Int
            let move_number: Int
        }
        
        let moveData = MoveData(
            match_id: matchId,
            player_device_id: deviceId,
            column_index: column,
            row_index: row,
            move_number: moveNumber
        )
        
        do {
            let response: Connect4Move = try await client
                .from("connect4_moves")
                .insert(moveData)
                .select()
                .single()
                .execute()
                .value
            
            Log.info("Successfully submitted move: \(response.id)")
            return response
        } catch {
            Log.error("Failed to submit move: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Update match status
    /// - Parameters:
    ///   - matchId: ID of the match
    ///   - status: New status
    ///   - winnerDeviceId: Optional winner device ID
    ///   - currentTurnDeviceId: Optional current turn device ID
    /// - Returns: Updated match
    func updateConnect4MatchStatus(matchId: UUID, status: Connect4MatchStatus, winnerDeviceId: String? = nil, currentTurnDeviceId: String? = nil) async throws -> Connect4Match {
        Log.info("Updating match \(matchId) status to: \(status.rawValue)")
        
        struct UpdateData: Codable {
            let status: String
            let winner_device_id: String?
            let current_turn_device_id: String?
            let completed_at: String?
            let updated_at: String
        }
        
        let updateData = UpdateData(
            status: status.rawValue,
            winner_device_id: winnerDeviceId,
            current_turn_device_id: currentTurnDeviceId,
            completed_at: status == .completed ? ISO8601DateFormatter().string(from: Date()) : nil,
            updated_at: ISO8601DateFormatter().string(from: Date())
        )
        
        do {
            let response: Connect4Match = try await client
                .from("connect4_matches")
                .update(updateData)
                .eq("id", value: matchId)
                .select()
                .single()
                .execute()
                .value
            
            Log.info("Successfully updated match status: \(matchId)")
            return response
        } catch {
            Log.error("Failed to update match status: \(error.localizedDescription)")
            throw error
        }
    }
}
