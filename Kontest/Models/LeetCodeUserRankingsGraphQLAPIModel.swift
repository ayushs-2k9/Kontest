//
//  LeetCodeUserRankingsGraphQLAPIModel.swift
//  Kontest
//
//  Created by Ayush Singhal on 04/09/23.
//

import Foundation

// MARK: - LeetCodeUserRankingsGraphQLAPIModel

struct LeetCodeUserRankingsGraphQLAPIModel: Codable {
    let leetCodeUserRankingGraphQLAPIModel: LeetCodeUserRankingGraphQLAPIModel?
    let leetCodeUserRankingHistoryGraphQLAPIModel: [LeetCodeUserRankingHistoryGraphQLAPIModel?]?
}

struct LeetCodeUserRankingGraphQLAPIModel: Codable {
    let attendedContestsCount: Int?
    let rating: Double?
    let globalRanking: Int?
    let totalParticipants: Int?
    let topPercentage: Double?
    let badge: BadgeModel?
}

struct BadgeModel: Codable {
    let name: String?
}

struct LeetCodeUserRankingHistoryGraphQLAPIModel: Codable {
    let attended: Bool?
    let trendDirection: String?
    let problemsSolved: Int?
    let totalProblems: Int?
    let finishTimeInSeconds: Int?
    let rating: Double?
    let ranking: Int?
    let contest: ContestModel?
}

struct ContestModel: Codable {
    let title: String?
    let startTime: String?
}

extension LeetCodeUserRankingsGraphQLAPIModel {
    static func from(leetCodeUserRankingsGraphQLAPIDTO: LeetCodeUserRankingsGraphQLAPIDTO?) -> LeetCodeUserRankingsGraphQLAPIModel? {
        guard let leetCodeUserRankingsGraphQLAPIDTO else { return nil }

        return LeetCodeUserRankingsGraphQLAPIModel(
            leetCodeUserRankingGraphQLAPIModel: LeetCodeUserRankingGraphQLAPIModel.from(leetCodeUserRankingGraphQLAPIDTO: leetCodeUserRankingsGraphQLAPIDTO.leetCodeUserRankingGraphQLAPIDTO),

            leetCodeUserRankingHistoryGraphQLAPIModel: LeetCodeUserRankingHistoryGraphQLAPIModel.from(leetCodeUserRankingHistoryGraphQLAPIDTOs: leetCodeUserRankingsGraphQLAPIDTO.leetCodeUserRankingHistoryGraphQLAPIDTO))
    }
}

extension BadgeModel {
    static func from(badgeDTO: BadgeDTO?) -> BadgeModel? {
        guard let badgeDTO else { return nil }

        return BadgeModel(name: badgeDTO.name)
    }
}

extension LeetCodeUserRankingGraphQLAPIModel {
    static func from(leetCodeUserRankingGraphQLAPIDTO: LeetCodeUserRankingGraphQLAPIDTO?) -> LeetCodeUserRankingGraphQLAPIModel? {
        guard let leetCodeUserRankingGraphQLAPIDTO else { return nil }

        return LeetCodeUserRankingGraphQLAPIModel(attendedContestsCount: leetCodeUserRankingGraphQLAPIDTO.attendedContestsCount, rating: leetCodeUserRankingGraphQLAPIDTO.rating, globalRanking: leetCodeUserRankingGraphQLAPIDTO.globalRanking, totalParticipants: leetCodeUserRankingGraphQLAPIDTO.totalParticipants, topPercentage: leetCodeUserRankingGraphQLAPIDTO.topPercentage, badge: BadgeModel.from(badgeDTO: leetCodeUserRankingGraphQLAPIDTO.badge))
    }
}

extension ContestModel {
    static func from(contestDTO: ContestDTO?) -> ContestModel? {
        guard let contestDTO else { return nil }

        return ContestModel(title: contestDTO.title, startTime: contestDTO.startTime)
    }
}

extension LeetCodeUserRankingHistoryGraphQLAPIModel {
    static func from(leetCodeUserRankingHistoryGraphQLAPIDTO: LeetCodeUserRankingHistoryGraphQLAPIDTO?) -> LeetCodeUserRankingHistoryGraphQLAPIModel? {
        guard let leetCodeUserRankingHistoryGraphQLAPIDTO else { return nil }

        return LeetCodeUserRankingHistoryGraphQLAPIModel(attended: leetCodeUserRankingHistoryGraphQLAPIDTO.attended, trendDirection: leetCodeUserRankingHistoryGraphQLAPIDTO.trendDirection, problemsSolved: leetCodeUserRankingHistoryGraphQLAPIDTO.problemsSolved, totalProblems: leetCodeUserRankingHistoryGraphQLAPIDTO.totalProblems, finishTimeInSeconds: leetCodeUserRankingHistoryGraphQLAPIDTO.finishTimeInSeconds, rating: leetCodeUserRankingHistoryGraphQLAPIDTO.rating, ranking: leetCodeUserRankingHistoryGraphQLAPIDTO.ranking, contest: ContestModel.from(contestDTO: leetCodeUserRankingHistoryGraphQLAPIDTO.contest))
    }

    static func from(leetCodeUserRankingHistoryGraphQLAPIDTOs: [LeetCodeUserRankingHistoryGraphQLAPIDTO?]?) -> [LeetCodeUserRankingHistoryGraphQLAPIModel?]? {
        guard let leetCodeUserRankingHistoryGraphQLAPIDTOs else { return nil }

        return leetCodeUserRankingHistoryGraphQLAPIDTOs.map { leetCodeUserRankingHistoryGraphQLAPIDTO in
            from(leetCodeUserRankingHistoryGraphQLAPIDTO: leetCodeUserRankingHistoryGraphQLAPIDTO)
        }
    }
}
