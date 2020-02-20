//
//  DatabaseController.swift
//  BackOn
//
//  Created by Emmanuel Tesauro on 18/02/2020.
//  Copyright © 2020 Emmanuel Tesauro. All rights reserved.
//

import Foundation
import CoreLocation

class DatabaseController {
    
//    MARK: USER
    
//    Salvo l'utente nel database
    static func registerUser(user: UserInfo) {
        print("registerUser")
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        
        let parameters: [String: String] = ["name": user.name, "surname": user.surname, "email" : user.email!, "photo": "\(user.photo)"]
                
        //create the url with URL
        let url = URL(string: "http://95.245.183.186:8180/NewBackOn-0.0.1-SNAPSHOT/RegisterUser")! //change the url
        
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
        }.resume()
    }
    
    
    static func getUserByEmail(email: String) {
        
        print("getUserByInt")
        
        var myUser: UserInfo?
        
        let parameters: [String: String] = ["email": "\(email)"]
        
        //create the url with URL
        let url = URL(string: "http://95.245.183.186:8180/NewBackOn-0.0.1-SNAPSHOT/GetUserByEmail")! //change the url
        
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
        
        //SE VOGLIO LEGGERE I DATI DAL SERVER
        URLSession.shared.dataTask(with: request) { data, response, error in
        }.resume()
    }
    
    
//    static func getUserByEmail(email: String) {
//
//        print("getUserByInt")
//
//        var myUser: UserInfo?
//
//        let parameters: [String: String] = ["email": "\(email)"]
//
//        //create the url with URL
//        let url = URL(string: "http://10.24.48.197:8080/NewBackOn-0.0.1-SNAPSHOT/GetUserByEmail")! //change the url
//
//        //now create the URLRequest object using the url object
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST" //set http method as POST
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
//
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//        //SE VOGLIO LEGGERE I DATI DAL SERVER
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data {
//                DispatchQueue.main.async{
//                    let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, String>
//                    if json != nil {
//                        if json!.count > 0 {
//                            myUser = UserInfo(photo: URL(string: json!["photo"]!)!, name: json!["name"]!, surname: json!["surname"]!, email: json!["email"]!)
//
//                        }
//                    }
//                }
//            }
//        }.resume()
//    }
    
    
    
//    MARK: COMMIT
    static func insertCommit(title: String, description: String, date: Date, latitude: Double, longitude: Double) {
        let coreDataController: CoreDataController = CoreDataController()
        
        let userEmail: String = coreDataController.getLoggedUser().1.email!
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date)
        print(formattedDate)
        
        let parameters: [String: String] = ["title":"\(title)", "description": "\(description)", "email": userEmail, "date":"\(formattedDate)","latitude":"\(latitude)", "lognitude":"\(longitude)"]
        
        //create the url with URL
        let url = URL(string: "http://95.245.183.186:8180/NewBackOn-0.0.1-SNAPSHOT/InsertCommit")! //change the url
        
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

//                                self.shared.commitmentSet[id! as! Int] = c
                            }
                        }
                    }
                }
            }
        }.resume()
    }
    
}
