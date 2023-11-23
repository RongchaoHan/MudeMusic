//
//  MusicPlayerViewController.swift
//  final_application
//
//  Created by Michael Choi on 11/6/22.
//

import UIKit
import AVFAudio
import AVFoundation

class MusicPlayerViewController: UIViewController {

    // Outlet
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var totalProgressTextLabel: UILabel!
    @IBOutlet weak var currentProgress: UILabel!
    
    // Variable
    weak var coreDataController: CoreDataListener?
    weak var databaseController: DatabaseProtocol?
    var musics: [Music] = []
    var currentMusic: Music?
    var currentCover: UIImage?
    var audioPlayer: AVQueuePlayer?
    var audioPlayerItem: AVPlayerItem?
    var trackIndex: Int = 0
    
    // ProgressBar
    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var previousMusicButton: UIButton!
    @IBOutlet weak var nextMusicButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    // Subscribe Segement control
    @IBOutlet weak var subscribeSegment: UISegmentedControl!
    let SUBSCRIBE_SEG = 1
    let DISSUBSCRIBE_SEG = 0
    
    // Music Queue Order Control
    @IBOutlet weak var repeatCurrentTrackBtn: UIButton!
    @IBOutlet weak var shuffleTrackListBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        coreDataController = appDelegate?.coreDataController as? CoreDataController
        databaseController = appDelegate?.databaseController as? FirebaseController
        
