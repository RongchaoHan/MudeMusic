//
//  FirebaseController.swift
//  FIT3178-W02-Lab
//
//  Created by Michael Choi on 10/4/22.
//

import UIKit

// Import both Firebase Authentication and Firebase FirestoreSwift
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol{
    
    // Properties
    var listeners = MulticastDelegate<DatabaseListener>()
    var database: Firestore
    
    var defaultUser: User
    var currentUser : FirebaseAuth.User?
    var errorMsg: String?
    var authController: Auth
    var authHandle: AuthStateDidChangeListenerHandle?
    
    var fileList: [File] = []
    var packageList:[Package] = []
    var musicList: [Music] = []
    var filesRef: CollectionReference?
    var packagesRef: CollectionReference?
    var usersRef: CollectionReference?
    
    var rootRef: DocumentReference?
    var myMusicRef: String?
    var myVideoRef: String?
    var myImageRef: String?
    
    var rootPackage: Package
    var currentPackage: Package
    
    override init(){
        
        // Configure the FirebaseApplication
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        rootPackage = Package()
        currentPackage = Package()
        defaultUser = User()
        super.init()

        authHandle = authController.addStateDidChangeListener{
            (auth, user) in
            if let _ = user{
                self.currentUser = user
                // self.setupUserListener()
            }
        }
        
    }
}

// Listener Common Setting
extension FirebaseController{
    
    // Database Protocol Confirmation methods
    func cleanup() {
        userLogOut()
    }
    
    
    // Configure the add object listener
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .file || listener.listenerType == .all{
            listener.onFileChange(change: .update, files: currentPackage.files)
        }
        
        if listener.listenerType == .music || listener.listenerType == .all{
            listener.onMusicChange(change: .update, musics: musicList)
        }
        
        if listener.listenerType == .package || listener.listenerType == .all{
            listener.onPackageChange(change: .update, packages: currentPackage.packages)
        }
    }
    
    //  Configure the remove object listener
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}


// Firebase Authentification Setting
// ===============================================================================================================
// ===============================================================================================================
extension FirebaseController{
    
    func userRegister(email: String, password: String, username: String){
        print("User Register ================= ")
        // Create a new user account
        authController.createUser(withEmail: email, password: password){
            [self] (authResult, error) in
            
            if error != nil{
                self.errorMsg = error?.localizedDescription
            } else{
                print("Sign Up Success ================= ")
                currentUser = authResult?.user
                self.setupUserListener(username)
                
                return
            }
        }
        
       
        print("User Register ================= To the END")
    }
    
    func userLogIn(email: String, password: String){
        print("User Login ================= ")
        
        // Sign in as an existing user

        authController.signIn(withEmail: email, password: password){
            [self] authResult, error in
            
            
            if error != nil{
                self.errorMsg = error?.localizedDescription
            } else{
                print("Login Success ================= ")
                currentUser = authResult?.user
                self.setupUserListener("")
                
                return
            }
        }
        print("User Login ================= To the END")
    }
    
    func userLogOut(){
        do{
            try authController.signOut()
        }catch{
            print("Fail to sign out ")
        }
    }
}



// Setup the User Profile
// ===============================================================================================================
// ===============================================================================================================
extension FirebaseController{
    
    func setupUserListener(_ username: String){
        print("Set up User ================= ")
        usersRef = database.collection("Users")
        
        usersRef?.addSnapshotListener{
            [self]
            (querySnapshot, error) in
                
            // Ensure snapshot is valid
            // Get out the first element from the collection which is team
            guard let querySnapshot = querySnapshot else{
                print("Unable to load package =================== ")
                return
            }
            
            for query in querySnapshot.documents as [QueryDocumentSnapshot]{
                if(query.data()["uid"] as? String == currentUser?.uid){
                    print("Parse User =================")
                    defaultUser = User()
                    defaultUser.id = query.documentID
                    defaultUser.name = query.data()["name"] as? String
                    defaultUser.uid = query.data()["uid"] as? String
                    defaultUser.email = query.data()["email"] as? String
                    defaultUser.root = query.data()["root"] as? String
                    rootRef = query.data()["root"] as? DocumentReference
                    print("Parse User =================== To the end ")
                    defaultUser.printUser()
                    setupRootPackageListener()
                    return
                }
            }
            
            packagesRef = database.collection("Packages")
            filesRef = database.collection("Files")
            if defaultUser.id == nil{
                self.defaultUser = addUser(name:username)
            }else{
                self.defaultUser = addUser(name:"default")
            }
            defaultUser.printUser()
            setupRootPackageListener()
            print("Set Up User =================== To the end ")
            return
        }
    }
    
}


