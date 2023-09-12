//
//  Upcoming_Kontests_macOS_Widget.swift
//  Upcoming Kontests macOS Widget
//
//  Created by Ayush Singhal on 12/09/23.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    let kontestModel = KontestModel.from(dto: KontestDTO(name: "ProjectEuler+1", url: "https://hackerrank.com/contests/projecteuler", start_time: "2023-08-15 18:29:00 UTC", end_time: "2023-08-18 17:43:00 UTC", duration: "1020.0", site: "HackerRank", in_24_hours: "No", status: "BEFORE"))

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), error: nil, ongoingKontests: [kontestModel], laterTodayKontests: [kontestModel], tomorrowKontests: [kontestModel], laterKontests: [kontestModel])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let kontestsDividedInCategories = await GetKontests.getKontestsDividedIncategories()

            let entry = SimpleEntry(date: Date(), error: kontestsDividedInCategories.error, ongoingKontests: kontestsDividedInCategories.ongoingKontests, laterTodayKontests: kontestsDividedInCategories.laterTodayKontests, tomorrowKontests: kontestsDividedInCategories.tomorrowKontests, laterKontests: kontestsDividedInCategories.laterKontests)

            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let kontestsDividedInCategories = await GetKontests.getKontestsDividedIncategories()

            let nextDateToRefresh = CalendarUtility.getNextDateToRefresh(ongoingKontests: kontestsDividedInCategories.ongoingKontests, laterTodayKontests: kontestsDividedInCategories.laterTodayKontests, tomorrowKontests: kontestsDividedInCategories.tomorrowKontests, laterKontests: kontestsDividedInCategories.laterKontests)

            var myEntries: [SimpleEntry] = []

            let entry = SimpleEntry(date: Date(), error: kontestsDividedInCategories.error, ongoingKontests: kontestsDividedInCategories.ongoingKontests, laterTodayKontests: kontestsDividedInCategories.laterTodayKontests, tomorrowKontests: kontestsDividedInCategories.tomorrowKontests, laterKontests: kontestsDividedInCategories.laterKontests)

            myEntries.append(entry)

            let timeline = Timeline(entries: myEntries, policy: .after(nextDateToRefresh))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let error: Error?
    let ongoingKontests: [KontestModel]
    let laterTodayKontests: [KontestModel]
    let tomorrowKontests: [KontestModel]
    let laterKontests: [KontestModel]
}

struct Upcoming_Kontests_macOS_WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            if let error = entry.error {
                Text("Error: \(error.localizedDescription)")
            } else {
                if entry.ongoingKontests.isEmpty && entry.laterTodayKontests.isEmpty && entry.tomorrowKontests.isEmpty && entry.laterKontests.isEmpty {
                    Text("No Kontests Scheduled")
                } else {
                    if !entry.ongoingKontests.isEmpty {
                        CreateSectionView(title: "On Going Kontests", kontests: entry.ongoingKontests, toShowDate: false, toShowTime: false)
                    }

                    if !entry.laterTodayKontests.isEmpty {
                        CreateSectionView(title: "Later Today Kontests", kontests: entry.laterTodayKontests, toShowDate: false, toShowTime: true)
                    }

                    if !entry.tomorrowKontests.isEmpty {
                        CreateSectionView(title: "Tomorrow Kontests", kontests: entry.tomorrowKontests, toShowDate: false, toShowTime: true)
                    }

                    if !entry.laterKontests.isEmpty {
                        CreateSectionView(title: "Later Kontests", kontests: entry.laterKontests, toShowDate: true, toShowTime: false)
                    }
                }
            }
        }
    }
}

struct Upcoming_Kontests_macOS_Widget: Widget {
    let kind: String = "Upcoming_Kontests_macOS_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(macOS 14.0, *) {
                Upcoming_Kontests_macOS_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                Upcoming_Kontests_macOS_WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemLarge, .systemExtraLarge])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
