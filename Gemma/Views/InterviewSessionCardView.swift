//
//  InterviewSessionCardView.swift
//  Gemma
//
//  Created by Andre jones on 4/6/25.
//

import SwiftUI

struct InterviewSessionCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    let session: Interview
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(session.name)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            HStack {
                Label("\(session.createdAt.formatted(date: .abbreviated, time: .omitted))", systemImage: "clock")
                Spacer()
                Label("\(session.feedback ?? "") ...", systemImage: "bubble.and.pencil")
                    .lineLimit(0)
                    
            }
            .font(.caption)
        }
        .padding()
        .foregroundStyle(colorScheme == .dark ? .lavender : .black )
    }
}

struct InterviewSessionCardView_Previews: PreviewProvider {
    static var session = Interview.sampleSession
    static var previews: some View {
        InterviewSessionCardView(session: session)
            .background(.lavender)
            .previewLayout(.fixed(width: 400, height: 600))
    }
}

#Preview {
    InterviewSessionCardView(session: Interview.emptyForm)
}
