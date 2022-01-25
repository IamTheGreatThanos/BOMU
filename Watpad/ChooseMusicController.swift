import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVFoundation
import SafariServices
import AVFoundation

class ChooseMusicController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressText: UILabel!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noMusic: UILabel!
    @IBOutlet weak var colorOutlet1: UIButton!
    @IBOutlet weak var colorOutlet2: UIButton!
    @IBOutlet weak var colorOutlet3: UIButton!
    @IBOutlet weak var colorOutlet4: UIButton!
    @IBOutlet weak var addMusicButton: UIButton!
    
    let defaults = UserDefaults.standard
    var sharedIdentifier = "group.BOMU.shareGroup"
    
    var playerState = "pause"
    var playingTrackID = -1
    var selectedTrackID = -1
    var isColorSelected = -1
    
    var musicURLs = [URL]()
    var musicNames = [String]()
    var musicDurations = [Int]()
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.borderStyle = .none
        searchTextField.setLeftPaddingPoints(35)
        searchTextField.layer.cornerRadius = 15
        searchTextField.clipsToBounds = true
        
        activityIndicator.alpha = 0.0
        noMusic.alpha = 0.0
        progressView.alpha = 0.0
        progressText.alpha = 0.0
        
        fetchData()
        displayMusic()
        
        searchTextField.alpha = 0.0
        searchIcon.alpha = 0.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if playerState == "play"{
            NotificationCenter.default.post(name: Notification.Name("PlaySPT"), object: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func fetchData(){
        let savedata =  UserDefaults.init(suiteName: self.sharedIdentifier)
        if savedata?.value(forKey: "music") != nil {
            let data = (savedata?.value(forKey: "music") as! NSDictionary).value(forKey: "musicData") as! Data
            let str = ((savedata?.value(forKey: "music")as! NSDictionary).value(forKey: "name")as! String)
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = str
//            print(fileName)
            let fileURL = documentsDirectory.appendingPathComponent(fileName+".mp3")
//            print(fileURL)
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    // writes the image data to disk
                    try data.write(to: fileURL, options: [.atomic])
                    print("File saved")
                } catch {
                    print("error saving file:", error)
                }
            }
            else{
                print("File exist!")
            }
                        
        }
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseMusicTableViewCell", for: indexPath) as! ChooseMusicTableViewCell
        cell.music.text = musicNames[indexPath.row]
        let time = musicDurations[indexPath.row]
        let seconds = time % 60
        var minutes = (time / 60) % 60
        cell.time.text = String(format: "%0.2d:%0.2d",minutes,seconds)
        if playingTrackID != indexPath.row{
            cell.playButton.setImage(UIImage(named: "playB"), for: .normal)
        }
        
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(playAction(sender:)), for: .touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = indexPath.row
        selectedTrackID = id
    }
    
    @objc func playAction(sender: UIButton){
        let id = sender.tag
        let musicURL = musicURLs[id]
        if id != playingTrackID{
            playingTrackID = id
            sender.setImage(UIImage(named: "pauseB"), for: .normal)
            playerState = "play"
            mainTableView.reloadData()
            // set and play music
            do{
                try AVAudioSession.sharedInstance().setMode(.default)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
                let url = musicURL
                
                self.player = try AVAudioPlayer(contentsOf: url)
                
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
            if let player = player, player.isPlaying{
                //stop playback
                player.pause()
                sender.setImage(UIImage(named: "playB"), for: .normal)
                playerState = "pause"
            }
            else{
                sender.setImage(UIImage(named: "pauseB"), for: .normal)
                playerState = "play"
                mainTableView.reloadData()
                // set and play music
                if self.player == nil{
                    do{
                        try AVAudioSession.sharedInstance().setMode(.default)
                        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                        
                        let url = musicURL
                        
                        self.player = try AVAudioPlayer(contentsOf: url)
                        
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
    }
    
    @IBAction func addMusicTapped(_ sender: UIButton) {
        if selectedTrackID != -1 && isColorSelected != -1{
            addMusicToChapter()
        }
        else{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Attention!", message: "Choose a music and color!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Внимание!", message: "Выберите песню и цвет!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addMusicToChapter(){
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
        progressView.alpha = 1.0
        progressText.alpha = 1.0
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json",
            "Content-type": "multipart/form-data"
        ]
        
        var rangeArr = [String]()
        rangeArr.append("0")
        rangeArr.append("0")
        
        let url = musicURLs[selectedTrackID]
        
        do{
            let parameters = ["duration" : String(musicDurations[selectedTrackID]), "track_name" : musicNames[selectedTrackID]]
            
            let fileName = url.lastPathComponent
            guard let audioFile: Data = try? Data (contentsOf: url) else {return}
            let request = AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(audioFile, withName: "audio", fileName: fileName, mimeType: "audio/mp3")
                for (key, value) in parameters {
                    multipartFormData.append((value.data(using: String.Encoding.utf8)!), withName: key)
                } //Optional for extra parameters
            }, to: GlobalVariables.url + "books/track/" + defaults.string(forKey: "SelectedBookChapterID")!, method: .post, headers: headers)
            request.validate().responseJSON { (response) in
                switch response.result {
                case .success(_):
                    let json = try? JSON(data: response.data!)
                    if json != nil{
                        if json!["status"] == "ok"{
                            self.setColorToText()
                            self.navigationController?.popViewController(animated: true)
                            self.defaults.set(self.musicNames[self.selectedTrackID] as String, forKey: "MusicName")
                            NotificationCenter.default.post(name: Notification.Name("AddMusicName"), object: nil)
                            self.activityIndicator.alpha = 0.0
                            self.activityIndicator.stopAnimating()
                            self.progressView.setProgress(0.0, animated: true)
                            self.progressView.alpha = 0.0
                            self.progressText.alpha = 0.0
                        }
                    }
                case .failure(let error):
                    print(error)
                    self.activityIndicator.alpha = 0.0
                    self.activityIndicator.stopAnimating()
                    self.progressView.alpha = 0.0
                    self.progressText.alpha = 0.0
                    if self.preferredLanguage == "en" {
                        self.showToast(message: "Uploading error, please try again!", font: .systemFont(ofSize: 12.0))
                    }
                    else if self.preferredLanguage == "ru" {
                        self.showToast(message: "Ошибка загрузки, повторите еще раз!", font: .systemFont(ofSize: 12.0))
                    }
                }
            }
            
            request.uploadProgress(queue: .main, closure: { progress in
                //Current upload progress of file
                self.progressView.setProgress(Float(progress.fractionCompleted), animated: true)
            })
        }
        catch{
            print("Error")
            activityIndicator.alpha = 0.0
            activityIndicator.stopAnimating()
            progressView.alpha = 0.0
            progressText.alpha = 0.0
        }
    }
    
    func displayMusic(){
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
//            print(directoryContents)

            // if you want to filter the directory contents you can do like this:
            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" || $0.pathExtension == "m4a"}
//            print("Music urls:",mp3Files)
            musicURLs = mp3Files
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            musicNames = mp3FileNames
//            print("Music name list:", mp3FileNames)
            for i in musicURLs{
                let asset = AVURLAsset(url: i, options: nil)
                let audioDuration = asset.duration
                let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
                self.musicDurations.append(Int(audioDurationSeconds))
            }
            
            if musicNames.count == 0{
                noMusic.alpha = 1.0
            }
            else{
                noMusic.alpha = 0.0
            }
            mainTableView.reloadData()

        } catch {
            print(error)
        }
    }
    
    
    @IBAction func colorButton1(_ sender: UIButton) {
        sender.borderWidth = 2.0
        sender.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.62)
        colorOutlet2.borderWidth = 0.0
        colorOutlet3.borderWidth = 0.0
        colorOutlet4.borderWidth = 0.0
        defaults.set("1", forKey: "ColorIndex")
        isColorSelected = 1
    }
    
    @IBAction func colorButton2(_ sender: UIButton) {
        sender.borderWidth = 2.0
        sender.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.62)
        colorOutlet1.borderWidth = 0.0
        colorOutlet3.borderWidth = 0.0
        colorOutlet4.borderWidth = 0.0
        defaults.set("2", forKey: "ColorIndex")
        isColorSelected = 1
    }
    
    @IBAction func colorButton3(_ sender: UIButton) {
        sender.borderWidth = 2.0
        sender.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.62)
        colorOutlet2.borderWidth = 0.0
        colorOutlet1.borderWidth = 0.0
        colorOutlet4.borderWidth = 0.0
        defaults.set("3", forKey: "ColorIndex")
        isColorSelected = 1
    }
    
    @IBAction func colorButton4(_ sender: UIButton) {
        sender.borderWidth = 2.0
        sender.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.62)
        colorOutlet2.borderWidth = 0.0
        colorOutlet3.borderWidth = 0.0
        colorOutlet1.borderWidth = 0.0
        defaults.set("4", forKey: "ColorIndex")
        isColorSelected = 1
    }
    
    func setColorToText(){
        NotificationCenter.default.post(name: Notification.Name("ChangeColor"), object: nil)
    }
    
    
    @IBAction func clearButton(_ sender: UIButton) {
        if self.preferredLanguage == "en" {
            let refreshAlert = UIAlertController(title: "Attention!", message: "All music will be deleted, continue?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                for i in self.musicURLs{
                    do{
                        _ = try FileManager.default.removeItem(at: i)
                    }
                    catch{
                        print("Error")
                    }
                }
                self.showToast(message: "Directory cleared!", font: .systemFont(ofSize: 12.0))
                self.displayMusic()
            }))

            present(refreshAlert, animated: true, completion: nil)
        }
        else if self.preferredLanguage == "ru" {
            let refreshAlert = UIAlertController(title: "Внимание!", message: "Вся музыка будет удалена, продолжить?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))

            refreshAlert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                for i in self.musicURLs{
                    do{
                        _ = try FileManager.default.removeItem(at: i)
                    }
                    catch{
                        print("Error")
                    }
                }
                self.showToast(message: "Директория очищена!", font: .systemFont(ofSize: 12.0))
                self.displayMusic()
            }))

            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    
    func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height-100, width: 200, height: 70))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
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

