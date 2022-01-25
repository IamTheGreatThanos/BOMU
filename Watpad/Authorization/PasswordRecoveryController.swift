import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class PasswordRecoveryController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginTextField: UITextField!
    
    let defaults = UserDefaults.standard
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginTextField.borderStyle = .none
        loginTextField.setLeftPaddingPoints(20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func nextButton(_ sender: Any) {
        let parameters = ["email" : String(loginTextField.text!)]
        print(parameters)
        AF.request(GlobalVariables.url + "users/password/forget/email/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
            print(response)
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    self.defaults.set(self.loginTextField.text, forKey: "Login")
                    self.defaults.set(String(json!["uid"].int!), forKey: "UID")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"ValidationController")
                    self.navigationController?.pushViewController(viewController,
                    animated: true)
                }
                else{
                    if self.preferredLanguage == "en" {
                        let alert = UIAlertController(title: "Attention!", message: "You are not registered or entered an incorrect username, password!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    else if self.preferredLanguage == "ru" {
                        let alert = UIAlertController(title: "Внимание!", message: "Вы не зарегистрированы или ввели неверный логин, пароль!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                        self.present(alert, animated: true)
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
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"RegistrationController")
        self.present(viewController, animated: true)
    }
}

