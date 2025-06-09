//
//  SetInterviewParametersView.swift
//  Gemma
//
//  Created by Andre jones on 4/5/25.
//

import SwiftUI

struct SetInterviewParametersView: View {
    @EnvironmentObject var interviewVm: InterviewService
    @State private var tempKeyWord: String = ""
    @State private var navigate: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Interview Info")) {
                        TextField("Role you're practicing for", text: $interviewVm.role)
                    }

                    Section(header: Text("Add Key Words")) {
                        HStack {
                            TextField("Key word", text: $tempKeyWord)
                            Spacer()
                            Button {
                                let trimmed = tempKeyWord.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmed.isEmpty && !interviewVm.keyWords.contains(trimmed) {
                                    interviewVm.keyWords.append(trimmed)
                                    tempKeyWord = ""
                                }
                            } label: {
                                Image(systemName: "plus.circle")
                            }
                        }

                        if !interviewVm.keyWords.isEmpty {
                            ForEach(interviewVm.keyWords, id: \.self) { keyword in
                                HStack {
                                    Text(keyword)
                                    Spacer()
                                    Button {
                                        interviewVm.keyWords.removeAll { $0 == keyword }
                                    } label: {
                                        Image(systemName: "minus.circle")
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()

                Button {
                    guard !interviewVm.keyWords.isEmpty && !interviewVm.role.isEmpty else {
                        return
                    }

                    print("Starting interview for role: \(interviewVm.role)")
                    print("Key words: \(interviewVm.keyWords)")

                    navigate = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 200, height: 50)
                            .foregroundStyle(interviewVm.role.isEmpty || interviewVm.keyWords.isEmpty ? Color.gray : Color.cyan)

                        Text("Start")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                }
                .disabled(interviewVm.role.isEmpty || interviewVm.keyWords.isEmpty)
                .padding(.bottom)

                NavigationLink(destination: ActiveInterviewView(), isActive: $navigate) {
                    EmptyView()
                }
                .padding(.bottom)
            }
            .navigationTitle("Interview Setup")
        }
    }
}

#Preview {
    SetInterviewParametersView()
        .environmentObject(InterviewService())
}
