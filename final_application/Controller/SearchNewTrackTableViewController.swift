//
//  SearchNewTrackTableViewController.swift
//  final_application
//
//  Created by Michael Choi on 12/6/22.
//
import Foundation
import UIKit
import CoreData

class SearchNewTrackTableViewController: UITableViewController {

    // Property
    let headers = [
        "X-RapidAPI-Key": "690a61c5ddmsh649afec04ed866cp1281ffjsn9a8919dfff98",
        "X-RapidAPI-Host": "deezerdevs-deezer.p.rapidapi.com"
    ]
    let CELL_TRACK = "trackCell"
    
    
    // Variable
    weak var coreDataController: CoreDataListener?
    var musicListenerType = ListenerType.music
    var listenerType = ListenerType.file
    var indicator = UIActivityIndicatorView()
    var listeners = MulticastDelegate<CoreDataListener>()
    
    //var persistentContainer : NSPersistentContainer
    //var allTracksFetchedResultsController: NSFetchedResultsController<Music>?
    
    
    var playList: Package?
    var tracks: [Track] = []
    var playingTracks:[Music] = []
    var covers: [UIImage] = []
    var trackIndex: Int?
    var imageIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        coreDataController = appDelegate?.coreDataController as? CoreDataController
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController

        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:view.safeAreaLayoutGuide.centerYAnchor)
        ])
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coreDataController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coreDataController?.removeListener(listener: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tracks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_TRACK, for: indexPath)

        // Configure the cell...
        let track = tracks[indexPath.row]
        var content = cell.defaultContentConfiguration()
        
        content.text = track.name
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        content.secondaryText = track.artist
        if(indexPath.row < covers.count){
            content.image = resizeImage(image: covers[indexPath.row], targetSize: CGSize.init(width: 100.0, height: 100.0))
            
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for track in playingTracks{
            if tracks[indexPath.row].url == track.url{
                self.trackIndex = playingTracks.firstIndex(of: track)
                performSegue(withIdentifier: "MusicPreviewSegue", sender: self)
                tableView.deselectRow(at: indexPath, animated: true)
                return
            }
        }
        let currentMusic = coreDataController!.addTrack(track: tracks[indexPath.row])
        playingTracks.append(currentMusic)
        self.trackIndex = playingTracks.count - 1
        performSegue(withIdentifier: "MusicPreviewSegue", sender: self)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "MusicPreviewSegue"{
            let nav = segue.destination as! UINavigationController
            let musicPlayerViewController = nav.topViewController as! MusicPlayerViewController
            if trackIndex != nil{
                musicPlayerViewController.trackIndex = trackIndex!
                musicPlayerViewController.musics = playingTracks
                trackIndex = nil
            }
            
        }
    }
    

}

extension SearchNewTrackTableViewController{
    
    func searchNewTrack(searchText: String) async {
        let searchText = searchText.replacingOccurrences(of: " ", with: "_", options: .literal, range: nil)
        let request = NSMutableURLRequest(url: NSURL(string: "https://deezerdevs-deezer.p.rapidapi.com/search?q=\(searchText)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [self]
            (data, response, error) -> Void in
            
            if (error != nil) {
                print(error as Any)
                return
            } else {
                let httpResponse = response as? HTTPURLResponse
                
                print(httpResponse?.statusCode as Any)
            }
            
            if let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                //print(responseJSON)
                for (i , jsonNode) in responseJSON{
                    if i == "data"{
                        if let array = jsonNode as? [Any]{
                            for j in array{
                                if let node = j as? [String: Any]{
                                    
                                    let artist = node["artist"] as? [String: Any]
                                    let album = node["album"] as? [String: Any]
                                    if album!["cover_xl"] is String{}
                                    else{
                                        continue
                                    }
                                    let track = Track()
                                    
                                    track.name = (node["title_short"] as? String)!
                                    track.image = (album!["cover_xl"] as? String)!
                                    track.url = (node["preview"] as? String)!
                                    track.artist = (artist!["name"] as? String)!
                                    track.duration = (node["duration"] as? Int64)!
                                    
                                    downloadImage(from: URL(string: track.image!)!, to: "cover")
                                    self.tracks.append(track)
                                }
                            }
                        }else{
                            return
                        }
                    }
                }
            }
        
            
            DispatchQueue.main.async { [self] in
                self.indicator.stopAnimating()
                tableView.reloadData()
            }
        })
        dataTask.resume()
        
    }
}

extension SearchNewTrackTableViewController: UISearchBarDelegate{
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("End up Editing ================================")
        tracks.removeAll()
        covers.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text,
              searchText.isEmpty == false else{
            return
        }
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        Task {
            await searchNewTrack(searchText: searchBar.text!)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, to ds: String) {
        //print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            //print(response?.suggestedFilename ?? url.lastPathComponent)
            //print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                if ds == "cover"{
                    print("imageIndex = \(self!.imageIndex)")
                    self!.imageIndex+=1
                    self?.covers.append(UIImage(data: data)!)
                    self!.tableView.reloadData()
                }
            }
        }
    }
}

extension SearchNewTrackTableViewController: CoreDataListener{
    func addMusicToFile(music: Music) -> File { return File() }
    
    func addListener(listener: CoreDataListener) {
        listeners.addDelegate(listener)
        
        if listener.musicListenerType == .music ||
            listener.musicListenerType == .all{
            listener.onMusicChange(musics: playingTracks)
        }
    }
    
    func removeListener(listener: CoreDataListener) {
        listeners.removeDelegate(listener)
    }
    
    func addTrack(track: Track) -> Music {
        return Music()
    }
    
    func cleanup() {}
    
    func onMusicChange(musics: [Music]) {
        print("============= On Music Change")
        self.playingTracks = musics
    }
    
    
}
