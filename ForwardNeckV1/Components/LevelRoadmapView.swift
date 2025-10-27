//
//  LevelRoadmapView.swift
//  ForwardNeckV1
//
//  Animated roadmap showing progress to next level
//

import SwiftUI

struct LevelRoadmapView: View {
    let currentLevel: Level?
    let nextLevel: Level?
    let userProgress: UserProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Progress header
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                
                Text("Level \(currentLevel?.number ?? 1)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                if let _ = currentLevel, let _ = nextLevel {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black.opacity(0.1))
                                .frame(height: 6)
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black.opacity(0.3))
                                .frame(width: geometry.size.width * (progressToNextLevel ?? 0), height: 6)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progressToNextLevel)
                        }
                    }
                    .frame(width: 80, height: 6)
                    
                    Text("\(progressDays) / \(totalDays)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            
            // Roadmap nodes with 4 per row
            if let roadmap = generateRoadmap() {
                VStack(spacing: 16) {
                    // Split into rows of 4
                    ForEach(0..<(roadmap.count + 3) / 4, id: \.self) { row in
                        let startIndex = row * 4
                        let endIndex = min(startIndex + 4, roadmap.count)
                        let rowNodes = Array(roadmap[startIndex..<endIndex])
                        
                        GeometryReader { geometry in
                            let spacing = (geometry.size.width - (CGFloat(rowNodes.count) * 60)) / CGFloat(max(1, rowNodes.count - 1))
                            
                            HStack(spacing: 0) {
                                ForEach(rowNodes.indices, id: \.self) { col in
                                    HStack(spacing: 0) {
                                        roadmapNode(for: rowNodes[col])
                                        
                                        // Connecting line between nodes
                                        if col < rowNodes.count - 1 {
                                            Rectangle()
                                                .fill(Color.black.opacity(0.2))
                                                .frame(height: 1)
                                                .frame(width: spacing)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 100)
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Computed Properties
    
    private var progressToNextLevel: Double? {
        guard let currentLevel = currentLevel,
              let nextLevel = nextLevel else { return nil }
        
        let currentLevelXP = currentLevel.xpRequired
        let nextLevelXP = nextLevel.xpRequired
        let userXP = userProgress.xp
        
        let xpInCurrentLevel = userXP - currentLevelXP
        let xpNeeded = nextLevelXP - currentLevelXP
        
        return min(1.0, Double(xpInCurrentLevel) / Double(xpNeeded))
    }
    
    private var progressDays: Int {
        // Return 0 since we're now showing levels, not days
        return 0
    }
    
    private var totalDays: Int {
        // Return 8 to show current level + 7 next levels
        return 8
    }
    
    // MARK: - Roadmap Generation
    
    private func generateRoadmap() -> [RoadmapNode]? {
        // Show all 20 levels starting from level 1
        var nodes: [RoadmapNode] = []
        
        for i in 0..<20 {
            let levelNumber = i + 1
            let isCompleted = levelNumber <= userProgress.level
            let isCurrent = levelNumber == userProgress.level + 1
            
            nodes.append(RoadmapNode(
                day: levelNumber,
                xpRequired: 0, // Not used anymore
                isCompleted: isCompleted,
                isCurrent: isCurrent && !isCompleted
            ))
        }
        
        return nodes
    }
    
    // MARK: - Roadmap Node
    
    @ViewBuilder
    private func roadmapNode(for node: RoadmapNode) -> some View {
        VStack(spacing: 8) {
            // Show level image
            Image(levelImageName(for: node.day))
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .opacity(node.isCompleted ? 1.0 : 0.3)
                .grayscale(node.isCompleted ? 0 : 1)
            
            Text("Level \(node.day)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.black)
        }
    }
    
    // Helper function to get level image name
    private func levelImageName(for level: Int) -> String {
        let clampedLevel = max(1, min(level, 20))
        return "level\(clampedLevel)"
    }
}

// MARK: - Roadmap Node Model

struct RoadmapNode: Identifiable {
    let id = UUID()
    let day: Int
    let xpRequired: Int
    let isCompleted: Bool
    let isCurrent: Bool
}

#Preview {
    LevelRoadmapView(
        currentLevel: Level(
            id: 5,
            number: 5,
            xpRequired: 400,
            title: "Neck Warrior",
            description: "You've completed 5 levels",
            iconSystemName: "shield.fill",
            colorHex: "#FF6B6B"
        ),
        nextLevel: Level(
            id: 6,
            number: 6,
            xpRequired: 500,
            title: "Neck Master",
            description: "You're getting stronger",
            iconSystemName: "crown.fill",
            colorHex: "#FFD700"
        ),
        userProgress: UserProgress(xp: 450, level: 5)
    )
    .padding()
}
