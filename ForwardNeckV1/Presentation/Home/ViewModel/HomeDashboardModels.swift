//
//  HomeDashboardModels.swift
//  NeckRotV1
//
//  Shared data models used by the home dashboard.
//

import Foundation

struct NeckFixDaySummary: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let label: String
    let count: Int
}

struct PreviousDaySummary: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let label: String
    let completionCount: Int
    let goal: Int
    let percentage: Int
    let mascotAssetName: String

    var percentageText: String { "\(percentage)%" }
}
