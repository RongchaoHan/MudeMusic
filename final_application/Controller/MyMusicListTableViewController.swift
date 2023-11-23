//
//  TasksTableViewController.swift
//  final_application
//
//  Created by Rongchao Han on 11/5/2022.
//

import UIKit

class MyMusicListTableViewController: UITableViewController{

    // Property
    let SECTION_SONG_LIST = 0
    let CELL_LIST = "listCell"
    
    // Variable
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .package
    var musics:[File] = []
    var lists:[Package] = []
    var currentAlbum: Package?
    
    // Web Service - The Audio DB
    let headers = [
        "X-RapidAPI-Key": "690a61c5ddmsh649afec04ed866cp1281ffjsn9a8919dfff98",
        "X-RapidAPI-Host": "deezerdevs-deezer.p.rapidapi.com"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Configure the View
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LIST, for: indexPath)

        // Configure the cell...
        var content = cell.defaultContentConfiguration()
        content.text = lists[indexPath.row].name
        content.textProperties.font = UIFont.preferredFont(forTextStyle: .headline)
        
        content.secondaryText = "\(lists[indexPath.row].files.count)  songs in \(String(describing: lists[indexPath.row].name))"
        content.secondaryTextProperties.color = UIColor.gray
        cell.contentConfiguration = content
        
        return cell
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentAlbum = lists[indexPath.row]
        //performSegue(withIdentifier: "ViewMusicListSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

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
    override func prepare(for segue: UIStoryboardSegue, sender a: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ViewMusicListSegue"{
            let destination = segue.destination as! MusicListTableViewController
            destination.title = currentAlbum?.name
            // destination.musics = currentAlbum!.files
        }
    }
    

}
