//
//  SharedResources.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 14/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class Shared: ObservableObject {
    @Published var previousView = "HomeView"
    @Published var authentication = false
    @Published var viewToShow = "HomeView"
    @Published var locationManager = LocationManager()
    @Published var selectedCommitment = Commitment()
    @Published var commitmentSet: [Int:Commitment] = commitmentDict
    @Published var discoverSet: [Int:Commitment] = [:]
    @Published var myIP: String = "10.24.48.197"
    @Published var helperMode = true
    private static var formatter = DateFormatter()
    var dateFormatter: DateFormatter{
        get{
            Shared.formatter.dateFormat = "MMM dd, yyyy  HH:mm"
            return Shared.formatter
        }
    }
    @Published var neederInfo: UserInfo?
    @Published var image: URL? = URL(string: "")
    
    var darkMode: Bool{
        get{
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark
        }
    }
    
    func commitmentArray() -> [Commitment] {
        return Array(commitmentSet.values)
    }
    
    func discoverArray() -> [Commitment] {
        return Array(discoverSet.values)
    }
}
