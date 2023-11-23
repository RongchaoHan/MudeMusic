//
//  DatabaseProtocol.swift
//  FIT3178-W02-Lab
//
//  Created by Jason Haasz on 20/3/2022.
//

import Foundation

enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType {
    case file
    case music
    case package
    case authentification
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onPackageChange(change: DatabaseChange, packages: [Package])
    func onFileChange(change: DatabaseChange, files: [File])
    func onMusicChange(change: DatabaseChange, musics: [Music])
}

protocol CoreDataListener: AnyObject{
    var musicListenerType: ListenerType {get set}
    func addListener(listener: CoreDataListener)
    func removeListener(listener: CoreDataListener)
    func addTrack(track:Track) -> Music
    func addMusicToFile(music: Music) -> File
    func cleanup()
    
    func onMusicChange(musics: [Music])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addDataToStorage(data: String) -> String
    func addFile(name: String, fileType: FileType, fileName: String, details: String) -> File
    func deleteFile(file: File)

    var currentPackage:Package {get set}
    var myMusicRef: String? {get}
    var myVideoRef: String? {get}
    var myImageRef: String? {get}
    func addPackage(packageName: String, uid: String, prePackageID: String) -> Package
    func deletePackage(package: Package)

    var defaultUser:User {get}
    var errorMsg:String? {get}
    func userLogIn(email:String, password:String)
    func userRegister(email:String, password:String, username: String)
    func addUser(name: String) -> User
    func userLogOut()

    func setupRootPackageListener()
    func setupPackagesListener(packageID: String)
    func addFileToPackage(file: File, package: Package) -> Bool
    func addPackageToPackage(newPackage:Package, package:Package) -> Bool
    func removeFileFromPackage(file: File, package: Package)
    func removePackageFromPackage(child: Package, parent: Package)
}
