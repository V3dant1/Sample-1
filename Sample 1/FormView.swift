//
//  FormView.swift
//  Sample 1
//
//  Created by Vedant Kathrani on 3/26/23.
//

import SwiftUI

struct FormView: View {
    @State var name=""
    @State var email=""
    @State var canNotify=false
    var body: some View {
        Form {
            TextField("Name",text:$name)
                .onChange(of: name) { newValue in
                    print("Updated name  to \(newValue)")
                }
            TextField("Email",text:$email)
                .onChange(of: email) { newValue in
                    print("Updated email  to \(newValue)")
                }
            Toggle(isOn: $canNotify) {
                Text("Notification")
            }.onChange(of: canNotify) { newValue in
                print("Updated canNotify to \(newValue)")
            }
        }
    }
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
    }
}
