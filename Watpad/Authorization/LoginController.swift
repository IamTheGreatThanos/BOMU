import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import FBSDKLoginKit
import FBSDKCoreKit
import AuthenticationServices

@available(iOS 13.0, *)
class LoginController: UIViewController, UITextFieldDelegate {
    
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
                        print(token.tokenString)
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
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        let parameters = ["email" : String(loginTextField.text!), "password" : String(passwordTextField.text!)]
        AF.request(GlobalVariables.url + "users/login/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
            print(response)
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if (json!["status"] == "ok") {
                    self.defaults.set(true, forKey: "isSignIn")
                    self.defaults.set(self.loginTextField.text, forKey: "Login")
                    self.defaults.set(String(json!["uid"].int!), forKey: "UID")
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
    
    @IBAction func recoverButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"PasswordRecoveryController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    @IBAction func facebookButton(_ sender: Any) {
        getFacebookUserInfo()
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier :"RegistrationController")
        self.navigationController?.pushViewController(viewController,
        animated: true)
    }
    
    
    @IBAction func signInApple(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
        else {
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Sorry", message: "Upgrade your iOS to version 13.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Извините", message: "Обновите IOS до 13 версии.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

@available(iOS 13.0, *)
extension LoginController : ASAuthorizationControllerDelegate{
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error")
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.authorizationCode,
            let token = String(data: tokenData, encoding: .utf8)
        else { return }

        let firstName = credential.fullName?.givenName
        let lastName = credential.fullName?.familyName
        
        print(token)
        print(firstName)
        print(lastName)
        
        
    }
}

@available(iOS 13.0, *)
extension LoginController : ASAuthorizationControllerPresentationContextProviding{
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
