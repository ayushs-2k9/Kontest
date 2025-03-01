//
//  AllKontestsScreen.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/08/23.
//

import SwiftUI
import WidgetKit

struct AllKontestsScreen: View {
    @Environment(AllKontestsViewModel.self) private var allKontestsViewModel
    @Environment(NetworkMonitor.self) private var networkMonitor
    @State var showRemoveAllNotificationsAlert = false
    @State var showNotificationForAllKontestsAlert = false
    let isInDevelopmentMode = false
    @State private var isNoNotificationIconAnimating = false
    let notificationsViewModel = Dependencies.instance.notificationsViewModel

    let changeUsernameViewModel = Dependencies.instance.changeUsernameViewModel

    @Environment(ErrorState.self) private var errorState

    @Environment(Router.self) private var router

    let userDefaults = UserDefaults(suiteName: Constants.userDefaultsGroupID)
    @State private var text: String = ""

    var body: some View {
        NavigationStack(path: Bindable(router).path) {
            if networkMonitor.currentStatus == .satisfied {
                ZStack {
                    if allKontestsViewModel.isLoading {
                        ProgressView()
                    } else if allKontestsViewModel.allKontests.isEmpty { // No Kontests Downloaded
                        NoKontestsDownloadedScreen()
                    } else {
                        TimelineView(.periodic(from: .now, by: 1)) { timelineViewDefaultContext in
                            VStack {
                                List {
                                    RatingsView(codeForcesUsername: changeUsernameViewModel.codeForcesUsername, leetCodeUsername: changeUsernameViewModel.leetcodeUsername, codeChefUsername: changeUsernameViewModel.codeChefUsername)
                                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                        .listRowSeparator(.hidden)

                                    if allKontestsViewModel.backupKontests.isEmpty { // There are some kontests but they are hidden due to KontestFilters
                                        NoKontestsDueToFiltersScreen()
                                    } else {
                                        let ongoingKontests = allKontestsViewModel.ongoingKontests

                                        let laterTodayKontests = allKontestsViewModel.laterTodayKontests

                                        let tomorrowKontests = allKontestsViewModel.tomorrowKontests

                                        let laterKontests = allKontestsViewModel.laterKontests

                                        if allKontestsViewModel.toShowKontests.isEmpty && !allKontestsViewModel.searchText.isEmpty {
                                            Text("Please try some different search term")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        } else {
                                            if ongoingKontests.count > 0 {
                                                createSection(title: "Live Now", kontests: ongoingKontests, timelineViewDefaultContext: timelineViewDefaultContext)
                                            }

                                            if laterTodayKontests.count > 0 {
                                                createSection(title: "Later Today", kontests: laterTodayKontests, timelineViewDefaultContext: timelineViewDefaultContext)
                                            }

                                            if tomorrowKontests.count > 0 {
                                                createSection(title: "Tomorrow", kontests: tomorrowKontests, timelineViewDefaultContext: timelineViewDefaultContext)
                                            }

                                            if laterKontests.count > 0 {
                                                createSection(title: "Upcoming", kontests: laterKontests, timelineViewDefaultContext: timelineViewDefaultContext)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        #if os(macOS)
                        .searchable(text: Bindable(allKontestsViewModel).searchText)
                        #endif
                    }
                }
                .navigationTitle("Kontest")
                .onAppear {
                    LocalNotificationManager.instance.setBadgeCountTo0()
                }
                .toolbar {
                    if isInDevelopmentMode {
                        ToolbarItem(placement: .automatic) { // change the placement here!
                            Button {
                                router.appendScreen(screen: .PendingNotificationsScreen)
                            } label: {
                                Text("All Pending Notifications")
                            }
                        }

                        ToolbarItem(placement: .automatic) { // change the placement here!
                            Button {
                                notificationsViewModel.printAllPendingNotifications()
                            } label: {
                                Text("Print all notifs")
                            }
                        }

                        ToolbarItem(placement: .automatic) { // change the placement here!
                            Button {
                                LocalNotificationManager.instance.scheduleIntervalNotification()
                            } label: {
                                Text("Schedule 5 seconds Notification")
                            }
                        }

                        ToolbarItem(placement: .automatic) { // change the placement here!
                            Button {
                                WidgetCenter.shared.reloadAllTimelines()
                            } label: {
                                Text("Reload all widgets")
                            }
                        }

                        ToolbarItem(placement: .automatic) { // change the placement here!
                            Button {
                                allKontestsViewModel.errorWrapper = ErrorWrapper(error: AppError(title: "Fake Error Title", description: "Fake Error Description"), guidance: "Fake Error Guidance")
                            } label: {
                                Text("Invoke Error Wrapper")
                            }
                        }
                    }

                    if !allKontestsViewModel.allKontests.isEmpty || !allKontestsViewModel.searchText.isEmpty {
                        ToolbarItem(placement: .automatic) {
                            AllNotificationMenu()
                        }

                        ToolbarItem(placement: .automatic) { // change the placement here!
                            Button {
                                showRemoveAllNotificationsAlert = true
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    isNoNotificationIconAnimating = false
                                }
                            } label: {
                                Image(systemName: "bell.slash")
                                    .symbolEffect(.bounce.up.byLayer, value: isNoNotificationIconAnimating)
                            }
                            .help("Remove all Notification") // Tooltip text
                            .alert("Remove all Notification", isPresented: $showRemoveAllNotificationsAlert, actions: {
                                Button("Remove all", role: .destructive) {
                                    notificationsViewModel.removeAllPendingNotifications()
                                    isNoNotificationIconAnimating = true
                                }
                            })
                        }
                    }

                    ToolbarItem(placement: .automatic) {
                        Button {
                            router.appendScreen(screen: .SettingsScreen)
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .navigationDestination(for: SelectionState.self) { state in
                    switch state {
                    case .screen(let screen):
                        switch screen {
                        case .AllKontestScreen:
                            AllKontestsScreen()

                        case Screen.SettingsScreen:
                            SettingsScreen()

                        case .PendingNotificationsScreen:
                            PendingNotificationsScreen()

                        case .SettingsScreenType(let settingsScreenType):
                            switch settingsScreenType {
                            case .ChangeUserNamesScreen:
                                ChangeUsernameScreen()

                            case .FilterWebsitesScreen:
                                FilterWebsitesScreen()
                            }
                        }

                    case .kontestModel(let kontest):
                        KontestDetailsScreen(kontest: kontest)
                    }
                }
            } else {
                NoInternetScreen()
            }
        }
        .onAppear {
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onChange(of: networkMonitor.currentStatus) {
            if networkMonitor.currentStatus == .satisfied {
                allKontestsViewModel.fetchAllKontests()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .onChange(of: allKontestsViewModel.errorWrapper) { _, newValue in
            if let newValue {
                errorState.errorWrapper = newValue
            }
        }
        #if !os(macOS)
        .searchable(text: Bindable(allKontestsViewModel).searchText)
        #endif
    }

    func createSection(title: String, kontests: [KontestModel], timelineViewDefaultContext: TimelineViewDefaultContext) -> some View {
        Section {
            ForEach(kontests) { kontest in
                #if os(macOS)
                Link(destination: URL(string: kontest.url)!, label: {
                    kontestView(kontest: kontest, timelineViewDefaultContext: timelineViewDefaultContext)

                })
                #else
                NavigationLink(value: SelectionState.kontestModel(kontest)) {
                    kontestView(kontest: kontest, timelineViewDefaultContext: timelineViewDefaultContext)
                }
                #endif
            }
        } header: {
            Text(title)
        }
    }
}

#Preview {
    let networkMonitor = NetworkMonitor.shared

    return AllKontestsScreen()
        .environment(networkMonitor)
        .environment(Dependencies.instance.allKontestsViewModel)
        .environment(Router.instance)
}

extension AllKontestsScreen {
    func calendarSwipeButtonAction(kontest: KontestModel) {
        let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
        let kontestEndDate = CalendarUtility.getDate(date: kontest.end_time)
        print("Setted")

        if let kontestStartDate {
            if kontest.isCalendarEventAdded {
                Task {
                    do {
                        try await CalendarUtility.removeEvent(startDate: kontestStartDate, endDate: kontestEndDate ?? Date(), title: kontest.name, notes: "", url: URL(string: kontest.url))

                        kontest.isCalendarEventAdded = false
                        kontest.calendarEventDate = nil
                    } catch {
                        errorState.errorWrapper = ErrorWrapper(error: error, guidance: "Check that you have given Kontest the Calendar Permission (Full Access)")
                    }

                    WidgetCenter.shared.reloadAllTimelines()
                }
            } else {
                Task {
                    do {
                        if kontest.isCalendarEventAdded { // If one event was already setted, then remove it and set a new event
                            try await CalendarUtility.removeEvent(startDate: kontestStartDate, endDate: kontestEndDate ?? Date(), title: kontest.name, notes: "", url: URL(string: kontest.url))
                        }

                        if try await CalendarUtility.addEvent(startDate: kontestStartDate, endDate: kontestEndDate ?? Date(), title: kontest.name, notes: "", url: URL(string: kontest.url), alarmAbsoluteDate: kontestStartDate.addingTimeInterval(-15 * 60)) {
                            kontest.isCalendarEventAdded = true
                            kontest.calendarEventDate = kontestStartDate.addingTimeInterval(-15 * 60)
                        }
                    } catch {
                        errorState.errorWrapper = ErrorWrapper(error: error, guidance: "")
                    }

                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }
}

extension AllKontestsScreen {
    @ViewBuilder
    func kontestView(kontest: KontestModel, timelineViewDefaultContext: TimelineViewDefaultContext) -> some View {
        let kontestStartDate = CalendarUtility.getDate(date: kontest.start_time)
        let kontestEndDate = CalendarUtility.getDate(date: kontest.end_time)

        if let kontestStartDate, let kontestEndDate, !CalendarUtility.isKontestRunning(kontestStartDate: kontestStartDate, kontestEndDate: kontestEndDate) {
            SingleKontestView(kontest: kontest, timelineViewDefaultContext: timelineViewDefaultContext)
                .swipeActions(edge: .leading) {
                    Button("", systemImage: kontest.isCalendarEventAdded ? "calendar.badge.minus" : "calendar.badge.plus") {
                        calendarSwipeButtonAction(kontest: kontest)
                    }
                    .tint(Color(red: 94/255, green: 92/255, blue: 222/255))
                }
        } else {
            SingleKontestView(kontest: kontest, timelineViewDefaultContext: timelineViewDefaultContext)
        }
    }
}