// Set user root package
// ===============================================================================================================
// ===============================================================================================================
extension FirebaseController{
    func setupRootPackageListener(){
        print("Set up Root ================= ")
        packagesRef = database.collection("Packages")
        packagesRef?.addSnapshotListener{
            [self] (querySnapshot, error) in
                
            // Ensure snapshot is valid
            // Get out the first element from the collection which is team
            guard let packageSnapshot = querySnapshot else{
                print("Unable to load package =================== ")
                return
            }
            
            for query in packageSnapshot.documents as [QueryDocumentSnapshot]{
                if(query.data()["uid"] as? String == defaultUser.uid){
                    let package = Package()
                    package.id = query.documentID
                    package.uid = query.data()["uid"] as! String?
                    package.name = query.data()["name"] as! String?
                    package.previousPackageID = query.data()["previousPackageID"] as! String?
                    packageList.append(package)
                    
                    switch package.name{
                    case "My Music":
                        myMusicRef = query.documentID
                    case "My Video":
                        myVideoRef = query.documentID
                    case "My Image":
                        myImageRef = query.documentID
                    
                    default: break
                    }
                }
            }
                
            self.parsePackageSnapshot(snapshot: packageSnapshot, packageID: defaultUser.root!)
            
        }
    }
    
    func setupPackagesListener(packageID: String){
        print("Set up Packages ================= ")
        packagesRef = database.collection("Packages")
        filesRef = database.collection("Files")
        filesRef?.addSnapshotListener{
            [self] (querySnapshot, error) in
                
            // Ensure snapshot is valid
            // Get out the first element from the collection which is team
            guard let fileSnapshot = querySnapshot else{
                print("Unable to load file =================== ")
                return
            }
            
            for query in fileSnapshot.documents as [QueryDocumentSnapshot]{
                if(query.data()["uid"] as? String == defaultUser.uid){
                    let file = File()
                    file.id = query.documentID
                    file.uid = query.data()["uid"] as! String?
                    file.name = query.data()["name"] as! String?
                    file.details = query.data()["details"] as! String?
                    file.packageID = packageID
                    file.fileType = query.data()["fileType"] as! Int?
                    file.fileName = query.data()["fileName"] as! String?
                    fileList.append(file)
                }
            }
        }
        for i in fileList{
            i.printFile()
        }
        
        packagesRef?.addSnapshotListener{
            [self] (querySnapshot, error) in
                
            // Ensure snapshot is valid
            // Get out the first element from the collection which is team
            guard let packageSnapshot = querySnapshot else{
                print("Unable to load package =================== ")
                return
            }
            
            for query in packageSnapshot.documents as [QueryDocumentSnapshot]{
                if(query.data()["uid"] as? String == defaultUser.uid){
                    let package = Package()
                    package.id = query.documentID
                    package.uid = query.data()["uid"] as! String?
                    package.name = query.data()["name"] as! String?
                    package.previousPackageID = query.data()["previousPackageID"] as! String?
                    packageList.append(package)
                    
                }
            }
                
            self.parsePackageSnapshot(snapshot: packageSnapshot, packageID: packageID)
            
        }

    }
    
   
    
    
    
    func parsePackageSnapshot(snapshot: QuerySnapshot, packageID: String) {
        print("Parse Packages =================")
                
        let package = Package()
        for query in snapshot.documents as [QueryDocumentSnapshot]{
            if(query.documentID == packageID){
                package.id = query.documentID
                package.name = query.data()["name"] as! String?
                package.uid = query.data()["uid"] as! String?
                package.previousPackageID = query.data()["previousPackageID"] as! String?
                
                // Parse file list in the current package
                for reference in query.data()["files"] as! [DocumentReference]{
                    let file = getFileByID(reference.documentID)
                    file?.packageID = currentPackage.id
                    package.files.append(file!)
                }
                
                // Parse package list in the current pakcage
                for reference in query.data()["packages"] as! [DocumentReference]{
                    package.packages.append(getPackageByID(reference.documentID)!)
                }
            }
        }
        
        self.currentPackage = package
            
        // Reflect to listeners
        listeners.invoke{
            (listener) in
            if listener.listenerType == ListenerType.file ||
                listener.listenerType == ListenerType.all {
                listener.onFileChange(change: .update, files: currentPackage.files)
            }
            if listener.listenerType == ListenerType.package ||
                listener.listenerType == ListenerType.all {
                listener.onPackageChange(change: .update, packages: currentPackage.packages)
            }
        }
        print("Set Up Package =================== To the end ")
    }
}

extension FirebaseController {
    
    // Firebase Controller Specific Methods
    func getFileByID(_ id: String) -> File?{
        for file in fileList{
            if file.id == id{
                return file
            }
        }
        return nil
    }
    
    func getPackageByID(_ id: String) -> Package?{
        for package in packageList{
            if package.id == id{
                return package
            }
        }
        return nil
    }
    
    func addDataToStorage(data: String) -> String{
        return ""
    }
    
