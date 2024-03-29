//
//  EditMeal.swift
//  STMI-CGM
//
//  Created by Sorush Omidvar on 3/4/22.
//  Copyright © 2022 Amin Hamiditabar. All rights reserved.
//

import SwiftUI
import Firebase


struct EditMeal: View {
    @State var meal:Meal
    @State var mealName:String
    @State var calories: String
    @State var protein: String
    @State var carbs: String
    @State var fat: String
    @State var ingredients: String
    @State var portions: String
    
    @State var startTime: Date
    @State var startTimeSelected: Bool
    @State var finishTime: Date
    @State var finishTimeSelected:Bool
    
    @State var image: Image?
    @State var inputImage: UIImage?
    @State var mealPicAdd:String=""
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Meal.entity(), sortDescriptors: []) var meals: FetchedResults<Meal>
    @Environment(\.presentationMode) var presentation // to make this view dismiss itself
    
    @State var showActionSheet = false
    @State var showImagePicker = false
    @State var showAlert = false
    @State var sourceType: UIImagePickerController.SourceType = .camera
    
    @State var cameraPic = true
    @State var eatingNow = false
    @State var oldMeal = true
    @State var accurate = true
    
    @FetchRequest(entity: Credentials.entity(), sortDescriptors: []) var creds: FetchedResults<Credentials>
    var ref: DatabaseReference! = Database.database().reference()
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    VStack {
                        TextField("Name" ,text:  self.$mealName)
                        TextField("Calories", text: self.$calories)
                        TextField("Protein", text: self.$protein)
                        TextField("Carbs", text: self.$carbs)
                        TextField("Fat", text: self.$fat)
                        TextField("Ingredients", text: self.$ingredients)
                        TextField("Portion (servings)", text: self.$portions)
                    }.padding().padding(.top, 30)
                    VStack{
                        if self.image != nil {
                             self.image?
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150, alignment: .center)
                                .clipShape(Rectangle())
                                .cornerRadius(20)
                                .shadow(radius: 10)
                                .onTapGesture {self.showActionSheet = true}
                                .padding()
                        } else {
                            Image(systemName: "camera.circle.fill")
                                .resizable()
                                .foregroundColor(.blue)
                                .imageScale(.large)
                                .frame(width: 130, height: 130, alignment: .center)
                                .onTapGesture {self.showActionSheet = true}
                                .padding()
                        }
                    }.onTapGesture {self.showActionSheet = true}
                }.frame(width: geo.size.width, height: geo.size.height/2, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).padding(.bottom)
                
                Button("Estimate") {
                    self.accurate.toggle()
                }.buttonStyle(NotSelectedButtonStyle(selected: !self.accurate))
                
                HStack {
                    Button("Start eating") {
                        withAnimation{self.oldMeal=false}
                        withAnimation{self.eatingNow.toggle()}
                    }.buttonStyle(NotSelectedButtonStyle(selected: self.eatingNow)).padding()
                    Button("Input old meal") {
                        withAnimation{self.eatingNow=false}
                        withAnimation{self.oldMeal.toggle()}
                        
                    }.buttonStyle(NotSelectedButtonStyle(selected: self.oldMeal)).padding()
                }
                
                if eatingNow {
                    VStack {
                        if !startTimeSelected {
                            Button("Start") {
                                self.startTime = Date()
                                withAnimation{self.startTimeSelected = true}
                            }.buttonStyle(NotSelectedButtonStyle())
                        } else {
                            HStack {
                                Text(startTime, style: .time).padding(.horizontal)
                                Button(action: {
                                    self.startTimeSelected = false
                                }, label: {
                                    Text("clear")
                                })
                            }.padding()
                            
                        }
                        
                        if !finishTimeSelected {
                            Button("Finish") {
                                self.finishTime = Date()
                                withAnimation{self.finishTimeSelected = true}
                            }.buttonStyle(NotSelectedButtonStyle())
                        } else {
                            HStack {
                                Text(finishTime, style: .time).padding(.horizontal)
                                Button(action: {
                                    self.finishTimeSelected = false
                                }, label: {
                                    Text("clear")
                                })
                            }.padding()
                            
                        }
                    }
                }
                
                if oldMeal {
                    VStack {
                        DatePicker("Start time", selection: self.$startTime)
                        DatePicker("Finish time", selection: self.$finishTime)
                    }.padding()
                }
                
                
                
                Spacer()
                
                
                Button(action: {
                    if self.allEntriesFilled() {
                        self.saveToMoc()
                    } else {
                        self.showAlert.toggle()
                    }
                }){
                    Text("Update meal")
                    .font(.custom("Teko-Medium", size: 25))
                    .foregroundColor(Color.white)
                    .frame(width: 220, height: 60, alignment: .center)
                    .background(Color.blue)
                    .cornerRadius(40)
                }.padding()

                // Whenever you click on the camera this will open
                .actionSheet(isPresented: self.$showActionSheet, content: { () -> ActionSheet in
                    ActionSheet(title: Text("Select Image"), buttons: [
                        ActionSheet.Button.default(Text("Camera"), action: {
                            self.showImagePicker.toggle()
                            self.sourceType = .camera
                            self.cameraPic = true
                        }),
                        ActionSheet.Button.default(Text("Photo Gallery"), action: {
                            self.showImagePicker.toggle()
                            self.sourceType = .photoLibrary
                            self.cameraPic = false
                        }),
                        ActionSheet.Button.cancel()
                    ])
                })
                    // After choosing from camera or gallery this will open
                
                .sheet(isPresented: self.$showImagePicker, onDismiss: self.loadImage) {
                    ImagePicker(image: self.$inputImage, camera: self.$cameraPic)
                }
                .alert(isPresented: self.$showAlert) {
                    Alert(title: Text("Please fill out all entries"), message: Text("We need all of the entries to train our models. If you are missing any of them please estimate macronutrients on MyFitnessPal and find an image on Google and press the estimate button"), dismissButton: .default(Text("Got it!")))
                }
            }
            
        }
        
    }
    
    func allEntriesFilled() -> Bool {
        if self.image != nil && self.mealName != "" && self.calories != "" &&
            self.protein != "" && self.carbs != "" && self.fat != "" && self.portions != "" {
            return true
        } else {
            return false
        }
            
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {return}
        image = Image(uiImage: inputImage)
    }
    
    func getParticipantId()-> String {
        return self.creds[0].participantId ?? "no id found"
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func saveToMoc() {
        self.recordDeleter(thisMeal:self.meal)
        
        let meal = Meal(context: self.moc)
        meal.mealName = self.mealName
        meal.calories = Double(self.calories) ?? 0
        meal.carbs = Double(self.carbs) ?? 0
        meal.protein = Double(self.protein) ?? 0
        meal.fat = Double(self.fat) ?? 0
        meal.startTime = startTime
        meal.finishTime = finishTime
        meal.ingredients = self.ingredients
        meal.portions = portions
        meal.accurate = self.accurate
        meal.picture = self.inputImage?.jpegData(compressionQuality: 0.2)
        
        do {try self.moc.save()}
        catch {print(error)}
        self.saveMealPicture(thisMeal: meal, mealPicture: UIImage(data: Data((meal.picture!)))!)
    
        self.presentation.wrappedValue.dismiss()
        
        self.ref.child("Meal Entry").child("\(self.getParticipantId())").child("\(self.getDate())").child("mealName").setValue(["mealName": "\(self.mealName)"])
        self.ref.child("Meal Entry").child("\(self.getParticipantId())").child("\(self.getDate())").child("calories").setValue(["calories": "\(self.calories)"])
        self.ref.child("Meal Entry").child("\(self.getParticipantId())").child("\(self.getDate())").child("carbs").setValue(["carbs": "\(self.carbs)"])
        self.ref.child("Meal Entry").child("\(self.getParticipantId())").child("\(self.getDate())").child("protein").setValue(["protein": "\(self.protein)"])
        self.ref.child("Meal Entry").child("\(self.getParticipantId())").child("\(self.getDate())").child("fat").setValue(["fat": "\(self.fat)"])
        self.ref.child("Meal Entry").child("\(self.getParticipantId())").child("\(self.getDate())").child("startTime").setValue(["startTime": "\(self.startTime)"])
        self.ref.child("Meal Entry").child("\(self.getParticipantId())").child("\(self.getDate())").child("finishTime").setValue(["finishTime": "\(self.finishTime)"])
        self.ref.child("Meal Entry").child("\(self.getParticipantId())").child("\(self.getDate())").child("ingrerdients").setValue(["ingrerdients": "\(self.ingredients)"])
        self.ref.child("Meal Entry").child("\(self.getParticipantId())").child("\(self.getDate())").child("portions").setValue(["portions": "\(self.portions)"])

        
    }
    func recordDeleter(thisMeal:Meal){
        let pictureFileName=self.mealPictureFileNameGetter(thisMeal: thisMeal)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: pictureFileName.path) {
            try? fileManager.removeItem(atPath: pictureFileName.path)
        }
        self.moc.delete(self.meal)
    }
    
    func getDate() -> String {
        let myDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-HH:mm:ss"
        let currentTime = dateFormatter.string(from: myDate)
        
        return currentTime
    }
    
    func saveMealPicture(thisMeal:Meal,mealPicture:UIImage)->Void{
        let pictureFileName=self.mealPictureFileNameGetter(thisMeal: thisMeal)
        
        if let data = mealPicture.jpegData(compressionQuality: 100) {
            try? data.write(to: pictureFileName)
        }
    }
    func mealPictureFileNameGetter(thisMeal:Meal) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        var mealPicAdd=String(thisMeal.objectID.debugDescription)
        var index = mealPicAdd.index(mealPicAdd.lastIndex(of: "/")!, offsetBy: 1)
        mealPicAdd=String(mealPicAdd[index...])
        
        index = mealPicAdd.index(mealPicAdd.lastIndex(of: ">")!, offsetBy: 0)
        mealPicAdd=String(mealPicAdd[..<index])
        
        let mealPicAddURL = documentsDirectory.appendingPathComponent(mealPicAdd+".jpeg")
        return mealPicAddURL
    }
}
