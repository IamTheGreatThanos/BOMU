import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class EditProfileController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    
    let defaults = UserDefaults.standard
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.borderStyle = .none
        firstName.setLeftPaddingPoints(30)
        lastName.borderStyle = .none
        lastName.setLeftPaddingPoints(30)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        if firstName.text?.count != 0 && lastName.text?.count != 0{
            let headers: HTTPHeaders = [
                "Authorization": "Token " + defaults.string(forKey: "Token")!,
              "Accept": "application/json"
            ]
            let parameters = ["first_name" : firstName.text!, "last_name" : lastName.text!]
            AF.request(GlobalVariables.url + "users/detail/" + defaults.string(forKey: "UID")!, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { [self] response in
                switch response.result {
                case .success(_):
                    let json = try? JSON(data: response.data!)
                    if (String(json!["id"].int!) == defaults.string(forKey: "UID")!) {
                        self.navigationController?.popViewController(animated: true)
                    }
                    else{
                        if preferredLanguage == "en" {
                            let alert = UIAlertController(title: "Attention!", message: "Something went wrong ... Please try again later!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else if preferredLanguage == "ru" {
                            let alert = UIAlertController(title: "Внимание!", message: "Что-то пошло не так... Повторите попытку чуть позже!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                case .failure(let error):
                    print(error)
                    if preferredLanguage == "en" {
                        let alert = UIAlertController(title: "Sorry", message: "Internet connection error ... Check your connection or try again later!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    } else if preferredLanguage == "ru" {
                        let alert = UIAlertController(title: "Извините", message: "Ошибка соединения с интернетом… Проверьте соединение или повторите чуть позднее!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
        else{
            if preferredLanguage == "en" {
                let alert = UIAlertController(title: "Attention!", message: "Enter your first and last name.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else if preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Внимание!", message: "Введите имя и фамилию.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

