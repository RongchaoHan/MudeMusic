//
//  CoreDataController.swift
//  final_application
//
//  Created by Michael Choi on 14/6/22.
//

import Foundation
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate{
    
    // Variable
    var musicListenerType: ListenerType = ListenerType.music
    var listeners = MulticastDelegate<CoreDataListener>()
    var persistentContainer: NSPersistentContainer
    var allTracksFetchedResultsController: NSFetchedResultsController<Music>?
    
    override init(){
        persistentContainer = NSPersistentContainer(name: "final_application")
        persistentContainer.loadPersistentStores() {
            (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack with error: \(error)")
            }
        }
        super.init()
    }
    
    func fetchAllTracks() -> [Music]{
        if allTracksFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Music> = Music.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]

            allTracksFetchedResultsController = NSFetchedResultsController<Music>(
                fetchRequest:fetchRequest, managedObjectContext:
                    persistentContainer.viewContext, sectionNameKeyPath: nil,
                cacheName: nil)

            allTracksFetchedResultsController?.delegate = self
            do {
                try allTracksFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }

        if let tracks = allTracksFetchedResultsController?.fetchedObjects {
            return tracks
        }
        return [Music]()
    }
    
}

extension CoreDataController: CoreDataListener{
    func onMusicChange(musics: [Music]) {}
    
    func addListener(listener: CoreDataListener){
        listeners.addDelegate(listener)
        listener.onMusicChange(musics: fetchAllTracks())
    }
    
    func removeListener(listener: CoreDataListener) {
        listeners.removeDelegate(listener)
    }
    
    func addTrack(track: Track) -> Music{
        let music = NSEntityDescription.insertNewObject(
            forEntityName: "Music",
            into: persistentContainer.viewContext) as! Music
        music.name = track.name
        music.artist = track.artist
        music.image = track.image
        music.duration = track.duration!
        music.url = track.url
        music.isSubscribed = track.isSubscribed
        
        return music
    }
    
    func addMusicToFile(music: Music) -> File{
        let file = File()
        file.name = music.name
        file.fileTypeSelection = FileType.music
        file.fileName = music.url
        let jsonObject = "{ \"artist\" : \"\(music.artist! as String)\"," +
                           "\"duration\" : \(music.duration)," +
                           "\"image\" : \"\(music.image! as String)\"" +
                         "}"
        file.details = "[\(jsonObject)]"
//        let data: Data? = file.details?.data(using: .utf8)
//        do {
//            // make sure this JSON is in the format we expect
//            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [Any]
//
//            print(json as Any)
//            for array in json! as [Any]{
//                let i = array as? [String: Any]
//                print(i!["artist"] as! String)
//            }
//        } catch let error as NSError {
//            print("Failed to load: \(error.localizedDescription)")
//        }
        return file
        
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data with error \(error)")
            }
        }
    }
    
    func controllerDidChangeContent(_ controller:NSFetchedResultsController<NSFetchRequestResult>) {
        listeners.invoke() {
            listener in
            listener.onMusicChange(musics: fetchAllTracks())
        }
    }
    
    func deleteMusic(music: Music){
        persistentContainer.viewContext.delete(music)
    }
}
