-- Connect 4 Multiplayer Database Schema
-- Run this SQL in your Supabase SQL Editor to create the necessary tables

-- Create connect4_matches table
CREATE TABLE IF NOT EXISTS connect4_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player1_device_id TEXT NOT NULL,
    player2_device_id TEXT,
    status TEXT NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting', 'in_progress', 'completed', 'abandoned')),
    current_turn_device_id TEXT,
    winner_device_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Create connect4_moves table
CREATE TABLE IF NOT EXISTS connect4_moves (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID NOT NULL REFERENCES connect4_matches(id) ON DELETE CASCADE,
    player_device_id TEXT NOT NULL,
    column_index INTEGER NOT NULL CHECK (column_index >= 0 AND column_index <= 6),
    row_index INTEGER NOT NULL CHECK (row_index >= 0 AND row_index <= 5),
    move_number INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_connect4_matches_status ON connect4_matches(status);
CREATE INDEX IF NOT EXISTS idx_connect4_matches_player1 ON connect4_matches(player1_device_id);
CREATE INDEX IF NOT EXISTS idx_connect4_matches_player2 ON connect4_matches(player2_device_id);
CREATE INDEX IF NOT EXISTS idx_connect4_moves_match_id ON connect4_moves(match_id);
CREATE INDEX IF NOT EXISTS idx_connect4_moves_match_move ON connect4_moves(match_id, move_number);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_connect4_matches_updated_at BEFORE UPDATE ON connect4_matches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE connect4_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE connect4_moves ENABLE ROW LEVEL SECURITY;

-- RLS Policies for connect4_matches
-- Using simpler policies that work with anon key
-- Security is handled in the application layer

-- Drop any existing policies first
DROP POLICY IF EXISTS "Users can view their own matches" ON connect4_matches;
DROP POLICY IF EXISTS "Anyone can create matches" ON connect4_matches;
DROP POLICY IF EXISTS "Users can update their own matches" ON connect4_matches;
DROP POLICY IF EXISTS "Users can view moves from their matches" ON connect4_moves;
DROP POLICY IF EXISTS "Users can insert moves for their matches" ON connect4_moves;

-- Create simple policies that allow all operations for anon users
-- Note: Security is handled in the application layer by checking device IDs
CREATE POLICY "Allow all operations for anon users" ON connect4_matches 
    FOR ALL USING (true) WITH CHECK (true);
    
CREATE POLICY "Allow all operations for anon users" ON connect4_moves 
    FOR ALL USING (true) WITH CHECK (true);

