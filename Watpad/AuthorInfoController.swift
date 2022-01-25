import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class AuthorInfoController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var authorAva: UIImageView!
    @IBOutlet weak var authorNick: UILabel!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    let defaults = UserDefaults.standard
    var books = [JSON]()
    var author = JSON()
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jsonStr = defaults.string(forKey: "AuthorInfo")!
        if jsonStr != "" {
            if let json = jsonStr.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                do {
                    author = try JSON(data: json)
                    authorNick.text = author["first_name"].string! + " " + author["last_name"].string!
                    authorAva.kf.setImage(with: URL(string: author["avatar"].string!))
                    getAuthorBooks()
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
    
    // MARK: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AuthorInfoCollectionViewCell", for: indexPath) as! AuthorInfoCollectionViewCell
        cell.bookTitle.text = books[indexPath.row]["title"].string
        cell.bookImage.kf.setImage(with: URL(string: books[indexPath.row]["photo_url"].string!))
        cell.views.text = books[indexPath.row]["views"].stringValue
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
                    self.mainCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getAuthorBooks(){
        books = []
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/user/" + author["id"].stringValue, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                for i in json!.arrayValue{
                    if i["is_published"].bool == true{
                        self.books.append(i)
                    }
                }
                self.mainCollectionView.reloadData()
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
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

