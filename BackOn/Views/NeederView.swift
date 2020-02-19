//
//  HomeView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 12/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

struct NeederView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Hi Andy!")
                    .font(.largeTitle)
                    .bold()
                    .fontWeight(.heavy)
                    .padding(20)
                DiscoverRow()
                Spacer()
                AddNeedButton()
                Spacer()
            }.padding(.top, 40)
        }.background(Color("background"))
        .edgesIgnoringSafeArea(.all)
    }
}

