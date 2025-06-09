//
//  CreateACarlListView.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import SwiftUI


struct CreateACarlView: View {
    @StateObject var dataVm = DataViewModel()
    @State private var title = ""
    @State private var context = ""
    @State private var action = ""
    @State private var result = ""
    @State private var learning = ""
    @State private var date = Date()
    
    @Binding var showAddACarlView: Bool
    
    let user = User.sample
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("e.g., Leading a Team Meeting", text: $title)
                }
                
                Section(header: Text("Context")) {
                    TextEditor(text: $context)
                        .frame(height: 100)
                }
                
                Section(header: Text("Action")) {
                    TextEditor(text: $action)
                        .frame(height: 100)
                }
                
                Section(header: Text("Result")) {
                    TextEditor(text: $result)
                        .frame(height: 100)
                }
                
                Section(header: Text("Learning")) {
                    TextEditor(text: $learning)
                        .frame(height: 100)
                }
                
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newCarl = CarlMethod(
                            docId: UUID().uuidString,
                            title: title,
                            context: context,
                            action: action,
                            result: result,
                            learning: learning,
                            createdAt: date
                        )
                        
                        Task {
                            await dataVm.postCarl(uid: user.uid, carl: newCarl)
                        }
                        
                        showAddACarlView = false
                    }
                    .disabled(
                        title.isEmpty && context.isEmpty && action.isEmpty && result.isEmpty && learning.isEmpty
                    )
                    .bold()
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showAddACarlView = false
                    }
                }
            }
            .navigationTitle("New CARL Entry")
        }
        
    }
}

#Preview {
    CreateACarlView(showAddACarlView: .constant(true))
}

