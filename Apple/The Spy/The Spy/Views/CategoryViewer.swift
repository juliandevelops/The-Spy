//
//  CategoryViewer.swift
//  The Spy
//
//  Created by Julian Schumacher on 14.06.24.
//

import SwiftUI

struct CategoryViewer: View {
    
    let json : [String : [String]]
    
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
        VStack {
            List {
                ForEach(json.sorted(by: { $0.key > $1.key } ), id: \.key) {
                    category, words in
                    Section(category) {
                        ForEach(words, id: \.hashValue) {
                            word in
                            Text(word)
                        }
                    }
                }
            }
        }
        .navigationTitle("Words")
    }
}

#Preview {
    CategoryViewer()
}
