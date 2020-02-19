//
//  Certificates.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 11/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import MapKit

struct CommitmentView: View {
    @EnvironmentObject var shared: Shared
    
    var commitment: Commitment
    
    var body: some View {
        VStack {
            MapViewCommitment(key: commitment.ID)
                .frame(height: 250)
            Button(action: {
                withAnimation {
                    self.shared.selectedCommitment = self.commitment
                    CommitmentDetailedView.show()
                }
            }) {
                VStack{
                    Avatar(image: commitment.userInfo.profilePic)
                    //                    Avatar(image: "\(commitment.userInfo.photo)", size: 60)
                    Spacer()
                    Text(self.commitment.userInfo.identity)
                        .font(.title)
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(self.commitment.title).foregroundColor(Color.primary)
                    Spacer()
                    Text(self.shared.dateFormatter.string(from: self.commitment.date)).foregroundColor(Color.secondary).padding(.horizontal, 10).offset(y:15).frame(width: 320, alignment: .trailing)
                }.offset(x: 0, y: -30)
            }.buttonStyle(PlainButtonStyle())
        }
        .frame(width: CGFloat(320), height: CGFloat(400))
        .background(Color.primary.colorInvert())
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct CommitmentRow: View {
    @EnvironmentObject var shared: Shared
    @State private var results = [Result]()
    @State private var myCommits = Dictionary<Int, Commitment>()
    
    var body: some View {
        VStack (alignment: .leading){
            Button(action: {
                withAnimation{
                    CommitmentsListView.show()
                }
            }) {
                HStack {
                    Text("Your commitments")
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
                    ForEach(shared.commitmentArray(), id: \.ID) { currentCommitment in
                        CommitmentView(commitment: currentCommitment)
                    }
                }
                .padding(20)
            }.offset(x: 0, y: -20)
        }.onAppear(perform: getCommitByUser)
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


struct CommitmentsListView: View {
    @EnvironmentObject var shared: Shared
    
    var body: some View {
        
        
        VStack (alignment: .leading, spacing: 10){
            Button(action: {withAnimation{HomeView.show()}}) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.headline).foregroundColor(Color(UIColor.systemBlue))
                    
                    Text("Your commitments")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding(.leading, 5)
                }.padding([.top,.horizontal])
            }.buttonStyle(PlainButtonStyle())
            ScrollView(.vertical, showsIndicators: false) {
                VStack (alignment: .center, spacing: 25){
                    ForEach(shared.commitmentArray(), id: \.ID) { currentCommitment in
                        Button(action: {withAnimation{
                            self.shared.selectedCommitment = currentCommitment
                            CommitmentDetailedView.show()
                            }}) {
                                HStack {
                                    UserPreview(user: currentCommitment.userInfo, description: currentCommitment.title, whiteText: self.shared.darkMode)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.headline)
                                        .foregroundColor(Color(UIColor.systemBlue))
                                }.padding(.horizontal, 15)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(.top,20)
            }
            Spacer()
        }
        .padding(.top, 40)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.all)
    }
}

struct Result: Codable {
    var id: String
    var descrizione: String
}


#if DEBUG
struct CommitmentRow_Previews: PreviewProvider {
    static var previews: some View {
        CommitmentRow()
    }
}
#endif



