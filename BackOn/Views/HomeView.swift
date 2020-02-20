//
//  HomeView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI
import GoogleSignIn
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var shared: Shared
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack{
                //          Bottone per notificare il prossimo commitment
                Button("Schedule Notification") {
                    let nextCommitment = getNextNotificableCommitment(dataDictionary: self.shared.commitmentSet)
                    if nextCommitment != nil {
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                                let notification = UNMutableNotificationContent()
                                notification.title = nextCommitment!.title
                                notification.subtitle = nextCommitment!.descr
                                notification.sound = UNNotificationSound.default
                                
                                //              Imposto la notifica 30 min prima della scadenza
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: nextCommitment!.timeRemaining() - 30*60, repeats: false)
  // Le notifiche non vanno perché va aggiustato l'id del commitment                              
//let request = UNNotificationRequest(identifier: "\(nextCommitment!.ID)", content: notification, trigger: trigger)
                                //              Aggiungo la richiesta di notifica al notification center (sembra una InvokeLater per le notifiche)
//                                UNUserNotificationCenter.current().add(request)
                            }
                        }
                    }
                }
                Spacer()
                Button(action: {
                    print("Logout!")
                    GIDSignIn.sharedInstance()?.disconnect()
                }) {
                    Text("Logout")
                        .bold()
                        .foregroundColor(.black)
                }
                CommitmentRow()
                DiscoverRow()
                .onAppear(perform: loadCommitByOther)
                .offset(x: 0, y: -20)
                NeederButton()
                Spacer()
            }
        }
        .padding(.top, 40)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.all)
    }
    
    //MARK: loadCommitByOther
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
                    
                    let controller = CoreDataController()
                    let loggedUserEmail = controller.getLoggedUser().1.email!
                    
                    if let array = json as? NSArray {
                        for obj in array {
                            if let dict = obj as? NSDictionary {

                                let userEmail = dict.value(forKey: "userEmail")
                                
                                if !(loggedUserEmail == userEmail! as! String) {
                                    let id = dict.value(forKey: "id")
                                    let descrizione = dict.value(forKey: "description")
                                    let data = dict.value(forKey: "date")
                                    let latitude = dict.value(forKey: "latitude")
                                    let longitude = dict.value(forKey: "longitude")
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
                                    
                                    print(c.title)
                                    
                                    self.shared.discoverSet[id! as! Int] = c
                                }
                            }
                        }
                    }
                }
            }
        }.resume()
    }
    
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
