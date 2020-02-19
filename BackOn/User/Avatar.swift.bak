//
//  ContentView.swift
//  BeMyPal
//
//  Created by Vincenzo Riccio on 10/02/2020.
//  Copyright © 2020 Vincenzo Riccio. All rights reserved.
//

import SwiftUI

struct Avatar: View {
    let image: String
    let size: CGFloat

    var body: some View {
        Image(image)
            .renderingMode(.original)
            .resizable()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 7)
    }
    
}
