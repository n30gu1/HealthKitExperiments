//
//  ContentView.swift
//  HealthKitExperiments
//
//  Created by Sung Park on 2022/07/30.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vc = ContentViewController()
    
    var body: some View {
        VStack {
            ForEach(vc.hrvValues, id: \.self) { item in
                Text("\(item)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
