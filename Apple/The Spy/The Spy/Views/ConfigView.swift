//
//  ConfigView.swift
//  The Spy
//
//  Created by Julian Schumacher on 11.09.24.
//

import SwiftUI
import SwiftData

internal struct ConfigView: View {
    
    @Query internal var configs : [Configuration]
    
    private let json : [String : [String]]
    
    @State private var selection : [String] = []
    
    @Environment(\.modelContext) private var modelContext
    
    internal init() {
        do {
            let path = Bundle.main.path(forResource: "words", ofType: "json")
            let data = try Data(contentsOf: URL(filePath: path!), options: .mappedIfSafe)
            json = try JSONSerialization.jsonObject(with: data, options: .topLevelDictionaryAssumed) as! [String : [String]]
        } catch {
            json = [:]
            print("Error")
        }
    }
    
    var body: some View {
        List {
            ForEach(json.sorted(by: { $0.key > $1.key } ), id: \.key) {
                category, _ in
                SelectableRow(selection: $selection, category: category)
            }
        }
        .navigationTitle("Categories")
        .onAppear {
            selection.append(contentsOf: configs.first!.unselectedCategories)
        }
        .onChange(of: selection) {
            configs.first!.unselectedCategories = selection
        }
    }
}

private struct SelectableRow: View {
    
    internal var selection : Binding<[String]>
    
    @State private var isSelected : Bool
    
    internal let category : String
    
    internal init(
        selection: Binding<[String]>,
        category: String
    ) {
        self.selection = selection
        self.category = category
        isSelected = !selection.wrappedValue.contains(where: { $0 == category })
    }
    
    var body: some View {
        HStack {
            Button {
                isSelected.toggle()
                if selection.wrappedValue.contains(category) {
                    selection.wrappedValue.removeAll(where: { $0 == category })
                } else {
                    selection.wrappedValue.append(category)
                }
            } label: {
                Image(systemName: isSelected ? "checkmark.circle" : "circle")
            }
            .foregroundStyle(.primary)
            Text(category)
        }
        .navigationBarTitleDisplayMode(.automatic)
    }
}


// TODO: work on preview (currently not working, because configs is empty when only this view is loaded
//#Preview {
//    ConfigView()
//        .onAppear {
//        }
//        .modelContainer(previewModelContainer)
//}
//
//private var previewModelContainer: ModelContainer = {
//    let schema = Schema([
//        Configuration.self
//    ])
//    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//    do {
//        return try ModelContainer(for: schema, configurations: [modelConfiguration])
//    } catch {
//        fatalError("Could not create ModelContainer: \(error)")
//    }
//}()
