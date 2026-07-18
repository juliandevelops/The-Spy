//
//  ConfigSheet.swift
//  The Spy
//
//  Created by Julian Schumacher on 15.01.25.
//

import SwiftUI

struct ConfigSheet: View {

    @Environment(\.dismiss) private var dismiss

    @Binding internal var numberPlayer : Int

    @Binding internal var numberSpies : Int

    @Binding internal var rolesShowing : Bool

    @State private var playerNames : [String] = Array(repeating: "", count: 3)

    @Binding internal var players : [Player]

    @State private var playerNameCache : [String] = Array(repeating: "", count: 2)

    var body: some View {
        NavigationStack {
            ScrollView {
                Section {
                    HStack {
                        Button {
                            numberPlayer -= 1
                        } label: {
                            Image(systemName: "minus")
                        }
                        .frame(width: 20, height: 20)
                        .padding(.all, 20)
                        .glass(.regular.interactive())
                        .disabled(numberPlayer < 4)
                        Text("\(numberPlayer)")
                            .padding(.horizontal, 16)
                            .font(.title3)
                            .onChange(of: numberPlayer) {
                                playerNames = Array(
                                    repeating: "",
                                    count: numberPlayer
                                )
                                for i in 0..<playerNameCache.count {
                                    guard i < playerNames.count else { return }
                                    playerNames[i] = playerNameCache[i]
                                }
                            }
                        Button {
                            numberPlayer += 1
                        } label: {
                            Image(systemName: "plus")
                        }
                        .frame(width: 20, height: 20)
                        .padding(.all, 20)
                        .glass(.regular.interactive())
                    }
                    .padding(.vertical, 24)
                } header: {
                    Text("Player")
                        .font(.title2)
                        .padding(.top, 24)
                } footer: {
                    Text("This is the number of total players in your game, including the number of spies. It must be greater than 3, in order to not directly know who the spy is.")
                        .font(.footnote)
                }
                Section {
                    HStack {
                        Button {
                            numberSpies -= 1
                        } label: {
                            Image(systemName: "minus")
                        }
                        .frame(width: 20, height: 20)
                        .padding(.all, 20)
                        .glass(.regular.interactive())
                        .disabled(numberSpies < 2)
                        Text("\(numberSpies)")
                            .padding(.horizontal, 16)
                            .font(.title3)
                        Button {
                            numberSpies += 1
                        } label: {
                            Image(systemName: "plus")
                        }
                        .frame(width: 20, height: 20)
                        .padding(.all, 20)
                        .glass(.regular.interactive())
                        .disabled(numberPlayer == numberSpies + 1)
                    }
                    .padding(.vertical, 24)
                } header: {
                    Text("Spies")
                        .font(.title2)
                        .padding(.top, 24)
                } footer: {
                    Text("Your game must at least include 1 spy, and at least 1 player (with a complete total of 3 players).")
                        .font(.footnote)
                }
                Section {
                    ForEach(0..<playerNames.count, id: \.self) {
                        playerFieldNumber in
                        TextField("Playername \(playerFieldNumber + 1)", text: $playerNames[playerFieldNumber])
                            .padding(12)
                            .backgroundStyle(.clear)
                            .glass(.regular.interactive())
                            .keyboardType(.alphabet)
                            .textContentType(.name)
                    }
                } header: {
                    Text("Players")
                        .font(.title2)
                        .padding(.top, 24)
                } footer: {
                    Text("Give each player a name")
                        .font(.footnote)
                }
            }
            .navigationTitle("New Game")
            .toolbarRole(.automatic)
            .toolbar(.automatic, for: .automatic)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Start") {
                        playerNames.forEach {
                            players.append(Player(name: $0))
                        }
                        rolesShowing.toggle()
                        dismiss()
                    }
                    .disabled(!playerNames.allSatisfy { !$0.isEmpty })
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        numberPlayer = 3
                        numberSpies = 1
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

#Preview {

    @Previewable @State var numberPlayer: Int = 3

    @Previewable @State var numberSpies: Int = 1

    @Previewable @State var rolesShowing: Bool = false

    @Previewable @State var players : [Player] = []

    ConfigSheet(
        numberPlayer: $numberPlayer,
        numberSpies: $numberSpies,
        rolesShowing: $rolesShowing,
        players: $players
    )
}
