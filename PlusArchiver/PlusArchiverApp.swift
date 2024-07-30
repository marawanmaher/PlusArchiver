//
//  PlusArchiverApp.swift
//  PlusArchiver
//
//  Created by Marawan on 30/07/2024.
//

import SwiftUI

@main
struct PlusArchiverApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
