//
//  Sample_1App.swift
//  Sample 1
//
//  Created by Vedant Kathrani on 3/26/23.
//

import SwiftUI

@main
struct Sample_1App: App {
    var refreshManager = RefreshManager(refreshTab: 1)
    var body: some Scene {
        WindowGroup {
            MultiTabView()
                .environmentObject(refreshManager)
        }
    }
}
