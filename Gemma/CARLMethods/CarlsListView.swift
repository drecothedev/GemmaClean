//
//  CarlsView.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import SwiftUI

struct CarlsListView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var dataVm = DataViewModel()
    @State var user = User.sample
    @State var showCarls: Bool = false
    @State var userCarls: [CarlMethod] = []
    @State var showAddACarlView = false
    @State private var refreshID = UUID()
    @Binding var showHints: Bool

    var body: some View {
        NavigationStack {
            VStack {
                List(userCarls) { carl in
                    NavigationLink(destination: CarlDetailView(carl: carl)) {
                        CarlCardView(carl: carl)
                    }
                }
            }
            .id(refreshID)
            .onAppear {
                Task {
                    userCarls = await dataVm.getUserCarls(uid: user.uid)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddACarlView.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(colorScheme == .dark ? .bubblegum : .blue)
                    }
                }
            }
            .sheet(isPresented: $showAddACarlView, onDismiss: {
                Task {
                    userCarls = await dataVm.getUserCarls(uid: user.uid)
                    refreshID = UUID() // Forces the List to refresh
                }
            }) {
                CreateACarlView(showAddACarlView: $showAddACarlView)
            }
        }
    }
}

#Preview {
    CarlsListView(showHints: .constant(true))
}
