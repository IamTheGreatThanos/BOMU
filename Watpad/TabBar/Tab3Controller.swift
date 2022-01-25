import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class Tab3Controller: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var ava: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let defaults = UserDefaults.standard
    var isSignIn = false
    let imagePicker = UIImagePickerController()
    
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isSignIn = defaults.bool(forKey: "isSignIn")
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSignIn == true{
            getInfo()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let resizedImage = pickedImage.resizeWithWidth(width: 480)!
            let compressData = pickedImage.jpegData(compressionQuality: 0.0) //max value is 1.0 and minimum is 0.0
            let compressedImage = UIImage(data: compressData!)!
            ava.image = compressedImage
            dismiss(animated: true, completion: nil)
            
            let headers: HTTPHeaders = [
                "Authorization": "Token " + defaults.string(forKey: "Token")!,
                "Accept": "application/json"
            ]
            
            let imgStr = compressData!.base64EncodedString()
            let parameters = ["avatar" : imgStr]
            AF.request(GlobalVariables.url + "users/change/avatar/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                let json = try? JSON(data: response.data!)
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
                }

                if json!["first_name"] != "" || json!["last_name"] != ""{
                    if self.preferredLanguage == "en" {
                        self.nameLabel.text = String("Welcome, " + json!["first_name"].stringValue + " " + json!["last_name"].stringValue + "!")
                    }
                    else if self.preferredLanguage == "ru" {
                        self.nameLabel.text = String("Добро пожаловать, " + json!["first_name"].stringValue + " " + json!["last_name"].stringValue + "!")
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
                
                
//                self.defaults.set(json!["nickname"].string, forKey: "Name")
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
    
    @IBAction func changeAvaButton(_ sender: UIButton) {
        if isSignIn == true{
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func editButton(_ sender: UIButton) {
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
            let viewController = storyboard.instantiateViewController(withIdentifier :"EditProfileController")
            self.navigationController?.pushViewController(viewController,
            animated: true)
        }
    }
    
    
    @IBAction func readingButton(_ sender: UIButton) {
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
            let viewController = storyboard.instantiateViewController(withIdentifier :"ReadingController")
            self.navigationController?.pushViewController(viewController,
            animated: true)
        }
    }
    
    
    @IBAction func favoritesButton(_ sender: UIButton) {
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
            let viewController = storyboard.instantiateViewController(withIdentifier :"NotesController")
            self.navigationController?.pushViewController(viewController,
            animated: true)
        }
    }
    
}

