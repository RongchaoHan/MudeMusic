//
//  FilesTableViewController.swift
//  final_application
//
//  Created by Rongchao Han on 11/5/2022.
//

import UIKit


class PackageTableViewController: UITableViewController, DatabaseListener{
    
    // Property
    let MUSIC_FILE = 1
    let IMAGE_FILE = 0
    let VIDEO_FILE = 2
    
    // Property
    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    weak var coreDataController: CoreDataListener?
    
    let SECTION_FILE = 1
    let SECTION_PACKAGE = 2
    let SECTION_NEW_ITEM = 0
    let CELL_FILE = "fileCell"
    let CELL_PACKAGE = "packageCell"
    let CELL_NEW_ITEM = "newItemCell"
    
    var packages:[Package] = []
    var files:[File] = []
    var tracks:[Track] = []
    var itemName: String?
    var packageTitle:String?
    var currentPackageID:String?
    var subPackageID: String?
    var imageData: String?
    var fileIndex: Int = -1
    
    var playingTracks:[Music] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        coreDataController = appDelegate?.coreDataController
    }
    
    // MARK: - Table view listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.setupPackagesListener(packageID: currentPackageID!)
        databaseController?.addListener(listener: self)
        
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section{
            case SECTION_FILE:
                return files.count
            case SECTION_PACKAGE:
                return packages.count
            case SECTION_NEW_ITEM:
                return 1
            default:
                return 0
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == SECTION_FILE{
            
            // Configure the cell...
            let fileCell = tableView.dequeueReusableCell(withIdentifier: CELL_FILE, for: indexPath)
            var content = fileCell.defaultContentConfiguration()
            
            let file = files[indexPath.row]
            if file.fileType == FileType.music.rawValue{
                
                content.text = file.name
                let track = addFileToTrack(file: file)

                content.secondaryText = track.artist
                content.image = UIImage(systemName: "music.note")
                print(tracks.count)
                print(files.count)
                if tracks.count < files.count{
                    tracks.append(track)
                }
                
                
            }
            
            fileCell.contentConfiguration = content

            return fileCell
        }else if indexPath.section == SECTION_PACKAGE{
            
            // Configure the cell...
            let packageCell = tableView.dequeueReusableCell(withIdentifier: CELL_PACKAGE, for: indexPath)
            var content = packageCell.defaultContentConfiguration()
            let package = packages[indexPath.row]
            content.text = package.name
            content.secondaryText = package.uid
            content.image = UIImage(systemName: "folder")
            packageCell.contentConfiguration = content
            return packageCell
        }else{
            
            // Configure the cell...
            let newItemCell = tableView.dequeueReusableCell(withIdentifier: CELL_NEW_ITEM, for: indexPath) as! AddNewItemTableViewCell
            newItemCell.delegate = self
            return newItemCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_PACKAGE{
            let package = packages[indexPath.row]
            databaseController!.setupPackagesListener(packageID: package.id!)
            packageTitle = package.name
            subPackageID = package.id
            performSegue(withIdentifier: "SubPackageSegue", sender: self)
        }else if indexPath.section == SECTION_FILE{
            let file = files[indexPath.row]
            if file.fileType == FileType.music.rawValue{
                playingTracks = []
                fileIndex = indexPath.row
                print(tracks.count)
                for t in tracks{
                    playingTracks.append((coreDataController?.addTrack(track: t))!)
                }
                tracks = []
                performSegue(withIdentifier: "MusicPlayerSegue", sender: self)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_FILE{
            
            self.databaseController?.removeFileFromPackage(file: files[indexPath.row], package: databaseController!.currentPackage)
            self.databaseController?.deleteFile(file: files[indexPath.row])
            self.files.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }else if editingStyle == .delete && indexPath.section == SECTION_PACKAGE{
            
            self.databaseController?.removePackageFromPackage(child: packages[indexPath.row], parent: databaseController!.currentPackage)
            self.databaseController?.deletePackage(package: packages[indexPath.row])
            self.packages.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_FILE {
            return "Files"
        }else if section == SECTION_PACKAGE{
            return "Packages"
        }else{
            return "Add New Item"
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if(segue.identifier == "UploadImageFileSegue"){
            let uploadImageFileViewController = segue.destination as! UploadImageFileViewController
            uploadImageFileViewController.username = (databaseController?.defaultUser.name)!
            uploadImageFileViewController.filename = itemName!
            uploadImageFileViewController.delegate = self
        }else if(segue.identifier == "SubPackageSegue"){
            let subPackageViewController = segue.destination as! PackageTableViewController
            subPackageViewController.title = self.packageTitle
            subPackageViewController.currentPackageID = self.subPackageID
        }else if(segue.identifier == "SearchMusicSegue"){
            let searchMusicViewController = segue.destination as! SearchNewTrackTableViewController
            print("Search My Music ============================")
            databaseController?.currentPackage.printPackage()
            searchMusicViewController.playList = databaseController?.currentPackage
            
        }else if(segue.identifier == "MusicPlayerSegue"){
            let nav = segue.destination as! UINavigationController
            let musicPlayerViewController = nav.topViewController as! MusicPlayerViewController
            if fileIndex > -1{
                print(playingTracks.count)
                musicPlayerViewController.trackIndex = fileIndex
                musicPlayerViewController.musics = playingTracks
                fileIndex = -1
            }
        }
        // Pass the selected object to the new view controller.
    }
    
    
}

extension PackageTableViewController {
    func onPackageChange(change: DatabaseChange, packages: [Package]) {
        print("On Package Change ==========")
        self.packages = packages
        tableView.reloadData()
    }
    
    func onFileChange(change: DatabaseChange, files: [File]) {
        print("On File Change ==========")
        self.files = files
        tableView.reloadData()
    }
    
    func onMusicChange(change: DatabaseChange, musics: [Music]) {
        
    }
    
    func addFile(_ newFile: File) -> Bool{
        return databaseController!.addFileToPackage(file: newFile, package: databaseController!.currentPackage)
    }
    
    func addFileToTrack(file: File) -> Track{
        let track = Track()
        track.name = file.name
        track.url = file.fileName
        track.isSubscribed = true
        let data: Data? = file.details?.data(using: .utf8)

        if data != nil{
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [Any]
            for array in json! as [Any]{
                let details = array as! [String: Any]
                track.artist = details["artist"] as? String
                track.image = details["image"] as? String
                track.duration = details["duration"] as? Int64
            }
        }
        return track
    }
    
    
}

extension PackageTableViewController: AddNewItemDelegate{
    
    func didTapButtonMenuItem(withTag: String, itemName: String) {
        self.itemName = itemName
        
        switch withTag{
            
        case "ADD_IMAGE":
            print("add new image is tapped")
            
            performSegue(withIdentifier: "UploadImageFileSegue", sender: self)
            
            return
        case "ADD_MUSIC":
            print("add new music is tapped")
            
            performSegue(withIdentifier: "SearchMusicSegue", sender: self)
            
            return
            
        case "ADD_PACKAGE":
            print("add new package is tapped")
            let newPackage = databaseController?.addPackage(packageName: itemName, uid: (databaseController?.defaultUser.uid)!, prePackageID: databaseController!.currentPackage.id!)
            let result = databaseController?.addPackageToPackage(newPackage: newPackage!, package: databaseController!.currentPackage)
            if result == false{
                print("Failed to add Package into current Package")
            }
            
            return
            
        default:
            return
        }
    }
}

extension PackageTableViewController: UploadImageFileDelegate{
    func didTapSubmitButton(size: String, createdDate: String, description: String) {
        let newFile = databaseController?.addFile(name: itemName!, fileType: FileType.image, fileName: "", details: "")
        let result = databaseController!.addFileToPackage(file: newFile!, package: databaseController!.currentPackage)
        if result == false{
            print("Failed to add File into current Package")
        }
        tableView.reloadData()
    }
    
    @IBAction func unwindToPackage(segue: UIStoryboardSegue){
        
    }
}

