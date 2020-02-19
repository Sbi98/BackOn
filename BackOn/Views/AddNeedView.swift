//
//  HomeView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

struct AddNeedView: View {
    @ObservedObject var titlePickerData = TitlePickerData()
    @State var toggleRepeat = false
    @State var toggleVerified = false
    @State var needDescription = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Add Need")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                CloseButton()
            }.padding(.bottom, 10)
            Text("Type of your need")
                .font(.headline)
            Text(titlePickerData.titlePickerValue == -1 ? "Click to select your need" : titlePickerData.titles[self.titlePickerData.titlePickerValue])
                .onTapGesture {
                    withAnimation {self.titlePickerData.showTitlePicker.toggle()}
                }
            Text("Description (optional)")
                .font(.headline)
            
            TextField("", text: self.$needDescription)
                .padding(7)
                .frame(minHeight: 30)
                .background(Color(.systemGray3).opacity(0.35))
                .cornerRadius(5)
                .font(.callout)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
            Toggle(isOn: $toggleRepeat) {
                Text("Repeat each week at the same hour")
            }
            Toggle(isOn: $toggleVerified) {
                Text("Do you want only verified helpers?")
            }
            Spacer()
            ConfirmAddNeedButton()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        .overlay(myOverlay(isPresented: self.$titlePickerData.showTitlePicker, toOverlay: AnyView(TitlePicker(pickerElements: self.titlePickerData.titles, selectedValue: self.$titlePickerData.titlePickerValue))))
 
    }
}

class TitlePickerData: ObservableObject {
    var titles = ["Getting groceries","Shopping","Pet Caring","Houseworks","Sharing time","Wheelchair transport"]
    @Published var showTitlePicker = false
    @Published var titlePickerValue = -1
}

struct TitlePicker: View {
    var pickerElements: [String]
    @Binding var selectedValue: Int
    var body: some View {
        Picker("Select your need", selection: self.$selectedValue) {
            ForEach(0 ..< self.pickerElements.count) {
                Text(self.pickerElements[$0])
                    .font(.headline)
                    .fontWeight(.medium)
            }
        }.labelsHidden()
        .frame(width: UIScreen.main.bounds.width, height: 250)
        .background(Color.primary.colorInvert())
    }
}

