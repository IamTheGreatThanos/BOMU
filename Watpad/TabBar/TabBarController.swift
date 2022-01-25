import FloatingTabBarController
import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class TabBarController: FloatingTabBarController {
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if defaults.bool(forKey: "isChooseLang") != true{
//            let refreshAlert = UIAlertController(title: "Внимание! \n Attention!", message: "Выберите язык. \n  Choose Language.", preferredStyle: UIAlertController.Style.alert)
//
//            refreshAlert.addAction(UIAlertAction(title: "Русский", style: .default, handler: { (action: UIAlertAction!) in
//                  print("Rus")
////                defaults.set(true, forKey: "isChooseLang")
//            }))
//
//            refreshAlert.addAction(UIAlertAction(title: "English", style: .default, handler: { (action: UIAlertAction!) in
//                  print("Eng")
//            }))
//
//            present(refreshAlert, animated: true, completion: nil)
//        }
        
        tabBarInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func tabBarInit(){
        let color = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        let imagesArrLarge = [#imageLiteral(resourceName: "TabIcon1_55"),#imageLiteral(resourceName: "TabIcon2_55"),#imageLiteral(resourceName: "TabIcon3_55")]
        let imagesArrSmall = [#imageLiteral(resourceName: "TabIcon1_45"),#imageLiteral(resourceName: "TabIcon2_45"),#imageLiteral(resourceName: "TabIcon3_45")]
        
        var count = 0

        tabBar.tintColor = #colorLiteral(red: 0.3294117647, green: 0.3294117647, blue: 0.3294117647, alpha: 1)
        tabBar.backgroundColor = #colorLiteral(red: 0.9136260152, green: 0.9137827754, blue: 0.9136161804, alpha: 1)
        
        let layerGradient = CAGradientLayer()
        layerGradient.colors = [#colorLiteral(red: 0.368627451, green: 0.09019607843, blue: 0.9215686275, alpha: 1), #colorLiteral(red: 1, green: 0.568627451, blue: 0.3019607843, alpha: 1)]
        layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layerGradient.frame = tabBar.bounds
        tabBar.layer.addSublayer(layerGradient)
        
        viewControllers = (1...3).map { "Tab\($0)" }.map {
            let selected = imagesArrLarge[count]
            let normal = imagesArrSmall[count]
            let controller = storyboard!.instantiateViewController(withIdentifier: $0)
            controller.title = $0

            controller.view.backgroundColor = color[count]
            count  = count + 1
            controller.floatingTabItem = FloatingTabItem(selectedImage: selected, normalImage: normal)
            return controller
        }
    }
    
    
}



