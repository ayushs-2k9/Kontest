//
//  CodeForcesView.swift
//  Kontest
//
//  Created by Ayush Singhal on 16/08/23.
//

import SwiftUI

struct CodeForcesView: View {
    let username: String
    let codeForcesViewModel: CodeForcesViewModel
    let bgGradient: RadialGradient 
    @State var isHovering = false
    let hoveringScaleValue: CGFloat

    init(username: String, bgGradient: RadialGradient, hoveringScaleValue: CGFloat) {
        self.username = username
        self.codeForcesViewModel = CodeForcesViewModel(username: username)
        self.bgGradient = bgGradient
        self.hoveringScaleValue = hoveringScaleValue
    }

    var body: some View {
        CodeForcesProfileView(codeForcesViewModel: codeForcesViewModel, username: username, bgGradient: bgGradient, isLoading: codeForcesViewModel.isLoading, error: codeForcesViewModel.error)
            .onHover(perform: { hovering in
                withAnimation {
                    isHovering = hovering
                }
            })
            .scaleEffect(isHovering && !codeForcesViewModel.isLoading && codeForcesViewModel.error == nil ? hoveringScaleValue : 1)
    }
}

struct CodeForcesProfileView: View {
    let codeForcesViewModel: CodeForcesViewModel
    let username: String
    let bgGradient: RadialGradient
    let isLoading: Bool
    let error: Error?

    init(codeForcesViewModel: CodeForcesViewModel, username: String, bgGradient: RadialGradient, isLoading: Bool, error: Error?) {
        self.codeForcesViewModel = codeForcesViewModel
        self.username = username
        self.bgGradient = bgGradient
        self.isLoading = isLoading
        self.error = error
    }

    @Environment(\.openURL) private var openURL
    @Environment(Router.self) private var router

    var body: some View {
        ZStack {
           bgGradient

            if isLoading && error == nil {
                ProgressView()
            }
            else {
                HStack {
                    Image(.codeForcesLogo)
                        .resizable()
                        .frame(width: 25, height: 25)

                    Text("CodeForces")
                }
                .font(FontUtility.getCardCornerSideFont())
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                Text(username)
                    .bold()
                    .font(FontUtility.getCardCornerSideFont())
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

                if let codeForcesRatings = codeForcesViewModel.codeForcesRatings {
                    if codeForcesRatings.result.isEmpty {
                        Text("LastRank 0")
                            .font(FontUtility.getCardCornerSideFont())
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                        Text("U N R A T E D")
                            .fontDesign(.monospaced)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    else {
                        let latestCodeForcesRatings = codeForcesRatings.result[codeForcesRatings.result.count - 1]

                        let latestCodeForcesuserInfo = codeForcesViewModel.codeForcesUserInfos?.result.first

                        if let latestCodeForcesuserInfo {
                            Text("Max Rating: \(latestCodeForcesuserInfo.maxRating)")
                                .font(FontUtility.getCardCornerSideFont())
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        }

                        let rating = codeForcesViewModel.getRatingsTitle()
                        VStack(spacing: 0) {
                            Text(rating.title)
                                .fontDesign(.monospaced)
                                .bold()

                            Text("with a current rating of \(latestCodeForcesRatings.newRating) [\((latestCodeForcesRatings.newRating - latestCodeForcesRatings.oldRating) >= 0 ? "+" : "")\(latestCodeForcesRatings.newRating - latestCodeForcesRatings.oldRating)]")
                                .font(.caption)
                        }
                        .foregroundStyle(rating.color)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                        Text("LastRank \(latestCodeForcesRatings.rank)")
                            .font(FontUtility.getCardCornerSideFont())
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    }
                }
                else {
                    Text("LastRank 0")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                    VStack {
                        Text("INVALID USERNAME")
                            .fontDesign(.monospaced)
                            .bold()

                        Text("please update your username in the settings")
                            .font(.caption)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .onTapGesture {
            if !isLoading {
                if codeForcesViewModel.codeForcesRatings != nil {
                    guard let url = URL(string: "https://codeforces.com/profile/\(username)") else { return }
                    openURL(url)
                }
                else {
                    router.appendScreen(screen: .SettingsScreenType(.ChangeUserNamesScreen))
                }
            }
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.black)
    }
}

#Preview {
    let bgGradient: RadialGradient = .init(gradient: Gradient(stops: [.init(color: Color(red: 159/255, green: 150/255, blue: 137/255), location: 0.0), .init(color: Color(red: 209/255, green: 204/255, blue: 198/255), location: 0.5)]), center: .center, startRadius: 10, endRadius: 500)

    return VStack {
        CodeForcesView(username: "Fefer_Ivan", bgGradient: bgGradient, hoveringScaleValue: 1.05)
        CodeForcesView(username: "ayushsinghals", bgGradient: bgGradient, hoveringScaleValue: 1.05)
        CodeForcesView(username: "ayushsinghals02", bgGradient: bgGradient, hoveringScaleValue: 1.05)
        CodeForcesView(username: "yermak0v", bgGradient: bgGradient, hoveringScaleValue: 1.05)
    }
    .environment(Router.instance)
}
