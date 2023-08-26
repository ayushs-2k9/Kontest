//
//  SingleKontestView.swift
//  Kontest
//
//  Created by Ayush Singhal on 14/08/23.
//

import Combine
import SwiftUI

struct SingleKontestView: View {
    let kontest: KontestModel
    @Environment(AllKontestsViewModel.self) private var allKontestsViewModel

    @Environment(\.colorScheme) private var colorScheme

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let kontestStartDate: Date?
    let kontestEndDate: Date?

    @State var remainingTime: String = "--:--:--"

    init(kontest: KontestModel) {
        self.kontest = kontest
        kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
        kontestEndDate = CalendarUtility.getDate(date: kontest.end_time)
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack {
                #if os(macOS)
                Image(KontestModel.getLogo(site: kontest.site))
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: FontUtility.getLogoSize())
                #endif

                let isContestRunning = CalendarUtility.isKontestRunning(kontestStartDate: kontestStartDate ?? Date(), kontestEndDate: kontestEndDate ?? Date()) || kontest.status == .Running

                if isContestRunning {
                    BlinkingDotView(color: .green)
                        .frame(width: 10, height: 10)
                }
                else {
                    #if os(macOS)
                    EmptyView()
                    #else
                    BlinkingDotView(color: .clear)
                        .frame(width: 10, height: 10)
                    #endif
                }
            }
            .foregroundStyle(colorScheme == .light ? .black : .white)

            VStack(alignment: .leading) {
                Text(kontest.site.uppercased())
                    .foregroundStyle(KontestModel.getColorForIdentifier(site: kontest.site))
                    .bold()
                    .font(FontUtility.getSiteFontSize())

                Text(kontest.name)
                    .font(FontUtility.getNameFontSize())
                #if os(iOS)
                    .padding(.top, 1)
                    .lineLimit(1)
                #else
                    .multilineTextAlignment(.leading)
                #endif
            }
            .foregroundStyle(colorScheme == .light ? .black : .white)

            #if !os(iOS)
            Button {
                ClipboardUtility.copyToClipBoard(kontest.url)
            } label: {
                Image(systemName: "link")
            }
            .help("Copy link")
            #endif

            #if os(macOS)
            if CalendarUtility.isKontestOfFuture(kontestStartDate: kontestStartDate ?? Date()), numberOfOptions(kontest: kontest) > 0 {
                SingleNotificationMenu(kontest: kontest)
                    .frame(width: 45)
            }
            #endif

            Spacer()

            VStack {
                if kontestStartDate != nil && kontestEndDate != nil {
                    Text("\(kontestStartDate!.formatted(date: .omitted, time: .shortened)) - \(kontestEndDate!.formatted(date: .omitted, time: .shortened))")
                        .foregroundStyle(KontestModel.getColorForIdentifier(site: kontest.site))
                        .font(FontUtility.getTimeFontSize())
                        .bold()

                    if CalendarUtility.isKontestOfFuture(kontestStartDate: kontestStartDate ?? Date()) && kontestStartDate ?? Date() < CalendarUtility.getTomorrow() {
                        Text(remainingTime)
                            .font(FontUtility.getRemainingTimeFontSize())
                            .onReceive(timer) { time in
                                let p = kontestStartDate!.timeIntervalSince(time)
                                remainingTime = CalendarUtility.formattedTimeFrom(seconds: Int(p))
                                print("remainingTime: \(remainingTime)")
                            }
                            .padding(.top, 5)
                    }

                    HStack {
                        Image(systemName: "clock")

                        Text(CalendarUtility.getFormattedDuration(fromSeconds: kontest.duration) ?? "")
                    }
                    .font(FontUtility.getDateFontSize())
                    .padding(.bottom, 5)

                    Text("\(CalendarUtility.getNumericKontestDate(date: kontestStartDate ?? Date())) - \(CalendarUtility.getNumericKontestDate(date: kontestEndDate ?? Date()))")
                        .font(FontUtility.getDateFontSize())
                }
                else {
                    Text("No date provided")
                }
            }
            .foregroundStyle(colorScheme == .light ? .black : .white)
            .font(.footnote)

            #if os(macOS)
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
            #endif
        }
        #if os(macOS)
        .padding()
        #endif
    }
}

private func numberOfOptions(kontest: KontestModel) -> Int {
    var ans = 0
    let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
    if kontestStartDate == nil {
        return 4
    }

    if CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 10, hours: 0, days: 0) {
        ans += 1
    }

    if CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 30, hours: 0, days: 0) {
        ans += 1
    }

    if CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 0, hours: 1, days: 0) {
        ans += 1
    }

    if CalendarUtility.isRemainingTimeGreaterThanGivenTime(date: kontestStartDate, minutes: 0, hours: 6, days: 0) {
        ans += 1
    }

    return ans
}

#Preview("SingleKontentView") {
    let allKontestsViewModel = AllKontestsViewModel()

    return List {
        SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "ProjectEuler+", url: "https://hackerrank.com/contests/projecteuler", start_time: "2014-07-07T15:38:00.000Z", end_time: "2024-07-30T18:30:00.000Z", duration: "317616720.0", site: "HackerRank", in_24_hours: "No", status: "BEFORE")))

        SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "1v1 Games by CodeChef", url: "https://www.codechef.com/GAMES", start_time: "2023-11-10 06:30:00 UTC", end_time: "2032-11-10 06:30:00 UTC", duration: "315619200.0", site: "CodeChef", in_24_hours: "No", status: "CODING")))

        SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "Weekly Contest 358", url: "https://leetcode.com/contest/weekly-contest-358", start_time: "2023-08-25T02:30:00.000Z", end_time: "2023-08-25T04:00:00.000Z", duration: "5400", site: "LeetCode", in_24_hours: "Yes", status: "BEFORE")))

        SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "Test Contest", url: "https://leetcode.com/contest/weekly-contest-358", start_time: "2023-08-13T02:30:00.000Z", end_time: "2023-08-13T05:00:00.000Z", duration: "1800", site: "LeetCode", in_24_hours: "Yes", status: "BEFORE")))
        SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "Starters 100 (Date to be decided)", url: "https://www.codechef.com/START100", start_time: "2023-08-30 14:30:00 UTC", end_time: "2023-08-30 16:30:00 UTC", duration: "7200", site: "CodeChef", in_24_hours: "No", status: "BEFORE")))
    }
    .environment(allKontestsViewModel)

//    return SingleKontestView(kontest: KontestModel.from(dto: KontestDTO(name: "1v1 Games by CodeChef", url: "https://www.codechef.com/GAMES", start_time: "2023-11-10 06:30:00 UTC", end_time: "2032-11-10 06:30:00 UTC", duration: "315619200.0", site: "CodeChef", in_24_hours: "No", status: "CODING")))
//        .environment(allKontestsViewModel)
}
