//
//  AllKontestsScreen.swift
//  Kontest
//
//  Created by Ayush Singhal on 12/08/23.
//

import SwiftUI

struct AllKontestsScreen: View {
    @Environment(AllKontestsViewModel.self) private var allKontestsViewModel
    @State var showRemoveAllNotificationsAlert = false
    @State var showNotificationForAllKontestsAlert = false
    let isInDevelopmentMode = false
    @State private var isNoNotificationIconAnimating = false

    let settingsViewModel = SettingsViewModel.instance

    @Environment(Router.self) private var router

    var body: some View {
        NavigationStack(path: Bindable(router).path) {
            ZStack {
                if allKontestsViewModel.isLoading {
                    ProgressView()
                } else if allKontestsViewModel.backupKontests.isEmpty {
                    NoKontestsScreen()
                } else {
                    TimelineView(.periodic(from: .now, by: 1)) { timelineViewDefaultContext in
                        VStack {
                            List {
                                RatingsView(codeForcesUsername: settingsViewModel.codeForcesUsername, leetCodeUsername: settingsViewModel.leetcodeUsername, codeChefUsername: settingsViewModel.codeChefUsername)
                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .listRowSeparator(.hidden)
                                
                                let ongoingKontests = allKontestsViewModel.ongoingKontests

                                let laterTodayKontests = allKontestsViewModel.laterTodayKontests

                                let tomorrowKontests = allKontestsViewModel.tomorrowKontests

                                let laterKontests = allKontestsViewModel.laterKontests

                                if allKontestsViewModel.allKontests.isEmpty && !allKontestsViewModel.searchText.isEmpty {
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
                            allKontestsViewModel.printAllPendingNotifications()
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
                }

                if !allKontestsViewModel.allKontests.isEmpty || !allKontestsViewModel.searchText.isEmpty {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            router.appendScreen(screen: .SettingsScreen)
                        } label: {
                            Image(systemName: "gear")
                        }
                    }

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
                                allKontestsViewModel.removeAllPendingNotifications()
                                isNoNotificationIconAnimating = true
                            }
                        })
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
                    }

                case .kontestModel(let kontest):
                    KontestDetailsScreen(kontest: kontest)
                }
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
                    SingleKontestView(kontest: kontest, timelineViewDefaultContext: timelineViewDefaultContext)
                })
                #else
                NavigationLink(value: SelectionState.kontestModel(kontest)) {
                    SingleKontestView(kontest: kontest, timelineViewDefaultContext: timelineViewDefaultContext)
                }
                #endif
            }
        } header: {
            Text(title)
        }
    }
}

#Preview {
    AllKontestsScreen()
        .environment(AllKontestsViewModel())
        .environment(Router.instance)
}
