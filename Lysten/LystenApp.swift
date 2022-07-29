//
//  LystenApp.swift
//  Lysten
//
//  Created by Evan Tu on 8/4/21.
//

import SwiftUI

@main
struct LystenApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