    func addFile(name: String, fileType: FileType, fileName: String, details: String) -> File {
        print("Add File ==========")
        // Create a file object and setting the attributes
        let currentFile = File()
        currentFile.name = name
        currentFile.uid = defaultUser.uid
        currentFile.packageID = currentPackage.id
        currentFile.fileType = fileType.rawValue
        currentFile.fileName = fileName
        currentFile.details = details
        // Add the file to Fire Store
        // Using encoding and decoding methods in Codable which should be protected by do catch statement
        if let fileRef = filesRef?.addDocument(
            data: ["name" : name,
                   "uid" : currentUser?.uid as Any,
                   "packageID" : currentPackage.id as Any,
                   "fileType" : currentFile.fileType as Any,
                   "fileName" : currentFile.fileName as Any,
                   "details" : currentFile.details as Any]) {
            currentFile.id = fileRef.documentID
            }
//        ["id" : "",
//                  "body" : data,
//                  "description" : "",
//                  "createdDate" : ""]
        return currentFile
    }
    
    func deleteFile(file: File) {
        print("Delete File ==========")
        if let fileID = file.id{
            filesRef?.document(fileID).delete()
        }
        
        // Delete from fire storage
    }
    

    func addPackage(packageName: String, uid: String, prePackageID: String) -> Package {
        print("Add Package ==========")
        let package = Package()
        package.name = packageName
        package.uid = uid
        package.previousPackageID = prePackageID
        // Contains a Document ID and other information
        if let packageRef = packagesRef?.addDocument(
            data: ["name" : packageName,
                   "uid":currentUser?.uid as Any,
                   "previousPackageID": prePackageID,
                   "files":[],
                   "packages":[]]) {
            package.id = packageRef.documentID
        }
        packageList.append(package)
        return package
    }
    
    func deletePackage(package: Package) {
        print("Delete Package ==========")
        if let packageID = package.id{
            packagesRef?.document(packageID).delete()
        }
    }
    
    func addUser(name: String) -> User {
        print("Add User ==========")
        // Create a file object and setting the attributes
        let user = User()
        user.name = name
        user.uid = currentUser!.uid
        user.email = currentUser?.email
        
        // Setup Root Package
        rootPackage = addPackage(packageName: "Root", uid: user.uid!, prePackageID: "")
        
        // Setup Profile Package
        let MyMusicPackage = addPackage(packageName: "My Music", uid: user.uid!, prePackageID: rootPackage.id!)
        let MyVideoPackage = addPackage(packageName: "My Video", uid: user.uid!, prePackageID: rootPackage.id!)
        let MyImagePackage = addPackage(packageName: "My Image", uid: user.uid!, prePackageID: rootPackage.id!)
        _ = addPackageToPackage(newPackage: MyMusicPackage, package: rootPackage)
        _ = addPackageToPackage(newPackage: MyVideoPackage, package: rootPackage)
        _ = addPackageToPackage(newPackage: MyImagePackage, package: rootPackage)
        // Set More Package ...
        
        
        user.root = rootPackage.id
        // Add the user to Fire Store
        do {
            // Using encoding and decoding methods in Codable which should be protected by do catch statement
            if let userRef = try usersRef?.addDocument(from: user) {
                user.id = userRef.documentID
                
            }
        } catch {
            // deletePackage(package: getPackageByID(defaultUser.root!)!)
            print("Failed to serialize User")
        }
        return user
    }
    
    func addFileToPackage(file: File, package: Package) -> Bool {
        
        guard let fileID = file.id, let packageID = package.id, package.files.count < 12
        else{
            return false
        }
        
        print("Add File to Package ==================")
        if let newFileRef = filesRef?.document(fileID) {
            packagesRef?.document(packageID).updateData([
                "files" : FieldValue.arrayUnion([newFileRef])
            ])
        }
        
        return true
    }
    
    
    func addPackageToPackage(newPackage:Package, package:Package) -> Bool{
        guard let packageID = newPackage.id,
              let previousPackageID = package.id,
              package.packages.count < 12
        else{
            return false
        }
        
        print("Add Package to Package ==================")
        if let newFileRef = packagesRef?.document(packageID) {
            packagesRef?.document(previousPackageID).updateData([
                "packages" : FieldValue.arrayUnion([newFileRef])
            ])
        }
        return true
    }
    
    func removeFileFromPackage(file: File, package: Package) {
        if package.files.contains(file),let packageID = package.id,let fileID = file.id{
            // Get hero reference from Firestore and remove it
            if let removedFileRef = filesRef?.document(fileID){
                packagesRef?.document(packageID).updateData(
                    ["files" : FieldValue.arrayRemove([removedFileRef])]
                )
            }
        }
    }
    
    func removePackageFromPackage(child: Package, parent: Package) {
        if parent.packages.contains(child),let packageID = parent.id,let childID = child.id{
            // Get hero reference from Firestore and remove it
            if let removedPackageRef = packagesRef?.document(childID){
                packagesRef?.document(packageID).updateData(
                    ["packages" : FieldValue.arrayRemove([removedPackageRef])]
                )
            }
        }
    }
}
