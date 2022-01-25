import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class EditMyBookChaptersController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    
    @IBOutlet weak var mainTableView: UITableView!
    
    let defaults = UserDefaults.standard
    var bookInfo = JSON()
    
    var bookChapters = [JSON]()
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jsonStr = defaults.string(forKey: "AboutBookInfo")!
        if jsonStr != "" {
            if let json = jsonStr.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                do {
                    bookInfo = try JSON(data: json)
                    bookTitle.text = bookInfo["title"].string
                    bookImage.kf.setImage(with: URL(string: bookInfo["photo_url"].string!))
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
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookChapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyBookChapterTableViewCell", for: indexPath) as! MyBookChapterTableViewCell
        
        if self.preferredLanguage == "en" {
            cell.chapter.text = "Chapter \(indexPath.row+1). " + bookChapters[indexPath.row]["title"].string!
            cell.music.text = "attached \(bookChapters[indexPath.row]["audios"].stringValue) audio"
        }
        else if self.preferredLanguage == "ru" {
            cell.chapter.text = "Глава \(indexPath.row+1). " + bookChapters[indexPath.row]["title"].string!
            cell.music.text = "прикреплено \(bookChapters[indexPath.row]["audios"].stringValue) аудио"
        }
        cell.editButton.tag = indexPath.row
        cell.editButton.addTarget(self, action: #selector(editButtonAction(sender:)), for: .touchUpInside)
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteChapterAction(sender:)), for: .touchUpInside)
        return cell
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//       let id = indexPath.row
//    }
    
    @objc func editButtonAction(sender: UIButton){
        let id = sender.tag
        
        if self.preferredLanguage == "en" {
            defaults.set("Chapter \(id+1). " + bookChapters[id]["title"].string!, forKey: "SelectedBookChapter")
        }
        else if self.preferredLanguage == "ru" {
            defaults.set("Глава \(id+1). " + bookChapters[id]["title"].string!, forKey: "SelectedBookChapter")
        }
        defaults.set(bookChapters[id]["id"].stringValue, forKey: "SelectedBookChapterID")
        defaults.set(bookInfo["id"].stringValue, forKey: "SelectedBookID")
        defaults.set(true, forKey: "FromEdit")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"EditTextController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
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
    
    func createChapterRequest(chapter: String){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        let parameters = ["title" : chapter]
        
        AF.request(GlobalVariables.url + "books/chapter/" + bookInfo["id"].stringValue, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json != nil{
                    if json!["status"].string == "ok"{
                        self.getChapter()
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
    
    
    func createChapterAction(){
        if self.preferredLanguage == "en" {
            let alert = UIAlertController(title: "Chapter", message: "Enter the title of the chapter:", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = ""
                textField.autocapitalizationType = .sentences
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields![0]
                if textField.text != "" {
                    self.createChapterRequest(chapter: textField.text!)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in }))
            self.present(alert, animated: true, completion: nil)
        }
        else if self.preferredLanguage == "ru" {
            let alert = UIAlertController(title: "Глава", message: "Введите название главы:", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = ""
                textField.autocapitalizationType = .sentences
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields![0]
                if textField.text != "" {
                    self.createChapterRequest(chapter: textField.text!)
                }
            }))
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: {_ in }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteChapter(id: Int){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/chapter/" + bookChapters[id]["id"].stringValue, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json != nil{
                    if json!["status"].string == "ok"{
                        self.getChapter()
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
    
    @objc func deleteChapterAction(sender: UIButton){
        let id = sender.tag
        
        if self.preferredLanguage == "en" {
            let alert = UIAlertController(title: "Attention!", message: "Do you want to delete a chapter?", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.deleteChapter(id: id)
            }))

            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            }))

            present(alert, animated: true, completion: nil)
        }
        else if self.preferredLanguage == "ru" {
            let alert = UIAlertController(title: "Внимание!", message: "Вы хотите удалить главу?", preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action: UIAlertAction!) in
                self.deleteChapter(id: id)
            }))

            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: { (action: UIAlertAction!) in
            }))

            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func createChapter(_ sender: UIButton) {
        createChapterAction()
    }
    
    @IBAction func createChapterIcon(_ sender: UIButton) {
        createChapterAction()
    }
    
    
    @IBAction func publishButton(_ sender: UIButton) {
        if bookChapters.count != 0{
            defaults.set(bookInfo["id"].stringValue, forKey: "SelectedBookID")
            defaults.set(bookInfo["title"].stringValue, forKey: "SelectedBookTitle")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"CategoryController")
            self.navigationController?.pushViewController(viewController,
            animated: true)
        }
        else{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Sorry", message: "Create at least one chapter.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Извините", message: "Создайте хоть одну главу.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
