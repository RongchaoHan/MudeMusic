//
//  RootPackageTableViewController.swift
//  final_application
//
//  Created by Rongchao Han on 30/5/2022.
//

import UIKit
import nanopb

class RootPackageTableViewController: UITableViewController {

    // Variables
    weak var databaseController: DatabaseProtocol?
    
    var listenerType: ListenerType = .all
    var packages: [Package] = []
    var profiles: [Package] = []
    var myMusic: Package = Package()
    var myVideo: Package = Package()
    var myImage: Package = Package()
    var packageTitle: String?
    var subPackageID: String?
    var newPackageTextField: UITextField? = nil
    
    // Properties
    let SECTION_PROFILE = 0
    let SECTION_PACKAGE = 1
    
    let CELL_PROFILE = "profileCell"
    let CELL_PACKAGE = "packageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        navigationItem.title = "Root"
    }

    // MARK: - Table view listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.setupRootPackageListener()
        databaseController?.addListener(listener: self)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        for package in packages{
            if package.id == nil{
                packages.remove(at: packages.firstIndex(of: package)!)
            }
        }
        databaseController?.removeListener(listener: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section{
        case SECTION_PROFILE:
            return profiles.count
        case SECTION_PACKAGE:
            return packages.count-profiles.count
        default:
            return 0
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == SECTION_PROFILE{
            return false
        }
        return true
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == SECTION_PROFILE{
            
            // Configure the cell...
            let cellProfile = tableView.dequeueReusableCell(withIdentifier: CELL_PROFILE, for: indexPath)
            var content = cellProfile.defaultContentConfiguration()
            
            let profile = profiles[indexPath.row]
            content.text = profile.name
            content.secondaryText = profile.uid
            switch profile.name{
            case "My Music":
                content.image = UIImage(systemName: "music.note")
            case "My Video":
                content.image = UIImage(systemName: "video")
            case "My Image":
                content.image = UIImage(systemName: "photo.artframe")
            
            default: break
            }
            
            cellProfile.contentConfiguration = content

            return cellProfile
        }else{
            // Configure the cell...
            let packageCell = tableView.dequeueReusableCell(withIdentifier: CELL_PACKAGE, for: indexPath)
            
            let package = packages[indexPath.row+3]
            if package.id == nil{
                let content = packageCell.defaultContentConfiguration()
                packageCell.contentConfiguration = content
                let textField = UITextField(frame: CGRect(x: 20, y: 0, width: 300, height: 40))
                textField.placeholder = "Enter New Package Name here"
                textField.font = UIFont.systemFont(ofSize: 20)
                if newPackageTextField == nil{
                    newPackageTextField = textField
                    textField.delegate = self
                    packageCell.contentView.addSubview(textField)
                }
            }else{
                var content = packageCell.defaultContentConfiguration()
                content.text = package.name
                content.secondaryText = package.uid
                content.image = UIImage(systemName: "folder")
                packageCell.contentConfiguration = content
                if newPackageTextField != nil{
                    newPackageTextField?.removeFromSuperview()
                    newPackageTextField = nil
                    
                }
            }
            return packageCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == SECTION_PACKAGE{
            let package = packages[indexPath.row+3]
            if package.id == nil{
                newPackageTextField?.becomeFirstResponder()
            }else{
                databaseController!.setupPackagesListener(packageID: package.id!)
                packageTitle = package.name
                subPackageID = package.id
                performSegue(withIdentifier: "SubPackageSegue", sender: self)
            }
        }else if indexPath.section == SECTION_PROFILE{
            let profile = profiles[indexPath.row]
            databaseController!.setupPackagesListener(packageID: profile.id!)
            packageTitle = profile.name
            subPackageID = profile.id
            performSegue(withIdentifier: "SubPackageSegue", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_PACKAGE{
            self.databaseController?.removePackageFromPackage(child: packages[indexPath.row+3], parent: databaseController!.currentPackage)
            self.databaseController?.deletePackage(package: packages[indexPath.row+3])
            self.packages.remove(at: indexPath.row+3)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }else if editingStyle == .delete && indexPath.section == SECTION_PROFILE{
            self.databaseController?.removePackageFromPackage(child: profiles[indexPath.row], parent: databaseController!.currentPackage)
            self.databaseController?.deletePackage(package: profiles[indexPath.row])
            self.profiles.remove(at: indexPath.row)
            self.packages.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_PROFILE {
            return "Profiles"
        }else{
            return "Packages"
        }
    }
    
    @IBAction func addNewPackage(_ sender: Any) {
        if newPackageTextField == nil{
            packages.append(Package())
            tableView.register(MyPackageCell.self, forCellReuseIdentifier: CELL_PACKAGE)
            tableView.reloadData()
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
        // Pass the selected object to the new view controller.
        if(segue.identifier == "SubPackageSegue"){
            let subPackageViewController = segue.destination as! PackageTableViewController
            subPackageViewController.title = self.packageTitle
            subPackageViewController.currentPackageID = self.subPackageID
        }
    }
    

}

extension RootPackageTableViewController : DatabaseListener{
    
    func onPackageChange(change: DatabaseChange, packages: [Package]) {
        print("On Package Change ==========")
        self.packages = packages
        if(self.packages.count >= 3 && self.profiles.count < 3){
            myMusic = packages[0]
            myVideo = packages[1]
            myImage = packages[2]
            self.profiles.append(packages[0])
            self.profiles.append(packages[1])
            self.profiles.append(packages[2])
        }
        tableView.reloadData()
    }
    
    func onMusicChange(change: DatabaseChange, musics: [Music]) {
        // Do nothing
    }
    
    func onFileChange(change: DatabaseChange, files: [File]) {
        // Do nothing
    }
}

extension RootPackageTableViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        if textField.text?.isEmpty == false{
            let package = (databaseController?.addPackage(packageName: textField.text!, uid: (databaseController?.defaultUser.uid)!, prePackageID: databaseController!.currentPackage.id!))!
            _ = databaseController?.addPackageToPackage(newPackage: package, package: databaseController!.currentPackage)
            tableView.reloadData()
        }
        return true
    }
}

class MyPackageCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