        progressBar.isContinuous = false
        progressBar.addTarget(self, action: #selector(didBeginDraggingSlider), for: .touchDown)
        progressBar.addTarget(self, action: #selector(didEndDraggingSlider), for: .valueChanged)
        // Do any additional setup after loading the view.
        if currentMusic != nil{
            loadingAudioPlayer()
        }else{
            if musics.isEmpty == false{
                currentMusic = musics.first
                loadingAudioPlayer()
            }else{
                dismiss(animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadingAudioPlayer(){
        currentMusic = musics[trackIndex]
        title = currentMusic?.name
        coverImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        
        if shuffleTrackListBtn.isSelected == false{
            repeatCurrentTrackBtn.isSelected = true
        }
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.tag = 10
        
        Task {
            do {
                if currentMusic != nil{
                let url = URL.init(string: (currentMusic?.url)!)
                    
                    if currentMusic?.isSubscribed == true{
                        subscribeSegment.selectedSegmentIndex = SUBSCRIBE_SEG
                    }else{
                        subscribeSegment.selectedSegmentIndex = DISSUBSCRIBE_SEG
                    }
                    
                let session = AVAudioSession.sharedInstance()
                do{
                    try session.setActive(true)
                    try session.setCategory(AVAudioSession.Category.ambient)
                }catch{
                    print(error.localizedDescription)
                }
                
                audioPlayerItem = AVPlayerItem.init(url: url!)
                audioPlayer = AVQueuePlayer.init(playerItem: audioPlayerItem)
                audioPlayer?.play()
                
                startUpdatingPlaybackStatus()
                
                
                let duration = CMTimeGetSeconds(audioPlayer!.currentItem!.asset.duration)
                let currentTime = CMTimeGetSeconds(audioPlayer!.currentTime())
                let minutesDuration = Int(duration) / 60 % 60
                let minutesCurrent = Int(currentTime) / 60 % 60
                let secondsDuration = Int(duration) % 60
                let secondsCurrent = Int(currentTime) % 60
                let strDuration = String(format:"%02d:%02d", minutesDuration, secondsDuration)
                let strCurrent = String(format:"%02d:%02d", minutesCurrent, secondsCurrent)
                
                totalProgressTextLabel.text = strDuration
                currentProgress.text = strCurrent
                

                playButton.setImage(UIImage(systemName: "pause.fill"), for:  .normal)
                playButton.setImage(UIImage(systemName: "play.fill"), for: .highlighted)
                playButton.tag = 20
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, to ds: String) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                if ds == "cover"{
                    self!.currentCover = (UIImage(data: data)!)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        audioPlayer?.pause()
        musics.removeAll()
        currentCover = nil
        
        // audioPlayer?.replaceCurrentItem(with: nil)
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .highlighted)
        playButton.tag = 10
    }
    func startUpdatingPlaybackStatus(){
        _ = audioPlayer!.addPeriodicTimeObserver(
                forInterval: CMTime(value: CMTimeValue(1), timescale: 1),
                queue: DispatchQueue.main
        ) {
            [weak self] (progressTime) in
            
            // print("periodic time: \(CMTimeGetSeconds(progressTime))")
            if self!.audioPlayer?.currentItem != nil {
                self?.updatePlaybackProgress(progressTime: progressTime)

                let currentTime = CMTimeGetSeconds(self!.audioPlayer!.currentTime())
                
                let minutesCurrent = Int(currentTime) / 60 % 60
                let secondsCurrent = Int(currentTime) % 60
                let strCurrent = String(format:"%02d:%02d", minutesCurrent, secondsCurrent)
                self!.currentProgress.text = strCurrent
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: audioPlayer?.currentItem)
    }
    
    func updatePlaybackProgress(progressTime: CMTime){
        progressBar.value = Float(CMTimeGetSeconds(progressTime)/CMTimeGetSeconds((audioPlayer?.currentItem!.duration)!))
        print("Index = \(trackIndex), count = \(musics.count)")
        if currentCover == nil{
            downloadImage(from: URL(string: (currentMusic?.image)!)!, to: "cover")
        }
        if currentCover != nil{
            coverImageView.image = currentCover
        }
        
    }
    
    @IBAction func playPauseMusicDidTapped(_ sender: Any) {
        playPauserButtonImageChange()
    }
    
    func playPauserButtonImageChange(){
        if playButton.tag == 10{
            self.audioPlayer?.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for:  .normal)
            playButton.setImage(UIImage(systemName: "play.fill"), for: .highlighted)
            playButton.tag = 20
            
        }else{
            self.audioPlayer?.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .highlighted)
            playButton.tag = 10
        }
    }

    @objc func didBeginDraggingSlider(){
        if(audioPlayerItem == nil){
            return
        }
        
        audioPlayer?.pause()
        playButton.setImage(UIImage(systemName: "play.fill"), for: .highlighted)
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playButton.tag = 20
    }
    
    @objc func didEndDraggingSlider(){
        if(audioPlayerItem == nil){
            return
        }
        
        let skipTime = progressBar.value * Float.init(CMTimeGetSeconds((audioPlayer?.currentItem!.duration)!))
        let skipTo = CMTime(
            value: CMTimeValue(skipTime),
            timescale: 1
        )
        
        audioPlayer!.seek(to: skipTo)
        audioPlayer?.play()
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .highlighted)
        playButton.tag = 10
    }
    
    @objc func playerDidFinishPlaying(){
        print("Track Finished")
        trackIndex =  trackIndex + 1
        handleTrackActionEvents()
        
    }

    @IBAction func shuffleTracksDidTapped(_ sender: Any) {
        shuffleTrackListBtn.isSelected = true
        repeatCurrentTrackBtn.isSelected = false
    }
    
    @IBAction func nextTrackDidTapped(_ sender: Any) {
        trackIndex =  trackIndex + 1
        handleTrackActionEvents()
    }
    
    @IBAction func preTrackDidTapped(_ sender: Any) {
        if trackIndex > 0{
            trackIndex =  trackIndex - 1
            handleTrackActionEvents()
        }else if musics.count > 1{
            trackIndex = musics.count - 1
            handleTrackActionEvents()
        }
    }
    
    func handleTrackActionEvents(){
        
        if shuffleTrackListBtn.isSelected == false{
            if musics.count > 0{
                if trackIndex >= musics.count{
                    trackIndex = 0
                    currentMusic = musics[trackIndex]
                    currentCover = nil
                }else{
                    currentMusic = musics[trackIndex]
                    currentCover = nil
                }
            }
        }else{
            trackIndex = 0
            musics = musics.shuffled()
            currentMusic = musics[trackIndex]
            shuffleTrackListBtn.isSelected = false
            repeatCurrentTrackBtn.isSelected = true
        }
        self.loadingAudioPlayer()
    }
    
    @IBAction func segmendDidChangedValue(_ sender: Any) {
        if subscribeSegment.isEnabledForSegment(at: SUBSCRIBE_SEG){

            assert((databaseController?.currentPackage) != nil)
            
            let temp = coreDataController!.addMusicToFile(music: currentMusic!)
            let file = databaseController?.addFile(name: temp.name!, fileType: FileType.music, fileName:(currentMusic?.url)!, details: temp.details!)

            _ = databaseController?.addFileToPackage(file: file!, package: databaseController!.currentPackage)
            currentMusic?.isSubscribed = true
        }else{

            assert((databaseController?.currentPackage) != nil)
            
            let files = databaseController!.currentPackage.files
            for currentFile in files{
                if currentFile.name == currentMusic!.name{
                    _ = databaseController!.removeFileFromPackage(file: currentFile, package: databaseController!.currentPackage)
                    currentMusic?.isSubscribed = false
                }
            }
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
