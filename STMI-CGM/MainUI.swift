//
//  MainUI.swift
//  STMI-CGM
//
//  Created by iMac on 5/7/20.
//  Copyright © 2020 Amin Hamiditabar. All rights reserved.
//

import SwiftUI
import UserNotifications

struct MainUI: View {
    var notifications = Notifications()
    @State var showSheet = false
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    @FetchRequest(entity: Credentials.entity(), sortDescriptors: []) var credentials: FetchedResults<Credentials>
    enum ActiveSheet {
       case first, second
    }
    func closeSheet() {
        self.showSheet = false
    }

    @State private var activeSheet: ActiveSheet = .first
    
    @State var participantId = ""
    
    var body: some View {
        VStack{
            if self.credentials.count == 0 {
                TextField("Enter participant id", text: self.$participantId).padding()
                Button("Submit") {
                    let credentials = Credentials(context: self.moc)
                    credentials.participantId = self.participantId
                    
                    do {try self.moc.save()}
                    catch {print(error)}
                }
            } else {
                VStack{
                    Text("Systems and Technology for Medicine and IoT lab")
                        .multilineTextAlignment(.center)
                        .frame(width: 300, height: 150, alignment: .center)
                        .font(.custom("Anton-Regular", size: 30))
                    HStack{
                        Button(action: {
                            self.showSheet = true
                            self.activeSheet = .first
                        }) {
                            VStack{
                                Image("activity")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 140, height: 140, alignment: .center)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color("maroon"), lineWidth: 2))
                                    .shadow(radius: 10)
                                    .padding()
                                Text("Activity")
                                    .font(.custom("Teko-Medium", size: 25))
                                    .foregroundColor(Color.white)
                                    .frame(width: 125, height: 60, alignment: .center)
                                    .background(Color.blue)
                                    .cornerRadius(40)
                            }
                        }
                        Divider()
                        Button(action: {
                            self.showSheet = true
                            self.activeSheet = .second
                        }, label:{
                            VStack {
                                Image("meal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 140, height: 140, alignment: .center)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color("maroon"), lineWidth: 2))
                                    .shadow(radius: 10)
                                    .padding()
                                Text("Meal")
                                    .font(.custom("Teko-Medium", size: 25))
                                    .foregroundColor(Color.white)
                                    .frame(width: 125, height: 60, alignment: .center)
                                    .background(Color.blue)
                                    .cornerRadius(40)

                            }
                        })
                    }
                    .sheet(isPresented: $showSheet, onDismiss: closeSheet) {
                        if self.activeSheet == .first {
                            ActivityMainIFC().navigationBarTitle("STMI", displayMode: .inline)
                            .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
                        } else if self.activeSheet == .second {
                            MealList().navigationBarTitle("STMI", displayMode: .inline)
                            .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
                        }
                        
                    }
                }
            }
            
        }
        .onAppear {
            notifications.authorizeNotification()
        }
    }
}

struct MainUI_Previews: PreviewProvider {
    static var previews: some View {
        MainUI()
    }
}
