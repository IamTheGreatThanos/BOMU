import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class NotesController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noBooks: UILabel!
    @IBOutlet weak var notesCount: UILabel!
    
    let defaults = UserDefaults.standard
    var notes = [JSON]()
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noBooks.alpha = 0.0
        activityIndicator.startAnimating()
        getNotes()
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
        cell.bookText.text = notes[indexPath.row]["text"].string
        cell.fromBook.text = notes[indexPath.row]["book"]["title"].string
        if indexPath.row % 2 == 0{
            cell.lineImage.image = UIImage(named: "lineV_green")
        }
        else{
            cell.lineImage.image = UIImage(named: "lineV_blue")
        }
        var countOfEnter = 1
        for i in notes[indexPath.row]["text"].stringValue{
            if i == "\n"{
                countOfEnter += 1
            }
        }
        if countOfEnter <= Int(notes[indexPath.row]["text"].string!.count/36)+1{
            cell.heightConstraint.constant = CGFloat((Int(notes[indexPath.row]["text"].string!.count/36)+2) * 20)
        }
        else{
            cell.heightConstraint.constant = CGFloat(countOfEnter * 20)
        }
        cell.starButton.tag = indexPath.row
        cell.starButton.addTarget(self, action: #selector(starTapped(sender:)), for: .touchUpInside)
        
        return cell
        
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//       let id = indexPath.row
//    }
    
    @objc func starTapped(sender: UIButton)
    {
        let id = sender.tag
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        let parameters = ["id" : notes[id]["id"].stringValue]
        
        AF.request(GlobalVariables.url + "note/my/", method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                self.getNotes()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getNotes(){
        notes = []
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "note/my/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                self.notes = json!.arrayValue
                self.mainTableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.alpha = 0.0
                if self.preferredLanguage == "en" {
                    self.notesCount.text = "Notes(\(self.notes.count))"
                }
                else if self.preferredLanguage == "ru" {
                    self.notesCount.text = "Заметки(\(self.notes.count))"
                }
                if self.notes.count == 0{
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

