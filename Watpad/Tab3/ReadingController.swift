import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class ReadingController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var booksCount: UILabel!
    @IBOutlet weak var readingButtonOutlet: UIButton!
    @IBOutlet weak var favoritesButtonOutlet: UIButton!
    @IBOutlet weak var noBooks: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let defaults = UserDefaults.standard
    var books = [JSON]()
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noBooks.alpha = 0.0
        activityIndicator.startAnimating()
        readingButtonOutlet.backgroundColor = #colorLiteral(red: 0.9136260152, green: 0.9137827754, blue: 0.9136161804, alpha: 1)
        getReadedBooks()
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingTableViewCell", for: indexPath) as! ReadingTableViewCell
        cell.bookTitle.text = books[indexPath.row]["title"].string
        cell.bookImage.kf.setImage(with: URL(string: books[indexPath.row]["photo_url"].string!))
        cell.viewsCount.text = books[indexPath.row]["views"].stringValue
        cell.bookDes.text = books[indexPath.row]["about"].string
        if GlobalVariables.favorites.contains(books[indexPath.row]["id"].int!){
            cell.favoriteButton.setImage(#imageLiteral(resourceName: "favorite-active"), for: .normal)
        }
        else{
            cell.favoriteButton.setImage(#imageLiteral(resourceName: "ProfileButton1"), for: .normal)
        }
        cell.favoriteButton.tag = books[indexPath.row]["id"].int!
        cell.favoriteButton.addTarget(self, action: #selector(favoriteAction(sender:)), for: .touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = indexPath.row
        defaults.set(books[id].rawString(), forKey: "AboutBookInfo")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"BookInfoController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    @objc func favoriteAction(sender: UIButton){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
          "Accept": "application/json"
        ]
        let parameters = ["id" : String(sender.tag)]
        AF.request(GlobalVariables.url + "books/favs/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    if sender.image(for: .normal) == #imageLiteral(resourceName: "favorite-active") {
                        sender.setImage(#imageLiteral(resourceName: "ProfileButton1"), for: .normal)
                        GlobalVariables.favorites.remove(at: GlobalVariables.favorites.firstIndex(of: sender.tag)!)
                    }
                    else{
                        sender.setImage(#imageLiteral(resourceName: "favorite-active"), for: .normal)
                        GlobalVariables.favorites.append(sender.tag)
                    }
                    self.mainTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    @IBAction func readingButton(_ sender: UIButton) {
        readingButtonOutlet.backgroundColor = #colorLiteral(red: 0.9136260152, green: 0.9137827754, blue: 0.9136161804, alpha: 1)
        favoritesButtonOutlet.backgroundColor = .clear
        activityIndicator.startAnimating()
        activityIndicator.alpha = 1.0
        getReadedBooks()
        
    }
    
    @IBAction func favoritesButton(_ sender: UIButton) {
        readingButtonOutlet.backgroundColor = .clear
        favoritesButtonOutlet.backgroundColor = #colorLiteral(red: 0.9136260152, green: 0.9137827754, blue: 0.9136161804, alpha: 1)
        activityIndicator.startAnimating()
        activityIndicator.alpha = 1.0
        getFavoriteBooks()
    }
    
    func getFavoriteBooks(){
        books = []
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/favs/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                self.books = json!.arrayValue
                self.mainTableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0.0
                if self.preferredLanguage == "en" {
                    self.booksCount.text = "Found: \(self.books.count) books"
                }
                else if self.preferredLanguage == "ru" {
                    self.booksCount.text = "Найдено: \(self.books.count) книг"
                }
                
                if self.books.count == 0{
                    self.noBooks.alpha = 1.0
                }
                else{
                    self.noBooks.alpha = 0.0
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
    
    func getReadedBooks(){
        books = []
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/i/read/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                self.books = json!.arrayValue
                self.mainTableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0.0
                if self.preferredLanguage == "en" {
                    self.booksCount.text = "Found: \(self.books.count) books"
                }
                else if self.preferredLanguage == "ru" {
                    self.booksCount.text = "Найдено: \(self.books.count) книг"
                }
                if self.books.count == 0{
                    self.noBooks.alpha = 1.0
                }
                else{
                    self.noBooks.alpha = 0.0
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
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

