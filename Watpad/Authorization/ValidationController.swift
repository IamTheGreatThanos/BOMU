import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class ValidationController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var codeTextField: UITextField!
    
    let defaults = UserDefaults.standard
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeTextField.borderStyle = .none
        codeTextField.setLeftPaddingPoints(30)
        addDoneButtonOnKeyboard()
        codeTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == codeTextField{
            if textField.text!.count == 5{
                codeTextField.text = String(codeTextField.text!.prefix(4))
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        codeTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.view.endEditing(true)
    }
    
    @IBAction func againButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"RegistrationController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        let parameters = ["uid" : String(defaults.string(forKey: "UID")!), "code" : String(codeTextField.text!)]
        AF.request(GlobalVariables.url + "users/email/validate/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
            print(response)
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    self.defaults.set(true, forKey: "isSignIn")
                    self.defaults.set(String(json!["key"].string!), forKey: "Token")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"MainNavigationController")
                    self.present(viewController, animated: true)
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
}
