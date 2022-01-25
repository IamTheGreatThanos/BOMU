import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import PayBoxSdk
import WebKit

class CategoryController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebDelegate {
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var book: UILabel!
    @IBOutlet weak var paymentView: PaymentView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    let defaults = UserDefaults.standard
    var selectedBookID = ""
    var currentArr = [Int]()
    
    let categoryArr = ["Фентези","Романтика","Приключения","Детектив","Драма","Фантастика","Экшн","Эротика","Юмор","Мистика","Повседневность","Психология","Хоррор","Даркфик"]
    let categoryArrEN = ["Fantasy","Romance","Adventures","Detective","Drama","Fiction","Action","Erotic","Humor","Mystic","Daily life","Psychology","Horror","Darkfic"]
    var checkMarks = [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentView.delegate = self
        paymentView.alpha = 0.0
        activityIndicator.alpha = 0.0
        book.text = "\"" + defaults.string(forKey: "SelectedBookTitle")! + "\""
        selectedBookID = defaults.string(forKey: "SelectedBookID")!
    }
    
    func loadStarted() {
        print("Load Started")
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
    }
    
    func loadFinished() {
        print("Load Finished")
        activityIndicator.alpha = 0.0
        activityIndicator.stopAnimating()
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryControllerTableViewCell", for: indexPath) as! CategoryControllerTableViewCell
        if self.preferredLanguage == "en" {
            cell.categoryTitle.text = categoryArrEN[indexPath.row]
        }
        else if self.preferredLanguage == "ru" {
            cell.categoryTitle.text = categoryArr[indexPath.row]
        }

        if checkMarks[indexPath.row] == 1{
            cell.checkmarkImage.image = UIImage(named: "checkMark1")
        }
        else{
            cell.checkmarkImage.image = UIImage(named: "checkMark0")
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = indexPath.row
        if checkMarks[indexPath.row] == 1{
            checkMarks[id] = 0
        }
        else{
            checkMarks[id] = 1
        }
        mainTableView.reloadData()
    }
    
    @IBAction func payButton(_ sender: UIButton) {
        var sendArr = [Int]()
        for i in 0..<checkMarks.count{
            if checkMarks[i] == 1{
                sendArr.append(i+1)
            }
        }
        if sendArr.count == 0{
            if self.preferredLanguage == "en" {
                let alert = UIAlertController(title: "Attention!", message: "Please select at least one category!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            else if self.preferredLanguage == "ru" {
                let alert = UIAlertController(title: "Внимание!", message: "Выберите хотя бы одну категорию!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        else{
            let headers: HTTPHeaders = [
                "Authorization": "Token " + defaults.string(forKey: "Token")!,
                "Accept": "application/json"
            ]
            
            AF.request(GlobalVariables.url + "books/test/", method: .get, parameters: nil, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success(_):
                    let json = try? JSON(data: response.data!)
                    print(json)
                    if json!["status"].stringValue == "false"{
                        if self.preferredLanguage == "en" {
                            let alert = UIAlertController(title: "Attention!", message: "Your request has been accepted and is being processed by the moderator!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: {_ in
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = storyboard.instantiateViewController(withIdentifier :"MainNavigationController")
                                self.present(viewController, animated: true)
                            }))
                            self.present(alert, animated: true)
                        }
                        else{
                            let alert = UIAlertController(title: "Внимание!", message: "Ваш запрос принят и обрабатывается модератором!", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: {_ in
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let viewController = storyboard.instantiateViewController(withIdentifier :"MainNavigationController")
                                self.present(viewController, animated: true)
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                    else{
                        self.currentArr = sendArr
                        self.paymentView.alpha = 1.0
                        let sdk = PayboxSdk.initialize(merchantId: 534896, secretKey: "pXv907x0f2olzwqI")
                        sdk.setPaymentView(paymentView: self.paymentView)
                        sdk.config().testMode(enabled: false)
                        sdk.config().setCurrencyCode(code: "KZT")
                        sdk.createPayment(amount: 490, description: "Для публикации книги.", orderId: self.selectedBookID, userId: self.defaults.string(forKey: "UID")!, extraParams: nil) {
                                payment, error in   //Вызовется после оплаты
                            if error != nil{
                                print(error)
                            }
                            else{
                                print(payment?.paymentId)
                                sdk.getPaymentStatus(paymentId: (payment?.paymentId)!) {
                                        status, error in // Вызовется после получения ответа
                                    print(status)
                                    print(status?.status)
                                    if status?.status == "ok"{
                                        self.addCategory()
                                    }
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
            
            
            
//            if self.preferredLanguage == "en" {
//                let alert = UIAlertController(title: "Attention", message: "Please, select a payment method.", preferredStyle: .actionSheet)
//
//                alert.addAction(UIAlertAction(title: "Paybox", style: .default , handler:{ (UIAlertAction)in
//                    self.currentArr = sendArr
//                    self.paymentView.alpha = 1.0
//                    let sdk = PayboxSdk.initialize(merchantId: 534896, secretKey: "pXv907x0f2olzwqI")
//                    sdk.setPaymentView(paymentView: self.paymentView)
//                    sdk.config().testMode(enabled: false)
//                    sdk.config().setCurrencyCode(code: "KZT")
//                    sdk.createPayment(amount: 490, description: "Для публикации книги.", orderId: self.selectedBookID, userId: self.defaults.string(forKey: "UID")!, extraParams: nil) {
//                            payment, error in   //Вызовется после оплаты
//                        if error != nil{
//                            print(error)
//                        }
//                        else{
//                            print(payment?.paymentId)
//                            sdk.getPaymentStatus(paymentId: (payment?.paymentId)!) {
//                                    status, error in // Вызовется после получения ответа
//                                print(status)
//                                print(status?.status)
//                                if status?.status == "ok"{
//                                    self.addCategory()
//                                }
//                            }
//                        }
//                    }
//                }))
//
//                alert.addAction(UIAlertAction(title: "Apple pay", style: .default , handler:{ (UIAlertAction)in
//                    print("User click Edit button")
//                }))
//
//                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
//                    print("User click Dismiss button")
//                }))
//
//                self.present(alert, animated: true, completion: {
//                    print("completion block")
//                })
//            }
//            else if self.preferredLanguage == "ru" {
//                let alert = UIAlertController(title: "Внимание", message: "Выберите способ оплаты.", preferredStyle: .actionSheet)
//
//                alert.addAction(UIAlertAction(title: "Paybox", style: .default , handler:{ (UIAlertAction)in
//                    self.currentArr = sendArr
//                    self.paymentView.alpha = 1.0
//                    let sdk = PayboxSdk.initialize(merchantId: 534896, secretKey: "pXv907x0f2olzwqI")
//                    sdk.setPaymentView(paymentView: self.paymentView)
//                    sdk.config().testMode(enabled: false)
//                    sdk.config().setCurrencyCode(code: "KZT")
//                    sdk.createPayment(amount: 490, description: "Для публикации книги.", orderId: self.selectedBookID, userId: self.defaults.string(forKey: "UID")!, extraParams: nil) {
//                            payment, error in   //Вызовется после оплаты
//                        if error != nil{
//                            print(error)
//                        }
//                        else{
//                            print(payment?.paymentId)
//                            sdk.getPaymentStatus(paymentId: (payment?.paymentId)!) {
//                                    status, error in // Вызовется после получения ответа
//                                print(status)
//                                print(status?.status)
//                                if status?.status == "ok"{
//                                    self.addCategory()
//                                }
//                            }
//                        }
//                    }
//                }))
//
//                alert.addAction(UIAlertAction(title: "Apple pay", style: .default , handler:{ (UIAlertAction)in
//                    print("User click Edit button")
//                }))
//
//                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler:{ (UIAlertAction)in
//                    print("User click Dismiss button")
//                }))
//
//                self.present(alert, animated: true, completion: {
//                    print("completion block")
//                })
//            }
        }
    }
    
    func addCategory(){
        print(currentArr)
        
        let parameters = ["id" : selectedBookID, "categories" : currentArr] as [String : Any]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/add/category/", method: .post, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                print(json)
                if json!["status"].stringValue == "ok"{
                    let alert = UIAlertController(title: "Поздравляю!", message: "Ваш запрос принят!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: {_ in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyboard.instantiateViewController(withIdentifier :"MainNavigationController")
                        self.present(viewController, animated: true)
                    }))
                    self.present(alert, animated: true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

