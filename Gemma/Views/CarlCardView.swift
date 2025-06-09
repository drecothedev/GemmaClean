//
//  CardView.swift
//  Gemma
//
//  Created by Andre Jones on 4/6/25.
//

import SwiftUI

struct CarlCardView: View {
    @Environment(\.colorScheme) var colorScheme
    let carl: CarlMethod

    var body: some View {
        VStack(alignment: .leading) {
            Text(carl.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
            
            HStack {
                Label("\(carl.createdAt.formatted(date: .abbreviated, time: .omitted))", systemImage: "clock")
                Spacer()
                Label("\(carl.context) ...", systemImage: "play")
                    .lineLimit(0)
            }
            .font(.caption)
        }
        .padding()
        .foregroundStyle(colorScheme == .dark ? .lavender : .black)
    }
}

struct CarlCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCarl = CarlMethod.sampleData
        

        return CarlCardView(carl: sampleCarl)
            .previewLayout(.fixed(width: 400, height: 600))
    }
}
