import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class CreateBookController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bookImage: UIImageView!
    
    let defaults = UserDefaults.standard
    let imagePicker = UIImagePickerController()
    
    var selectedImage = ""
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.borderStyle = .none
        titleTextField.layer.cornerRadius = 10
        titleTextField.clipsToBounds = true
        titleTextField.setLeftPaddingPoints(5)
        
        imagePicker.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Описание книги"{
            descTextView.text = ""
            descTextView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.62)
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
            bookImage.image = compressedImage
            dismiss(animated: true, completion: nil)
            
            selectedImage = compressData!.base64EncodedString()
        }
    }
    
    
    @IBAction func chooseImageButton(_ sender: UIButton) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createButton(_ sender: UIButton) {
        if titleTextField.text != nil && descTextView.text != nil && selectedImage != ""{
            let headers: HTTPHeaders = [
                "Authorization": "Token " + defaults.string(forKey: "Token")!,
              "Accept": "application/json"
            ]
            
            var lan = "ru"
            if preferredLanguage == "en"{
                lan = "en"
            }
            
            let parameters = ["photo" : selectedImage, "title" : titleTextField.text!, "about" : descTextView.text!, "language" : lan]
            
            AF.request(GlobalVariables.url + "books/my/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                let json = try? JSON(data: response.data!)
                if json!["status"].string == "ok"{
                    self.navigationController?.popViewController(animated: true)
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
            }
        }
        else{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Sorry", message: "Fill in all the fields!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Извините", message: "Заполните все поля!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

