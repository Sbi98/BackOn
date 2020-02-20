//
//  Certificates.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

struct DiscoverView: View {
    @ObservedObject var commitment: Commitment
    @EnvironmentObject var shared: Shared
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.shared.selectedCommitment = self.commitment
                DiscoverDetailedView.show()
            }
        }) {
            VStack (alignment: .leading, spacing: 5){
                //UserPreview(user: commitment.userInfo, description: "\(commitment.etaText)", whiteText: shared.darkMode)
                UserPreview(user: commitment.userInfo, description: shared.locationManager.lastLocation != nil ? commitment.etaText : "Location services disabled", whiteText: shared.darkMode)
                
                Text(commitment.title)
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                Text(commitment.descr)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .bold()
                    .foregroundColor(.black)
                    .frame(width: .none, height: 60, alignment: .leading)
            }.padding(.horizontal, 20)
                .offset(x: 0, y: -10)
                .frame(width: CGFloat(320), height: CGFloat(230))
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: CGFloat(320), height: CGFloat(230))
        .background(Color.primary.colorInvert())
        .cornerRadius(10)
        .shadow(radius: 10)
        .onAppear(perform: {
            if self.shared.locationManager.lastLocation != nil {
                self.commitment.requestETA(source: self.shared.locationManager.lastLocation!)
            }
        })
    }
}


struct DiscoverRow: View {
    @EnvironmentObject var shared: Shared
    
    var body: some View {
        VStack (alignment: .leading) {
            Button(action: {
                withAnimation {
                    FullDiscoverView.show()
                }
            }) {
                HStack {
                    Text(self.shared.helperMode ? "Around you" : "Your requests")
                        
                        //Text("Around you")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBlue))
                }.padding(.horizontal, 20)
            }.buttonStyle(PlainButtonStyle())
            
            if shared.discoverArray().isEmpty{
                Text("There are no commitments in your surroundings").font(.headline)
                    .padding(.horizontal, 50)
            } else{
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(shared.discoverArray(), id: \.ID) { currentDiscover in
                            DiscoverView(commitment: currentDiscover).frame(width: CGFloat(320), height: CGFloat(230))
                        }
                        
                    }.padding(20)
                }.offset(x: 0, y: -20)
            }
        }.onAppear(perform: loadCommitByOther)
    }
    
    func loadCommitByOther() {
        print("loadCommitByOther")
        guard let url = URL(string: "http://10.24.48.197:8080/NewBackOn-0.0.1-SNAPSHOT/GetAllOtherCommit") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else{
                        print("Error!")
                        return
                    }
                    
                    if let array = json as? NSArray {
                        for obj in array {
                            if let dict = obj as? NSDictionary {

                                let id = dict.value(forKey: "id")
                                let descrizione = dict.value(forKey: "description")
                                let data = dict.value(forKey: "date")
                                let latitude = dict.value(forKey: "latitude")
                                let longitude = dict.value(forKey: "longitude")
                                let userEmail = dict.value(forKey: "userEmail")
                                let userPhoto = dict.value(forKey: "userPhoto")
                                let userSurname = dict.value(forKey: "userSurname")
                                let userName = dict.value(forKey: "userName")
                                let title = dict.value(forKey: "titolo")
                                let userStatus = dict.value(forKey: "userStatus")
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                let date = dateFormatter.date(from:"\(data!)")!
                                
                                let position: CLLocation = CLLocation(latitude: (latitude as! NSString).doubleValue, longitude: (longitude as! NSString).doubleValue)
                                

                                let user = UserInfo(name: userName! as! String, surname: userSurname! as! String, email: userEmail! as! String, url: URL(string: userPhoto! as! String)!, isHelper: userStatus! as! Int)


                                let c = Commitment(userInfo: user, title: title! as! String, descr: descrizione! as! String, date: date , position: position, ID: id! as! Int)

                                //AGGIUNGERE CONTROLLO CHE PRENDE DA CORE DATA L'UTENTE LOGGATO E CONFRONTA LA SUA EMAIL CON userEmail.
                                //Se è uguale non deve fare questo comando qui sotto!
                                self.shared.discoverSet[id! as! Int] = c
                            }
                        }
                    }
                }
            }
        }.resume()
    }
    
}


struct FullDiscoverView: View {
    @EnvironmentObject var shared: Shared
    @State private var selectedView = 0
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            Button(action: {
                withAnimation{
                    HomeView.show()
                }}){
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.largeTitle)
                        
                        Text("Around you")
                            .fontWeight(.bold)
                            .font(.title).foregroundColor(.primary)
                    }.padding([.top,.horizontal])
            }
            
            Picker(selection: $selectedView, label: Text("What is your favorite color?")) {
                Text("List").tag(0)
                Text("Map").tag(1)
            }.pickerStyle(SegmentedPickerStyle()).labelsHidden().padding(.horizontal)
            if selectedView == 0 {ScrollView(.vertical, showsIndicators: false) {
                VStack (alignment: .center, spacing: 25){
                    ForEach(shared.discoverArray(), id: \.ID) { currentDiscover in
                        Button(action: {
                            self.shared.selectedCommitment = currentDiscover
                            DiscoverDetailedView.show()
                        }) {
                            HStack {
                                UserPreview(user: currentDiscover.userInfo, description: "\(currentDiscover.title)\nCasa", whiteText: self.shared.darkMode)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                                    .foregroundColor(Color(UIColor.systemBlue))
                            }.padding(.horizontal, 15)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(.top,20)
                }
            }
            else{
                MapViewDiscover().cornerRadius(20)
            }
        }
        .padding(.top, 40)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.all)
    }
}



