//
//  FakeAllKontestsRepository.swift
//  Kontests
//
//  Created by Ayush Singhal on 13/08/23.
//

import Foundation

class FakeAllKontestsRepository: KontestFetcher {
    func getAllKontests() async throws -> [Kontest] {
        var kontests: [Kontest] = []

        let startTime = "2023-08-13 13:59:00 UTC"
        let endTime = "2023-08-13 16:30:00 UTC"

        let allKontests = [
            Kontest(name: "ProjectEuler+", url: "https://hackerrank.com/contests/projecteuler", start_time: "2014-07-07T15:38:00.000Z", end_time: "2024-07-30T18:30:00.000Z", duration: "317616720.0", site: "HackerRank", in_24_hours: "No", status: "No"),

            Kontest(name: "1v1 Games by CodeChef", url: "https://www.codechef.com/GAMES", start_time: "2022-10-10 06:30:00 UTC", end_time: "2032-10-10 06:30:00 UTC", duration: "315619200.0", site: "CodeChef", in_24_hours: "No", status: "CODING"),

            Kontest(name: "Weekly Contest 358", url: "https://leetcode.com/contest/weekly-contest-358", start_time: "2023-08-13T02:30:00.000Z", end_time: "2023-08-13T04:00:00.000Z", duration: "5400", site: "LeetCode", in_24_hours: "Yes", status: "BEFORE"),

            Kontest(name: "Starters 100 (Date to be decided)", url: "https://www.codechef.com/START100", start_time: "2023-08-30 14:30:00 UTC", end_time: "2023-08-30 16:30:00 UTC", duration: "7200", site: "CodeChef", in_24_hours: "No", status: "BEFORE"),

            Kontest(name: "Starters 100 (Date to be decided)", url: "https://www.codechef.com/START100", start_time: "2023-08-30 14:30:00 UTC", end_time: "2023-08-30 16:30:00 UTC", duration: "7200", site: "CodeChef", in_24_hours: "No", status: "CODING"),

            Kontest(name: "Test Contest", url: "https://leetcode.com/contest/weekly-contest-358", start_time: startTime, end_time: endTime, duration: "1800", site: "LeetCode", in_24_hours: "Yes", status: "BEFORE")
        ]

        kontests.append(contentsOf: allKontests)

        return kontests
    }
}
