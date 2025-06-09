//
//  MicTestView.swift
//  Gemma
//
//  Created by Andre jones on 4/4/25.
//

import SwiftUI

struct MicTestView: View {
    @StateObject var micVm = MicService()
    @State private var isAuthorized: Bool = false
    var body: some View {
        VStack {
            if isAuthorized {
                Button("Start Recording") {
                    
                }
            } else {
                VStack {
                    Image("DeniedFace")
                        .resizable()
                        .frame(width: 75, height: 75)
                    Text("You will need to allow mic access to use this app. Go to settings and allow access.")
                        .frame(width: 200, height: 100 )
                        .padding()
                        .multilineTextAlignment(.center)
                }
            }
        }.task {
            isAuthorized = await micVm.isAuthorized
        }

    }
}

#Preview {
    MicTestView()
}
