import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import FBSDKLoginKit
import FBSDKCoreKit

class RegistrationController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let defaults = UserDefaults.standard
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginTextField.borderStyle = .none
        loginTextField.setLeftPaddingPoints(60)
        passwordTextField.borderStyle = .none
        passwordTextField.setLeftPaddingPoints(60)
        passwordTextField.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: Facebook Login Manager
    
    func getFacebookUserInfo(){
        let loginManager = LoginManager()
        if let _ = AccessToken.current {
            
            loginManager.logOut()
            
        } else {
            loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] (result, error) in
                guard error == nil else {
                    // Error occurred
                    print(error!.localizedDescription)
                    return
                }
                // Check for cancel
                guard let result = result, !result.isCancelled else {
                    print("User cancelled login")
                    return
                }
                // Successfully logged in
                Profile.loadCurrentProfile { (profile, error) in
//                    self?.updateMessage(with: Profile.current?.name)
//                    print(Profile.current?.name)
                    if let token = AccessToken.current, !token.isExpired {
                        // User is logged in, do work such as go to next view controller.
                        self!.sendFBToken(accessToken: token.tokenString)
                    }
                }
            }
        }
    }
    
    func sendFBToken(accessToken: String){
        let parameters = ["access_token" : accessToken]
        AF.request(GlobalVariables.url + "users/oauth/login/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
            let json = try? JSON(data: response.data!)
            print(json)
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    self.defaults.set(true, forKey: "isSignIn")
                    self.defaults.set(json!["email"].string!, forKey: "Login")
                    self.defaults.set(String(json!["uid"].int!), forKey: "UID")
                    self.defaults.set(json!["key"].string!, forKey: "Token")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"MainNavigationController")
                    self.present(viewController, animated: true)
                }
                else{
                    if self.preferredLanguage == "en" {
                        let alert = UIAlertController(title: "Attention!", message: "Something went wrong ... Please try again later!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    } else if self.preferredLanguage == "ru" {
                        let alert = UIAlertController(title: "Внимание!", message: "Что-то пошло не так... Повторите попытку чуть позже!", preferredStyle: .alert)
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
    
    @IBAction func loginButton(_ sender: Any) {
        if passwordTextField.text!.count > 7{
            let parameters = ["email" : String(loginTextField.text!), "password" : String(passwordTextField.text!)]
            AF.request(GlobalVariables.url + "users/register/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
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
                            let alert = UIAlertController(title: "Attention!", message: "You are already registered or entered an impossible login, password!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        else if self.preferredLanguage == "ru" {
                            print("RU")
                            let alert = UIAlertController(title: "Внимание!", message: "Вы уже зарегистрированы или ввели невозможный логин, пароль!", preferredStyle: .alert)
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
        else{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Attention!", message: "Password must contain at least 8 characters!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Внимание!", message: "Пароль должен содержать не менее 8 символов!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        
    }
    
    @IBAction func facebookButton(_ sender: Any) {
        getFacebookUserInfo()
    }
    
    
    
    @IBAction func signInApple(_ sender: UIButton) {
        
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

