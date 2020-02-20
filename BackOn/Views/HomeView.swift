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
    let dbController = (UIApplication.shared.delegate as! AppDelegate).dbController
    @State var isLoading: Bool = true
    
    var body: some View {
        RefreshableScrollView(height: 70, refreshing: self.$shared.loading) {
            VStack{
                Text("Hi \(CoreDataController().getLoggedUser().1.name)!")
                    .font(.largeTitle)
                    .bold()
                    .fontWeight(.heavy)
                    .padding(20)
//                          Bottone per notificare il prossimo commitment
                Button("Schedule Notification") {
                    let nextCommitment = getNextNotificableCommitment(dataDictionary: self.shared.commitmentSet)
                    if nextCommitment != nil {
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            if settings.authorizationStatus == UNAuthorizationStatus.authorized {
                                let notification = UNMutableNotificationContent()
                                notification.title = nextCommitment!.title
                                notification.subtitle = nextCommitment!.descr
                                notification.sound = UNNotificationSound.default

                                //              Imposto la notifica 2 min prima della scadenza
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: nextCommitment!.timeRemaining() - 2*60, repeats: false)
                                // Le notifiche non vanno perché va aggiustato l'id del commitment
                                let request = UNNotificationRequest(identifier: "\(nextCommitment!.ID)", content: notification, trigger: trigger)
                                //              Aggiungo la richiesta di notifica al notification center (sembra una InvokeLater per le notifiche)
                                UNUserNotificationCenter.current().add(request)
                            }
                        }
                    }
                }
//                Button(action: {
//                    print("Logout!")
//                    GIDSignIn.sharedInstance()?.disconnect()
//                }) {
//                    Text("Logout")
//                        .bold()
//                        .foregroundColor(.black)
//                }
                CommitmentRow()
                DiscoverRow()
                    .offset(x: 0, y: -20)
//                NeederButton()
//                Spacer()
            }
        }
        .padding(.top, 40)
        .background(Color("background"))
        .edgesIgnoringSafeArea(.all)
        //            }
        //        }
    }
    
}
