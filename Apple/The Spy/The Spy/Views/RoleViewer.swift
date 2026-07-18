//
//  RoleViewer.swift
//  The Spy
//
//  Created by Julian Schumacher on 08.05.24.
//

import SwiftUI
import SwiftData

/// View to display the roles of the players
internal struct RoleViewer: View {
    
    @Query private var configs : [Configuration]
    
    private var gameRunning : Binding<Bool>
    
    @Environment(\.dismiss) private var dismiss
    
    internal init(numberPlayer : Int, numberSpies : Int, gameRunning : Binding<Bool>, players : Binding<[Player]>) {
        self.gameRunning = gameRunning
        self.numberPlayer = numberPlayer
        self.numberSpies = numberSpies
        word = "Loaded Word"
        spyNumbers = []
        self._players = players
    }
    
    @State private var hidden : Bool = true
    
    private let numberPlayer : Int
    
    private let numberSpies : Int
    
    @State private var word : String
    
    @State private var counter : Int = 0

    @State private var spyNumbers : [Int]
    
    @State private var textToShow : String = ""
    
    @State private var loadingErrorPresented : Bool = false
    
    @Binding internal var players : [Player]
    
    var body: some View {
        Button {
            btnTap()
        } label: {
            VStack {
                if (hidden) {
                    Spacer()
                }
                if !(counter >= numberPlayer) {
                    Text("\(players[counter].name)")
                        .font(.largeTitle)
                        .padding(.all, 20)
                } else {
                    EmptyView().padding(.all, 20)
                }
                if (!hidden) {
                    Spacer()
                }
                Group {
                    if counter >= numberPlayer {
                        Text("Tap to start")
                    } else if hidden {
                        Text("Tap to show")
                    } else {
                        VStack {
                            Text(textToShow)
                            Text("Tap to hide again")
                        }
                    }
                }
                .padding(.bottom, 20)
                Spacer()
            }
        }
        .padding(10)
        .frame(width: 350, height: 500)
        .background(in: .rect(cornerRadius: 20), fillStyle: .init(eoFill: true, antialiased: true))
        .backgroundStyle(spyNumbers.contains(counter) && !hidden ? .red : .orange)
        .onAppear {
            do {
                let path = Bundle.main.path(forResource: "words", ofType: "json")
                let data = try Data(contentsOf: URL(filePath: path!), options: .mappedIfSafe)
                var json = try JSONSerialization.jsonObject(with: data, options: .topLevelDictionaryAssumed) as! [String : [String]]
                for category in configs.first!.unselectedCategories {
                    json.removeValue(forKey: category)
                }
                let category = json.randomElement()!
                word = category.value.randomElement()!
            } catch {
                loadingErrorPresented.toggle()
            }
            for _ in 1...numberSpies {
                var rm = Int.random(in: 0..<numberPlayer)
                while spyNumbers.contains(rm) {
                    rm = Int.random(in: 0..<numberPlayer)
                }
                spyNumbers.append(rm)
            }
        }
        .navigationTitle("Roles")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.automatic)
#endif
        .foregroundStyle(.primary)
        .alert("Loading error", isPresented: $loadingErrorPresented) {
            
        } message: {
            Text("An error occured while loading the words.\nPlease try again.")
        }
    }

    /// Executed on button tap
    private func btnTap() -> Void {
        guard hidden else {
            hidden.toggle()
            counter += 1
            print("")
            return
        }
        if spyNumbers.contains(counter) {
            textToShow = String(localized: "You're a Spy")
        } else if counter >= numberPlayer {
            gameRunning.wrappedValue = true
            dismiss()
        } else {
            textToShow = word
        }
        hidden.toggle()
    }
}

internal struct RoleViewerPreview : PreviewProvider {
    @State internal static var gameRunning : Bool = false
    
    private static var previewModelContainer: ModelContainer = {
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
    
    @State private static var players : [Player] = [Player(name: "name1"), Player(name: "name2")]
    
    static var previews: some View {
        RoleViewer(numberPlayer: 2, numberSpies: 1, gameRunning: $gameRunning, players: $players)
            .modelContainer(previewModelContainer)
    }
}
