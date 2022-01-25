import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class Tab2Controller: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    @IBOutlet weak var ava: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var duringButtonOutlet: UIButton!
    @IBOutlet weak var publishedButtonOutlet: UIButton!
    @IBOutlet weak var noBooks: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let defaults = UserDefaults.standard
    var isSignIn = false
    
    var myBooks = [JSON]()
    var publishedBooks = [JSON]()
    var notPublishedBooks = [JSON]()
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noBooks.alpha = 0.0
        isSignIn = defaults.bool(forKey: "isSignIn")
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        duringButtonOutlet.setImage(#imageLiteral(resourceName: "Ellip1"), for: .normal)
        publishedButtonOutlet.setImage(#imageLiteral(resourceName: "MainButton2"), for: .normal)
        if isSignIn == true{
            getInfo()
            getBooks()
        }
        else{
            activityIndicator.stopAnimating()
            activityIndicator.alpha = 0.0
            noBooks.alpha = 1.0
        }
    }
    
    //MARK: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tab2BookCollectionViewCell", for: indexPath) as! Tab2BookCollectionViewCell
        cell.bookTitle.text = "\"" + myBooks[indexPath.row]["title"].string! + "\""
        cell.bookImage.kf.setImage(with: URL(string: myBooks[indexPath.row]["photo_url"].string!))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.myBooks == self.notPublishedBooks{
            let id = indexPath.row
            defaults.set(myBooks[id].rawString(), forKey: "AboutBookInfo")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"EditMyBookChaptersController")
            self.navigationController?.pushViewController(viewController,
            animated: true)
        }
        else{
            let id = indexPath.row
            defaults.set(myBooks[id].rawString(), forKey: "AboutBookInfo")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"BookInfoController")
            self.navigationController?.pushViewController(viewController,
            animated: true)
        }
    }
    
    //MARK: Functions
    
    func getBooks(){
        publishedBooks = []
        notPublishedBooks = []
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/my/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json?.count == 0{
                    self.noBooks.alpha = 1.0
                }
                else{
                    for i in json!.arrayValue{
                        if i["is_published"].bool == true{
                            self.publishedBooks.append(i)
                        }
                        else{
                            self.notPublishedBooks.append(i)
                        }
                    }
                    self.myBooks = self.notPublishedBooks
                    if self.myBooks.count == 0{
                        self.noBooks.alpha = 1.0
                    }
                    else{
                        self.noBooks.alpha = 0.0
                    }
                    self.mainCollectionView.reloadData()
                }
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0.0
            case .failure(let error):
                print(error)
                self.getBooks()
            }
        }
    }
    
    // MARK: Get Info
    func getInfo(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "users/detail/" + defaults.string(forKey: "UID")!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json!["avatar"].stringValue != String(GlobalVariables.url + "media/default/user.svg"){
                    let url = URL(string: json!["avatar"].stringValue)
                    self.ava.kf.setImage(with: url)
                    self.defaults.set(url, forKey: "AvaURL")
                }

                if json!["first_name"] != "" || json!["last_name"] != ""{
                    if self.preferredLanguage == "en" {
                        self.nameLabel.text = String("Hi, " + json!["first_name"].stringValue + " " + json!["last_name"].stringValue + "!")
                    }
                    else if self.preferredLanguage == "ru" {
                        self.nameLabel.text = String("Привет, " + json!["first_name"].stringValue + " " + json!["last_name"].stringValue + "!")
                    }
                }
                else{
                    if self.preferredLanguage == "en" {
                        self.nameLabel.text = "Welcome, user!"
                    }
                    else if self.preferredLanguage == "ru" {
                        self.nameLabel.text = "Добро пожаловать, пользователь!"
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
    
    //MARK: Buttons
    
    @IBAction func duringButton(_ sender: UIButton) {
        if isSignIn == false{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Attention!", message: "You are not registred! Register?", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                    self.navigationController?.pushViewController(viewController, animated: true)
                }))

                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in}))
                present(alert, animated: true, completion: nil)
            }
            else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы! Зарегистрироваться?", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                    self.navigationController?.pushViewController(viewController, animated: true)
                }))

                alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { (action: UIAlertAction!) in }))

                present(alert, animated: true, completion: nil)
            }
        }
        else{
            duringButtonOutlet.setImage(#imageLiteral(resourceName: "Ellip1"), for: .normal)
            publishedButtonOutlet.setImage(#imageLiteral(resourceName: "MainButton2"), for: .normal)
            self.activityIndicator.startAnimating()
            self.activityIndicator.alpha = 1.0
            self.myBooks = self.notPublishedBooks
            if self.myBooks.count == 0{
                self.noBooks.alpha = 1.0
            }
            else{
                self.noBooks.alpha = 0.0
            }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.alpha = 0.0
            mainCollectionView.reloadData()
        }
    }
    
    @IBAction func publishedButton(_ sender: UIButton) {
        if isSignIn == false{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Attention!", message: "You are not registred! Register?", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                    self.navigationController?.pushViewController(viewController, animated: true)
                }))

                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in}))
                present(alert, animated: true, completion: nil)
            }
            else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы! Зарегистрироваться?", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                    self.navigationController?.pushViewController(viewController, animated: true)
                }))

                alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { (action: UIAlertAction!) in }))

                present(alert, animated: true, completion: nil)
            }
        }
        else{
            duringButtonOutlet.setImage(#imageLiteral(resourceName: "MainButton1"), for: .normal)
            publishedButtonOutlet.setImage(#imageLiteral(resourceName: "Ellip2"), for: .normal)
            self.activityIndicator.startAnimating()
            self.activityIndicator.alpha = 1.0
            self.myBooks = self.publishedBooks
            if self.myBooks.count == 0{
                self.noBooks.alpha = 1.0
            }
            else{
                self.noBooks.alpha = 0.0
            }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.alpha = 0.0
            mainCollectionView.reloadData()
        }
    }
    
    @IBAction func writeNewBook(_ sender: UIButton) {
        if isSignIn == false{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Attention!", message: "You are not registred! Register?", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                    self.navigationController?.pushViewController(viewController, animated: true)
                }))

                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in}))
                present(alert, animated: true, completion: nil)
            }
            else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы! Зарегистрироваться?", preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"LoginController")
                    self.navigationController?.pushViewController(viewController, animated: true)
                }))

                alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { (action: UIAlertAction!) in }))

                present(alert, animated: true, completion: nil)
            }
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"CreateBookController")
            self.navigationController?.pushViewController(viewController,
            animated: true)
        }
    }
}

