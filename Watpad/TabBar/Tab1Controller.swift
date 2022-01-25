import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class Tab1Controller: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var bookCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var bookCountLabel: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noBooks: UILabel!
    @IBOutlet weak var activityIndicator1: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    @IBOutlet weak var ava: UIImageView!
    
    let defaults = UserDefaults.standard
    
    var category = 1
    var topBooks = [JSON]()
    var books = [JSON]()
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(preferredLanguage)
        
        let isSignIn = defaults.bool(forKey: "isSignIn")
        if isSignIn == true{
            getFavorites()
        }
        
        
        searchTextField.borderStyle = .none
        searchTextField.setLeftPaddingPoints(35)
        searchTextField.layer.cornerRadius = 15
        searchTextField.clipsToBounds = true
        
        activityIndicator1.startAnimating()
        activityIndicator2.startAnimating()
        noBooks.alpha = 0.0
        
        getBooksInTop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if defaults.url(forKey: "AvaURL") != nil{
            self.ava.kf.setImage(with: defaults.url(forKey: "AvaURL")!)
        }
        getBooksByCategory()
        getBooksInTop()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        getBooksBySearch()
        return false
    }
    
    // MARK: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItem = 1
        switch collectionView {
        case bookCollectionView:
            numberOfItem = topBooks.count
        case categoryCollectionView:
            numberOfItem = 14
        default:
            print("Something wrong!")
        }
        
        return numberOfItem
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        switch collectionView {
        case bookCollectionView:
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "Tab1BookCollectionViewCell", for: indexPath) as! Tab1BookCollectionViewCell
            cell1.book.text = topBooks[indexPath.row]["title"].string
            cell1.bookImage.kf.setImage(with: URL(string: topBooks[indexPath.row]["photo_url"].string!))
            cell1.views.text = topBooks[indexPath.row]["views"].stringValue
            if GlobalVariables.favorites.contains(topBooks[indexPath.row]["id"].int!){
                cell1.favoriteButton.setImage(#imageLiteral(resourceName: "favorite-active"), for: .normal)
            }
            else{
                cell1.favoriteButton.setImage(#imageLiteral(resourceName: "ProfileButton1"), for: .normal)
            }
            cell1.favoriteButton.tag = topBooks[indexPath.row]["id"].int!
            cell1.favoriteButton.addTarget(self, action: #selector(favoriteAction(sender:)), for: .touchUpInside)
            return cell1
        case categoryCollectionView:
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "Tab1CategoryCollectionViewCell", for: indexPath) as! Tab1CategoryCollectionViewCell
            if self.preferredLanguage == "en" {
                cell2.categoryImage.setBackgroundImage(UIImage(named: "CardEN" + String(indexPath.row+1)), for: .normal)
            }
            else if self.preferredLanguage == "ru" {
                cell2.categoryImage.setBackgroundImage(UIImage(named: "Card" + String(indexPath.row+1)), for: .normal)
            }
            
            cell2.categoryImage.tag = indexPath.row+1
            cell2.categoryImage.addTarget(self, action: #selector(categoryAction(sender:)), for: .touchUpInside)
            return cell2
        default:
            print("Something wrong!")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case bookCollectionView:
            if self.defaults.bool(forKey: "isSignIn") == true{
                let id = indexPath.row
                defaults.set(topBooks[id].rawString(), forKey: "AboutBookInfo")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier :"BookInfoController")
                self.navigationController?.pushViewController(viewController,
                animated: true)
            }
            else{
                if self.preferredLanguage == "en" {
                    let alert = UIAlertController(title: "Attention!", message: "You are not registred! Register?", preferredStyle: UIAlertController.Style.alert)

                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                            self.navigationController?.pushViewController(viewController,
                            animated: true)
                    }))

                    alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                    }))

                    present(alert, animated: true, completion: nil)
                }
                else if self.preferredLanguage == "ru" {
                    let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы! Зарегистрироваться?", preferredStyle: UIAlertController.Style.alert)

                    alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                            self.navigationController?.pushViewController(viewController,
                            animated: true)
                    }))

                    alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { (action: UIAlertAction!) in
                    }))

                    present(alert, animated: true, completion: nil)
                }
                
            }
        case categoryCollectionView:
            print("Category")
        default:
            print("Something wrong!")
        }
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tab1BookTableViewCell", for: indexPath) as! Tab1BookTableViewCell
        cell.bookTitle.text = books[indexPath.row]["title"].string
        cell.bookImage.kf.setImage(with: URL(string: books[indexPath.row]["photo_url"].string!))
        cell.views.text = books[indexPath.row]["views"].stringValue
        cell.bookDesc.text = books[indexPath.row]["about"].string
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
        if self.defaults.bool(forKey: "isSignIn") == true{
            let id = indexPath.row
            defaults.set(books[id].rawString(), forKey: "AboutBookInfo")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"BookInfoController")
            self.navigationController?.pushViewController(viewController,
            animated: true)
        }
        else{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Attention!", message: "You are not registred! Register?", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                        self.navigationController?.pushViewController(viewController,
                        animated: true)
                }))

                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                }))

                present(alert, animated: true, completion: nil)
            }
            else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы! Зарегистрироваться?", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                        self.navigationController?.pushViewController(viewController,
                        animated: true)
                }))

                alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { (action: UIAlertAction!) in
                }))

                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func categoryAction(sender: UIButton){
        category = sender.tag
        getBooksByCategory()
    }
    
    @objc func favoriteAction(sender: UIButton){
        if self.defaults.bool(forKey: "isSignIn") == true{
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
                        self.bookCollectionView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        else{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Attention!", message: "You are not registred! Register?", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                        self.navigationController?.pushViewController(viewController,
                        animated: true)
                }))

                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                }))

                present(alert, animated: true, completion: nil)
            }
            else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы! Зарегистрироваться?", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                        self.navigationController?.pushViewController(viewController,
                        animated: true)
                }))

                alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { (action: UIAlertAction!) in
                }))

                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: Search function
    
    func getBooksBySearch(){
        self.activityIndicator2.startAnimating()
        self.activityIndicator2.alpha = 1.0
        let text = searchTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        var url = GlobalVariables.url + "books/"
        if preferredLanguage == "en"{
            url += "en"
        }
        else{
            url += "ru"
        }
        AF.request(url + "?search=" + text, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { [self] response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                print("Search")
                print(json)
                if json != nil{
                    self.books = json!.arrayValue
                }
                if self.books.count == 0{
                    self.noBooks.alpha = 1.0
                }
                else{
                    self.noBooks.alpha = 0.0
                }
                if books.count == 0{
                    self.heightConstraint.constant = 100
                }
                else{
                    self.heightConstraint.constant = CGFloat(120 * self.books.count)
                }
                if self.preferredLanguage == "en" {
                    self.bookCountLabel.text = "Found: \(self.books.count) books"
                }
                else if self.preferredLanguage == "ru" {
                    self.bookCountLabel.text = "Найдено: \(self.books.count) книг"
                }
                
                self.activityIndicator2.stopAnimating()
                self.activityIndicator2.alpha = 0.0
                mainTableView.reloadData()
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
    
    func getBooksByCategory(){
        self.activityIndicator2.startAnimating()
        self.activityIndicator2.alpha = 1.0
        var url = GlobalVariables.url + "books/"
        if preferredLanguage == "en"{
            url += "en"
        }
        else{
            url += "ru"
        }
        AF.request(url + "?category=" + String(self.category), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { [self] response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                print("Category")
                print(json)
                if json != nil{
                    self.books = json!.arrayValue
                }
                if self.books.count == 0{
                    self.noBooks.alpha = 1.0
                }
                else{
                    self.noBooks.alpha = 0.0
                }
                if books.count == 0{
                    self.heightConstraint.constant = 100
                }
                else{
                    self.heightConstraint.constant = CGFloat(120 * self.books.count)
                }
                
                if self.preferredLanguage == "en" {
                    self.bookCountLabel.text = "Found: \(self.books.count) books"
                }
                else if self.preferredLanguage == "ru" {
                    self.bookCountLabel.text = "Найдено: \(self.books.count) книг"
                }
                self.activityIndicator2.stopAnimating()
                self.activityIndicator2.alpha = 0.0
                mainTableView.reloadData()
            case .failure(let error):
                print(error)
                getBooksByCategory()
            }
        }
    }
    
    
    func getBooksInTop(){
        self.activityIndicator1.startAnimating()
        self.activityIndicator1.alpha = 1.0
        var urlTop = GlobalVariables.url + "books/most/viewed/"
        if preferredLanguage == "en"{
            urlTop += "en"
        }
        else{
            urlTop += "ru"
        }
        AF.request(urlTop, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                print("Top")
                print(json)
                self.topBooks = json!.arrayValue
                self.activityIndicator1.stopAnimating()
                self.activityIndicator1.alpha = 0.0
                self.bookCollectionView.reloadData()
            case .failure(let error):
                print(error)
                self.getBooksInTop()
            }
        }
    }
    
    func getFavorites(){
        GlobalVariables.favorites = []
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/favs/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json != nil{
                    for i in json!.arrayValue{
                        GlobalVariables.favorites.append(i["id"].int!)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

