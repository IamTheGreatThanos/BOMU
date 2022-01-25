import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class WelcomeController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults.bool(forKey: "isChooseLang") != true{
            print("***Allert")
            let refreshAlert = UIAlertController(title: "Внимание! \n Attention!", message: "Выберите язык. \n  Choose Language.", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Русский", style: .default, handler: { (action: UIAlertAction!) in
                  print("Rus")
            }))

            refreshAlert.addAction(UIAlertAction(title: "English", style: .default, handler: { (action: UIAlertAction!) in
                  print("Eng")
            }))

            present(refreshAlert, animated: true, completion: nil)
        }
        else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"MainNavigationController")
            self.present(viewController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}

