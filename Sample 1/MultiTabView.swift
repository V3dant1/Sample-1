//
//  MultiTabView.swift
//  Sample 1
//
//  Created by Vedant Kathrani on 3/26/23.
//

import SwiftUI

class RefreshManager: ObservableObject {
    @Published var refreshTab: Int
    
    init(refreshTab: Int) {
        self.refreshTab = refreshTab
    }
}


struct MultiTabView: View {
    
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject var refreshManager:RefreshManager
    
    @AppStorage("lat") var lat=0.0
    @AppStorage("lon") var lon=0.0
    
    var body: some View {
        
        ZStack {
            Color.blue.opacity(0.2).ignoresSafeArea()
            TabView{
                
                ObjectDetectionView()
                    .tabItem{
                        Label("Run AI",systemImage: "iphone.badge.play")
                    }
                SampleMapView(locationManager: locationManager)
                    .tabItem{
                        Label("Map",systemImage: "globe.desk.fill")
                           }
                WebView(url:URL(string:"https://www.google.com")!)
                    .tabItem{
                        Label("Information",systemImage: "info.circle")
                    }
            }
            .onAppear(){
                        locationManager.requestLocation()
                    }
            
        }
    }
}



struct MultiTabView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            MultiTabView()
        }
    }
}
