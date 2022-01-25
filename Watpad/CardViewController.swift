import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVFoundation

class CardViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet var handleArea: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var chaptersView: UIView!
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var chaptersTableView: UITableView!
    @IBOutlet weak var musicTableView: UITableView!
    @IBOutlet weak var noMusic: UILabel!
    
    let defaults = UserDefaults.standard
    var selectedChapterRow = 0
    
    let pageString = ["Montserrat", "Times", "Iowan", "Kazimir"]
    let fonts = ["Montserrat-Regular", "Times New Roman", "Palatino", "Kefa"]
    let fontsFamily = ["Montserrat", "Times New Roman", "Palatino", "Kefa"]
    var bookChapters = [JSON]()
    var musicArr = [JSON]()
    var playingTrackID = -1
    var playerState = "pause"
    var fromEdit = false
    
    var player : AVAudioPlayer?
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chaptersTableView.dataSource = self
        chaptersTableView.delegate = self
        fromEdit = defaults.bool(forKey: "FromEdit")
        
        getChapter()
        
        NotificationCenter.default.addObserver(self, selector: #selector(displayEditView), name: Notification.Name("DisplayEditView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayChaptersView), name: Notification.Name("DisplayChaptersView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayMusicView), name: Notification.Name("DisplayMusicView"), object: nil)
        
        pageControl.isEnabled = false
        scrollView.delegate = self
        
        for i in 0..<pageString.count {
            let textView = UILabel()
            textView.text = pageString[i]
            textView.numberOfLines = 0
            textView.textColor = UIColor.black
            textView.textAlignment = .center
            textView.font = UIFont(name: "Montserrat-Medium", size: 18)
            textView.frame = CGRect(x: scrollView.frame.size.width * CGFloat(i), y:0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            scrollView.contentSize.width = scrollView.frame.size.width * CGFloat(i+1)
            scrollView.addSubview(textView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMusic()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if playerState == "play"{
            NotificationCenter.default.post(name: Notification.Name("PlaySPT"), object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch tableView {
        case musicTableView:
            count = musicArr.count
        case chaptersTableView:
            count = bookChapters.count
        default:
            print("Something wrong!")
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch tableView {
        case musicTableView:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "MusicCardViewTableViewCell", for: indexPath) as! MusicCardViewTableViewCell
            cell1.music.text = musicArr[indexPath.row]["track_name"].string
            let time = musicArr[indexPath.row]["duration"].intValue
            let seconds = time % 60
            var minutes = (time / 60) % 60
            if playingTrackID != indexPath.row{
                cell1.playButton.setImage(UIImage(named: "playB"), for: .normal)
            }
            cell1.duration.text = String(format: "%0.2d:%0.2d",minutes,seconds)
            cell1.playButton.tag = indexPath.row
            cell1.playButton.addTarget(self, action: #selector(playAction(sender:)), for: .touchUpInside)
            cell1.deleteButton.tag = indexPath.row
            cell1.deleteButton.addTarget(self, action: #selector(deleteAction(sender:)), for: .touchUpInside)
            if fromEdit == true{
                cell1.deleteButton.alpha = 1.0
            }
            else{
                cell1.deleteButton.alpha = 0.0
            }
            return cell1
        case chaptersTableView:
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "ChaptersInCardViewTableViewCell", for: indexPath) as! ChaptersInCardViewTableViewCell
            if self.preferredLanguage == "en" {
                cell2.titleLabel.text = "Chapter \(indexPath.row+1). " + bookChapters[indexPath.row]["title"].string!
                cell2.audio.text = "attached \(bookChapters[indexPath.row]["audios"].stringValue) audio"
            }
            else if self.preferredLanguage == "ru" {
                cell2.titleLabel.text = "Глава \(indexPath.row+1). " + bookChapters[indexPath.row]["title"].string!
                cell2.audio.text = "прикреплено \(bookChapters[indexPath.row]["audios"].stringValue) аудио"
            }

            if selectedChapterRow == indexPath.row{
                cell2.selectionIndicator.image = UIImage(named: "selectedChapter")
            }
            else{
                cell2.selectionIndicator.image = UIImage(named: "deselectedChapter")
            }
            cell2.goToButton.tag = indexPath.row
            cell2.goToButton.addTarget(self, action: #selector(goToAction(sender:)), for: .touchUpInside)
            return cell2
        default:
            print("Something wrong!")
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let id = indexPath.row
//        print(id)
//        defaults.set(bookChapters[id]["id"], forKey: "SelectedBookChapterID")
//        defaults.set("Глава \(id+1). " + bookChapters[0]["title"].string!, forKey: "SelectedBookChapter")
//        NotificationCenter.default.post(name: Notification.Name("GetText"), object: nil)
//        selectedChapterRow = id
//        chaptersTableView.reloadData()
//    }
    
    @objc func playAction(sender: UIButton){
        let id = sender.tag
        let musicURL = musicArr[id]["audio"].string!
        if id != playingTrackID{
            playingTrackID = id
            if let audioUrl = URL(string: musicURL){
                
                if self.preferredLanguage == "en" {
                    self.showToast(message: "Playback...", font: .systemFont(ofSize: 12.0))
                }
                else if self.preferredLanguage == "ru" {
                    self.showToast(message: "Воспроизведение...", font: .systemFont(ofSize: 12.0))
                }

                
                
                sender.setImage(UIImage(named: "pauseB"), for: .normal)
                playerState = "play"
                musicTableView.reloadData()
                
                // then lets create your document folder url
                let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                // lets create your destination file url
                let destinationUrl = documentsDirectoryURL.appendingPathComponent(musicArr[id]["track_name"].string!+".mp3")
                print(destinationUrl)
                
                // to check if it exists before downloading it
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    print("The file already exists at path")
                    // if the file doesn't exist
                    // set and play music
                    do{
                        try AVAudioSession.sharedInstance().setMode(.default)
                        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                        self.player = try AVAudioPlayer(contentsOf: destinationUrl)
                        
                        guard let player = self.player else{
                            return
                        }
                        
                        player.play()
                    }
                    catch{
                        print("***Error")
                    }
                }
                else {
                    
                    // you can use NSURLSession.sharedSession to download the data asynchronously
                    URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                        guard let location = location, error == nil else { return }
                        do {
                            // after downloading your file you need to move it to your destination url
                            try FileManager.default.moveItem(at: location, to: destinationUrl)
                            print("File moved to documents folder")
                            // set and play music
                            do{
                                try AVAudioSession.sharedInstance().setMode(.default)
                                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                                self.player = try AVAudioPlayer(contentsOf: destinationUrl)
                                
                                guard let player = self.player else{
                                    return
                                }
                                
                                player.play()
                            }
                            catch{
                                print("***Error")
                            }
                            
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    }).resume()
                }
            }
        }
        else{
            if let player = player, player.isPlaying{
                //stop playback
                player.pause()
                sender.setImage(UIImage(named: "playB"), for: .normal)
                playerState = "pause"
            }
            else{
                sender.setImage(UIImage(named: "pauseB"), for: .normal)
                playerState = "play"
                musicTableView.reloadData()
                // set and play music
                self.player?.play()
            }
        }
        
        
    }
    
    
    func playMusicFunction(url: String, id: Int){
        if let player = player, player.isPlaying{
            //stop playback
            player.pause()
        }
        else{
            // set and play music
            if self.player == nil{
                let urlString = Bundle.main.path(forResource: "NF - You're Special", ofType: "mp3")
                
                do{
                    try AVAudioSession.sharedInstance().setMode(.default)
                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                    
                    guard let urlString = urlString else{
                        return
                    }
                    
                    let url = URL(string: "https://muzzona.kz/upload/files/2019-07/jah-khalib-snd_(muzzona.kz).mp3")
                    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    // lets create your destination file url
                    let destinationUrl = documentsDirectoryURL.appendingPathComponent(url!.lastPathComponent)
                    
                    self.player = try AVAudioPlayer(contentsOf: destinationUrl)
                    
                    guard let player = self.player else{
                        return
                    }
                    
                    player.play()
                }
                catch{
                    print("***Error")
                }
            }
            else{
                self.player?.play()
            }
        }
    }
    
    @objc func deleteAction(sender: UIButton){
        let id = sender.tag
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/track/" + musicArr[id]["id"].stringValue, method: .delete, parameters: nil, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                print(json)
                self.getMusic()
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    @objc func goToAction(sender: UIButton){
        let id = sender.tag
        defaults.set(bookChapters[id]["id"].stringValue, forKey: "SelectedBookChapterID")
        if self.preferredLanguage == "en" {
            defaults.set("Chapter \(id+1). " + bookChapters[id]["title"].string!, forKey: "SelectedBookChapter")
        }
        else if self.preferredLanguage == "ru" {
            defaults.set("Глава \(id+1). " + bookChapters[id]["title"].string!, forKey: "SelectedBookChapter")
        }

        
        NotificationCenter.default.post(name: Notification.Name("GetText"), object: nil)
        selectedChapterRow = id
        chaptersTableView.reloadData()
        getMusic()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x/scrollView.frame.width)
        pageControl.currentPage = page
        defaults.set(fonts[page], forKey: "FontName")
        defaults.set(fontsFamily[page], forKey: "FontFamily")
        NotificationCenter.default.post(name: Notification.Name("ChangeFont"), object: nil)
    }
    
    
    @IBAction func pageDidChange(_ sender: UIPageControl) {
        print(sender.currentPage)
    }
    
    @objc func displayEditView (notification: NSNotification){
        editView.alpha = 1.0
        chaptersView.alpha = 0.0
        musicView.alpha = 0.0
        
    }
    
    @objc func displayChaptersView (notification: NSNotification){
        editView.alpha = 0.0
        chaptersView.alpha = 1.0
        musicView.alpha = 0.0
        
    }
    
    @objc func displayMusicView (notification: NSNotification){
        editView.alpha = 0.0
        chaptersView.alpha = 0.0
        musicView.alpha = 1.0
        
    }
    
    @IBAction func blackButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("Black"), object: nil)
    }
    
    @IBAction func whiteButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("White"), object: nil)
    }
    
    @IBAction func minusButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("Minus"), object: nil)
    }
    
    @IBAction func plusButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("Plus"), object: nil)
    }
    
    @IBAction func sliderDidChanged(_ sender: UISlider) {
        let currentValue = CGFloat(sender.value)
        UIScreen.main.brightness = CGFloat(currentValue)
    }
    
    func getChapter(){
        bookChapters = []
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/chapter/" + defaults.string(forKey: "SelectedBookID")!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json != nil{
                    self.bookChapters = json!.arrayValue
//                    print(self.bookChapters)
                    self.chaptersTableView.reloadData()
                }
            case .failure(let error):
                print(error)
                if self.preferredLanguage == "en" {
                    let alert = UIAlertController(title: "Sorry", message: "Internet connection error ... Check your connection or try again later!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    self.present(alert, animated: true)
                } else if self.preferredLanguage == "ru" {
                    let alert = UIAlertController(title: "Извините", message: "Ошибка соединения с интернетом… Проверьте соединение или повторите чуть позднее!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func getMusic(){
        musicArr = []
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/track/" + defaults.string(forKey: "SelectedBookChapterID")!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json != nil{
                    self.musicArr = json!.arrayValue
                    print(self.musicArr)
                    self.musicTableView.reloadData()
                    if self.musicArr.count == 0{
                        self.noMusic.alpha = 1.0
                    }
                    else{
                        self.noMusic.alpha = 0.0
                    }
                }
            case .failure(let error):
                print(error)
                if self.preferredLanguage == "en" {
                    let alert = UIAlertController(title: "Sorry", message: "Internet connection error ... Check your connection or try again later!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    self.present(alert, animated: true)
                } else if self.preferredLanguage == "ru" {
                    let alert = UIAlertController(title: "Извините", message: "Ошибка соединения с интернетом… Проверьте соединение или повторите чуть позднее!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height - 100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        toastLabel.alpha = 0.0
        UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseOut, animations: {
             toastLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

}

