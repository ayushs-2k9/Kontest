//
//  Dependencies.swift
//  Kontest
//
//  Created by Ayush Singhal on 18/09/23.
//

import Foundation



class Dependencies {
    let notificationsViewModel: NotificationsViewModel
    let filterWebsitesViewModel: FilterWebsitesViewModel
    let allKontestsViewModel: AllKontestsViewModel
    let changeUsernameViewModel: ChangeUsernameViewModel

    static let instance = Dependencies()

    private init() {
        self.notificationsViewModel = NotificationsViewModel()
        self.filterWebsitesViewModel = FilterWebsitesViewModel()
        self.allKontestsViewModel = AllKontestsViewModel(notificationsViewModel: notificationsViewModel, filterWebsitesViewModel: filterWebsitesViewModel, repository: KontestRepository())
        self.changeUsernameViewModel = ChangeUsernameViewModel()
    }
}
