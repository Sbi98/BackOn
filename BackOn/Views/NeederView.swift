//
//  HomeView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import CoreLocation

struct NeederView: View {
    @EnvironmentObject var shared: Shared

    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Hi Andy!")
                    .font(.largeTitle)
                    .bold()
                    .fontWeight(.heavy)
                    .padding(20)
                NeederCommitRow()
                    .onAppear(perform: getCommitByUser)
                Spacer()
                AddNeedButton()
                Spacer()
            }.padding(.top, 40)
        }.background(Color("background"))
        .edgesIgnoringSafeArea(.all)
    }
    
    
    
    
    
    
    
    //MARK: GetCommitByUser
    func getCommitByUser() {
        print("*** getCommitByUser ***")
        let coreDataController: CoreDataController = CoreDataController()
        let userEmail: String = coreDataController.getLoggedUser().1.email!
        let parameters: [String: String] = ["email": userEmail]

        //create the url with URL
        let url = URL(string: "http://10.24.48.197:8080/NewBackOn-0.0.1-SNAPSHOT/GetCommitByUserEmail")! //change the url

        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body

        } catch let error {
            print(error.localizedDescription)
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //create dataTask using the session object to send data to the server

        //SE VOGLIO LEGGERE I DATI DAL SERVER
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
                                let userStatus = dict.value(forKey: "userStatus")
                                let title = dict.value(forKey: "titolo")

                                let dateFormatter = DateFormatter()
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                                let date = dateFormatter.date(from:"\(data!)")!

                                let position: CLLocation = CLLocation(latitude: (latitude as! NSString).doubleValue, longitude: (longitude as! NSString).doubleValue)

                                let user = UserInfo(name: userName! as! String, surname: userSurname! as! String, email: userEmail! as! String, url: URL(string: userPhoto! as! String)!, isHelper: userStatus! as! Int)

                                let c = Commitment(userInfo: user, title: title! as! String, descr: descrizione! as! String, date: date , position: position, ID: id! as! Int)

                                self.shared.commitmentSet[id! as! Int] = c
                            }
                        }
                    }
                }
            }
        }.resume()
    }
}

struct NeederCommitRow: View {
    @EnvironmentObject var shared: Shared
    
    var body: some View {
        VStack (alignment: .leading) {
            Button(action: {
                withAnimation {
                    FullDiscoverView.show()
                }
            }) {
                HStack {
                    Text("Your requests")
                        
                        //Text("Around you")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.systemBlue))
                }.padding(.horizontal, 20)
            }.buttonStyle(PlainButtonStyle())
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(shared.commitmentArray(), id: \.ID) { currentDiscover in
                        DiscoverView(commitment: currentDiscover)
                    }
                }.padding(20)
            }.offset(x: 0, y: -20)
        }
    }
}
