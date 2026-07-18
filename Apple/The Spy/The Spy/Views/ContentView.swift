//
//  ContentView.swift
//  The Spy
//
//  Created by Julian Schumacher on 08.05.24.
//

import SwiftUI
import SwiftData
import GameKit

internal struct ContentView: View {
    
    @Query private var configs : [Configuration]
    
    @Environment(\.modelContext) private var modelContext
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var gameRunning : Bool = false
    
    @State private var rolesShowing : Bool = false
    
    @State private var numberPlayer : Int = 3

    @State private var numberSpies : Int = 1

    @State private var configSheetShown : Bool = false
    
    private var viewController : UIViewController?
    
    @State private var players : [Player] = []
    
    var body: some View {
        NavigationSplitView {
            if gameRunning {
                GameView(gameRunning: $gameRunning)
                    .onAppear {
                        rolesShowing = false
                        numberSpies = 1
                        numberPlayer = 3
                    }
            } else if rolesShowing {
                RoleViewer(
                    numberPlayer: numberPlayer,
                    numberSpies: numberSpies,
                    gameRunning: $gameRunning,
                    players: $players
                )
            } else {
                VStack {
                    Button {
                        configSheetShown.toggle()
                    } label: {
                        Text("New Game")
                            .foregroundStyle(.white)
                            .frame(width: 210, height: 70)
                            .backgroundStyle(.clear)
                            .glass(.clear, in: .rect(cornerRadius: 20))
                    }
                    NavigationLink {
                        CategoryViewer()
                    } label: {
                        Text("Words")
                            .foregroundStyle(.white)
                            .frame(width: 210, height: 70)
                            .backgroundStyle(.clear)
                            .glass(.clear, in: .rect(cornerRadius: 20))
                    }
                    .padding(.vertical, 10)
                    NavigationLink {
                        ConfigView()
                    } label: {
                        Text("Select Categories")
                            .foregroundStyle(.white)
                            .frame(width: 210, height: 70)
                            .backgroundStyle(.clear)
                            .glass(.clear, in: .rect(cornerRadius: 20))
                    }
                }
                .background {
                    Image("SpyBackground")
                        .renderingMode(.original)
                        .blur(radius: 10, opaque: true)
                }
                .navigationTitle("Welcome")
                .toolbarColorScheme(.dark, for: .navigationBar)
#if !os(macOS)
                .navigationBarTitleDisplayMode(.automatic)
#endif
                .sheet(isPresented: $configSheetShown) {
                    ConfigSheet(
                        numberPlayer: $numberPlayer,
                        numberSpies: $numberSpies,
                        rolesShowing: $rolesShowing,
                        players: $players
                    )
                }
                .textFieldStyle(.automatic)
                .textCase(.none)
                .keyboardType(.numberPad)
            }
        } detail: {
            Text("Nothing to see here yet...")
        }
        .onAppear {
            if configs.isEmpty {
                let config = Configuration()
                modelContext.insert(config)
            } else if configs.count > 1 {
                print("More than one config model")
            }
            authenticateUser()
        }
        .onChange(of: gameRunning) {
            guard !gameRunning else { return }
            GKAchievement.loadAchievements {
                achievements, error in
                let firstGameID = "first_game"
                guard !(achievements?.contains(where: { $0.identifier == firstGameID }) ?? true) else { return }
                let achievement = GKAchievement(identifier: firstGameID)
                achievement.percentComplete = 100
                let achievementsToReport : [GKAchievement] = [achievement]
                GKAchievement.report(achievementsToReport)
            }
        }
    }
    
    //https://www.asushil.com.np/setting-up-game-center-authentication-in-swiftui-a-comprehensive-guide/
    /// Authenticates the User in the Game Center
    private func authenticateUser() -> Void {
        GKLocalPlayer.local.authenticateHandler = {
            vc, error  in
            guard !GKLocalPlayer.local.isAuthenticated else { return }
            if let view = vc {
                viewController?.present(view, animated: true)
            }
            if let e = error {
                print(e)
            }
        }
    }
}



#Preview {
    ContentView()
        .modelContainer(previewModelContainer)
}

private var previewModelContainer: ModelContainer = {
    let schema = Schema([
        Configuration.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
