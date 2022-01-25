import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class BookInfoController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookDesc: UILabel!
    @IBOutlet weak var authorNick: UILabel!
    @IBOutlet weak var authorEmail: UILabel!
    @IBOutlet weak var authorAva: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoriteButtonOutlet: UIButton!
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var mainTableView: UITableView!
    
    let defaults = UserDefaults.standard
    var bookInfo = JSON()
    
    var bookChapters = [JSON]()
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    let categoryArr = ["Фентези","Романтика","Приключения","Детектив","Драма","Фантастика","Экшн","Эротика","Юмор","Мистика","Повседневность","Психология","Хоррор","Даркфик"]
    let categoryArrEN = ["Fantasy","Romance","Adventures","Detective","Drama","Fiction","Action","Erotic","Humor","Mystic","Daily life","Psychology","Horror","Darkfic"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jsonStr = defaults.string(forKey: "AboutBookInfo")!
        if jsonStr != "" {
            if let json = jsonStr.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                do {
                    bookInfo = try JSON(data: json)
                    bookTitle.text = bookInfo["title"].string
                    bookDesc.text = bookInfo["about"].string
                    bookImage.kf.setImage(with: URL(string: bookInfo["photo_url"].string!))
                    authorNick.text = bookInfo["author"]["first_name"].string! + " " + bookInfo["author"]["last_name"].string!
                    authorAva.kf.setImage(with: URL(string: bookInfo["author"]["avatar"].string!))
                    authorEmail.text = bookInfo["author"]["email"].string
                    if GlobalVariables.favorites.contains(self.bookInfo["id"].int!){
                        favoriteButtonOutlet.setImage(#imageLiteral(resourceName: "favorite-active"), for: .normal)
                    }
                    else{
                        favoriteButtonOutlet.setImage(#imageLiteral(resourceName: "favorite2"), for: .normal)
                    }
                    mainCollectionView.reloadData()
                    self.getChapter()
                }
                catch{
                    print("Error")
                }
            }
        }
        else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookInfo["category"].arrayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookInfoCollectionViewCell", for: indexPath) as! BookInfoCollectionViewCell
        if self.preferredLanguage == "en" {
            cell.type.text = categoryArrEN[bookInfo["category"][indexPath.row]["id"].int!-1]
        }
        else if self.preferredLanguage == "ru" {
            cell.type.text = categoryArr[bookInfo["category"][indexPath.row]["id"].int!-1]
        }
        return cell
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookChapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookInfoChaptersTableViewCell", for: indexPath) as! BookInfoChaptersTableViewCell
        
        if self.preferredLanguage == "en" {
            cell.chapterTitle.text = "Chapter \(indexPath.row+1). " + bookChapters[indexPath.row]["title"].string!
            cell.audio.text = "attached \(bookChapters[indexPath.row]["audios"].stringValue) audio"
        }
        else if self.preferredLanguage == "ru" {
            cell.chapterTitle.text = "Глава \(indexPath.row+1). " + bookChapters[indexPath.row]["title"].string!
            cell.audio.text = "прикреплено \(bookChapters[indexPath.row]["audios"].stringValue) аудио"
        }
        
        return cell
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//       let id = indexPath.row
//    }
    
    func getChapter(){
        bookChapters = []
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/chapter/" + bookInfo["id"].stringValue, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json != nil{
                    self.bookChapters = json!.arrayValue
                    self.mainTableView.reloadData()
                    if self.bookChapters.count == 0{
                        self.heightConstraint.constant = 60
                    }
                    else{
                        self.heightConstraint.constant = CGFloat(60 * self.bookChapters.count)
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
    
    func addToReading(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        let parameters = ["id" : bookInfo["id"].stringValue]
        
        AF.request(GlobalVariables.url + "books/i/read/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func favoriteButton(_ sender: UIButton) {
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        let parameters = ["id" : bookInfo["id"].stringValue]
        AF.request(GlobalVariables.url + "books/favs/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    if sender.image(for: .normal) == #imageLiteral(resourceName: "favorite-active") {
                        sender.setImage(#imageLiteral(resourceName: "ProfileButton1"), for: .normal)
                        GlobalVariables.favorites.remove(at: GlobalVariables.favorites.firstIndex(of: self.bookInfo["id"].int!)!)
                    }
                    else{
                        sender.setImage(#imageLiteral(resourceName: "favorite-active"), for: .normal)
                        GlobalVariables.favorites.append(self.bookInfo["id"].int!)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    @IBAction func readBookButton(_ sender: UIButton) {
        if self.preferredLanguage == "en" {
            defaults.set("Chapter 1. " + bookChapters[0]["title"].string!, forKey: "SelectedBookChapter")
        }
        else if self.preferredLanguage == "ru" {
            defaults.set("Глава 1. " + bookChapters[0]["title"].string!, forKey: "SelectedBookChapter")
        }
        
        defaults.set(bookChapters[0]["id"].stringValue, forKey: "SelectedBookChapterID")
        defaults.set(false, forKey: "FromEdit")
        addToReading()
        defaults.set(bookInfo["id"].stringValue, forKey: "SelectedBookID")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"TextController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    @IBAction func readAuthorButton(_ sender: UIButton) {
        defaults.set(bookInfo["author"].rawString(), forKey: "AuthorInfo")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"AuthorInfoController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

