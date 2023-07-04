//
//  AnimatedGradient.swift
//  myChat
//
//  Created by Никита Куприянов on 04.07.2023.
//

import SwiftUI

struct AnimatedGradient: View {
    @State private var start = UnitPoint(x: 0, y: 0)
    @State private var end = UnitPoint(x: 0, y: 2)
    let colors: [Color]
    var body: some View {
        ZStack {
            LinearGradient(colors: colors, startPoint: start, endPoint: end)
                .onAppear {
                    withAnimation (.easeInOut(duration: 5).repeatForever()) {
                        self.start = UnitPoint(x: 1, y: -1)
                        self.end = UnitPoint(x: 0, y: 1)
                    }
                }
        }
    }
}


