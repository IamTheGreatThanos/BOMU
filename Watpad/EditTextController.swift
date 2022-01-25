import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class EditTextController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var buttonBG: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let defaults = UserDefaults.standard
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
    var words = [JSON]()
    
    enum CardState {
        case collapsed
        case expanded
    }

    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var cardViewController:CardViewController!
    var visualEffectView:UIVisualEffectView!
    
    var cardHeight:CGFloat = 270
    var cardHandleAreaHeight:CGFloat = 0
    
    var cardVisible = false

    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    var selectedTextInTextView = ""
    var textID = ""
    
    var selectedRange = UITextRange()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getText()
        setupCard()
        addDoneButtonOnKeyboard()
        addCustomMenu()
        titleLabel.text = defaults.string(forKey: "SelectedBookChapter")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(colorAction), name: Notification.Name("ChangeColor"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addMusicName), name: Notification.Name("AddMusicName"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.bottomConstraint.constant = 300
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        self.bottomConstraint.constant = 10
    }
    
    @objc func colorAction(sender: UIButton){
        let index = defaults.string(forKey: "ColorIndex")!
        if index == "1"{
            let attributedText = NSMutableAttributedString.init(string: textView.text)
            // Font default
            let mainFont = UIFont(name: "Montserrat-Regular", size: textView.font!.pointSize)
            let rangeFont = (textView.text as NSString).range(of: textView.text)
            attributedText.addAttribute(NSAttributedString.Key.font, value: mainFont, range: rangeFont)
            // Add Color
            let range = (textView.text as NSString).range(of: selectedTextInTextView)
            attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: #colorLiteral(red: 0.6078431373, green: 0.2705882353, blue: 0.6862745098, alpha: 0.62), range: range)
            textView.attributedText = attributedText
            var arr = [String]()
            arr.append(String(range.lowerBound))
            arr.append(String(range.upperBound))
            self.createAttributedWords(range: arr, color: "9B45AF")
        }
        else if index == "2"{
            let attributedText = NSMutableAttributedString.init(string: textView.text)
            // Font default
            let mainFont = UIFont(name: "Montserrat-Regular", size: textView.font!.pointSize)
            let rangeFont = (textView.text as NSString).range(of: textView.text)
            attributedText.addAttribute(NSAttributedString.Key.font, value: mainFont, range: rangeFont)
            // Add Color
            let range = (textView.text as NSString).range(of: selectedTextInTextView)
            attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: #colorLiteral(red: 0.9647058824, green: 0.5764705882, blue: 0.3882352941, alpha: 0.62), range: range)
            textView.attributedText = attributedText
            var arr = [String]()
            arr.append(String(range.lowerBound))
            arr.append(String(range.upperBound))
            self.createAttributedWords(range: arr, color: "F69363")
        }
        else if index == "3"{
            let attributedText = NSMutableAttributedString.init(string: textView.text)
            // Font default
            let mainFont = UIFont(name: "Montserrat-Regular", size: textView.font!.pointSize)
            let rangeFont = (textView.text as NSString).range(of: textView.text)
            attributedText.addAttribute(NSAttributedString.Key.font, value: mainFont, range: rangeFont)
            // Add Color
            let range = (textView.text as NSString).range(of: selectedTextInTextView)
            attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: #colorLiteral(red: 0.4666666667, green: 0.6039215686, blue: 0.6274509804, alpha: 0.62), range: range)
            textView.attributedText = attributedText
            var arr = [String]()
            arr.append(String(range.lowerBound))
            arr.append(String(range.upperBound))
            self.createAttributedWords(range: arr, color: "779AA0")
        }
        else{
            let attributedText = NSMutableAttributedString.init(string: textView.text)
            // Font default
            let mainFont = UIFont(name: "Montserrat-Regular", size: textView.font!.pointSize)
            let rangeFont = (textView.text as NSString).range(of: textView.text)
            attributedText.addAttribute(NSAttributedString.Key.font, value: mainFont, range: rangeFont)
            // Add Color
            let range = (textView.text as NSString).range(of: selectedTextInTextView)
            attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: #colorLiteral(red: 0.6117647059, green: 0.8235294118, blue: 0.3411764706, alpha: 0.62), range: range)
            textView.attributedText = attributedText
            var arr = [String]()
            arr.append(String(range.lowerBound))
            arr.append(String(range.upperBound))
            self.createAttributedWords(range: arr, color: "9CD257")
        }
        getText()
    }
    
    func createAttributedWords(range: [String], color: String){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        let parameters = ["ranges" : range, "types" : "text", "color" : color, "word" : selectedTextInTextView] as [String : Any]
        
        AF.request(GlobalVariables.url + "books/words/" + textID, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                self.defaults.set(true, forKey: "IsColorSelected")
            case .failure(let error):
                print(error)
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
        
        textView.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.view.endEditing(true)
        self.setText()
    }
    
    func addCustomMenu() {
        if self.preferredLanguage == "en" {
            let addMusicVar = UIMenuItem(title: "Add music", action: #selector(addMusic))
            let addNotesVar = UIMenuItem(title: "Add to notes", action: #selector(addNote))
            UIMenuController.shared.menuItems = [addMusicVar, addNotesVar]
        }
        else if self.preferredLanguage == "ru" {
            let addMusicVar = UIMenuItem(title: "Добавить музыку", action: #selector(addMusic))
            let addNotesVar = UIMenuItem(title: "Добавить в заметки", action: #selector(addNote))
            UIMenuController.shared.menuItems = [addMusicVar, addNotesVar]
        }
    }

    @objc func addMusic() {
        if let range = textView.selectedTextRange, let selectedText = textView.text(in: range) {
            self.selectedRange = range
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier :"ChooseMusicController")
            self.navigationController?.pushViewController(viewController,
            animated: true)
            self.selectedTextInTextView = selectedText
        }
    }
    
    @objc func addNote() {
        if let range = textView.selectedTextRange, let selectedText = textView.text(in: range) {
            if selectedText.count != 0{
                addNoteFunc(text: selectedText)
            }
        }
    }
    
    @objc func addMusicName() {
        var allText = NSMutableAttributedString()
        let music = defaults.string(forKey: "MusicName")!
        let rangeFont = ("( \"" + music + "\" )" as NSString).range(of: "( \"" + music + "\" )")
        let mainFont = UIFont(name: "Montserrat-Bold", size: textView.font!.pointSize)
        let musicName = NSMutableAttributedString.init(string:"( \"" + music + "\" )\n")
        musicName.addAttribute(NSAttributedString.Key.font, value: mainFont, range: rangeFont)
        let start = textView.attributedText.attributedSubstring(from: NSMakeRange(0, textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)))
        let end = textView.attributedText.attributedSubstring(from: NSMakeRange(textView.offset(from: textView.beginningOfDocument, to: selectedRange.start), textView.text.count - textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)))
        
        allText.append(start)
        allText.append(musicName)
        allText.append(end)
        textView.attributedText = allText
        
        var arr = [String]()
        arr.append(String(textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)))
        arr.append(String(textView.offset(from: textView.beginningOfDocument, to: selectedRange.start) + rangeFont.upperBound))
        
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        let parameters = ["ranges" : arr, "types" : "music", "color" : "null", "word" : "( \"" + music + "\" )"] as [String : Any]
        
        print(parameters)
        
        AF.request(GlobalVariables.url + "books/words/" + textID, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                self.defaults.set(true, forKey: "IsColorSelected")
            case .failure(let error):
                print(error)
            }
        }
        
        
        setText()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count % 20 == 0{
            setText()
        }
    }
    
    func addNoteFunc(text: String){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        let parameters = ["text" : text, "book" : defaults.string(forKey: "SelectedBookID")!]
        
        AF.request(GlobalVariables.url + "note/my/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getText(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/text/" + defaults.string(forKey: "SelectedBookChapterID")!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { [self] response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
                if json != nil{
                    self.textID = json!["id"].stringValue
                    self.words = json!["words"].arrayValue
                    
                    let attributedText = NSMutableAttributedString.init(string: json!["text"].string!)
                    // Font default
                    let mainFont = UIFont(name: "Montserrat-Regular", size: textView.font!.pointSize)
                    let rangeFont = (json!["text"].string! as NSString).range(of: json!["text"].string!)
                    attributedText.addAttribute(NSAttributedString.Key.font, value: mainFont, range: rangeFont)
                    // Add Color
                    print(self.words)
                    for i in self.words{
                        let arrRange = i["range"].arrayValue
                        let length = arrRange[1].intValue-arrRange[0].intValue
                        if i["word"].string != nil{
                            if i["type"].string == "music"{
                                let range = (json!["text"].string! as NSString).range(of: i["word"].stringValue)
                                if arrRange[0].intValue + length < attributedText.length-1{
//                                    let currentWord = attributedText.attributedSubstring(from: range).string
                                    attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Montserrat-Bold", size: textView.font!.pointSize), range: range)
        //                            if currentWord == i["word"].string{
        //                                attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: hexStringToUIColor(hex: i["color"].string!), range: range)
        //                            }
                                }
                            }
                            else{
                                let range = (json!["text"].string! as NSString).range(of: i["word"].stringValue)
        //                        let range = NSMakeRange(arrRange[0].intValue, length)
                                if arrRange[0].intValue + length < attributedText.length-1{
//                                    let currentWord = attributedText.attributedSubstring(from: range).string
                                    attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: hexStringToUIColor(hex: i["color"].string!), range: range)
        //                            if currentWord == i["word"].string{
        //                                attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: hexStringToUIColor(hex: i["color"].string!), range: range)
        //                            }
                                }
                            }
                        }
                    }
                    textView.attributedText = attributedText
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setText(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        var parameters = ["text" : ""]
        if textView.text == ""{
            parameters = ["text" : ""]
        }
        else{
            parameters = ["text" : textView.text]
        }
        
        
        AF.request(GlobalVariables.url + "books/text/" + defaults.string(forKey: "SelectedBookChapterID")!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func musicButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("DisplayMusicView"), object: nil)
        animateTransitionIfNeeded(state: nextState, duration: 0.9)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        setText()
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupCard() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
//        self.view.addSubview(visualEffectView)

        cardViewController = storyboard!.instantiateViewController(withIdentifier :"CardViewController") as! CardViewController
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        cardViewController.view.clipsToBounds = true
    
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TextController.handleCardTap(recognzier:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TextController.handleCardPan(recognizer:)))

        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        
    }

    // Handle tap gesture recognizer
    @objc
    func handleCardTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
            // Animate card when tap finishes
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }

    // Handle pan gesture recognizer
    @objc
    func handleCardPan (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // Start animation if pan begins
            startInteractiveTransition(state: nextState, duration: 0.9)

        case .changed:
            // Update the translation according to the percentage completed
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            // End animation when pan ends
            continueInteractiveTransition()
        default:
            break
        }
    }

    // Animate transistion function
     func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
         // Check if frame animator is empty
         if runningAnimations.isEmpty {
             // Create a UIViewPropertyAnimator depending on the state of the popover view
             let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                 switch state {
                 case .expanded:
                     // If expanding set popover y to the ending height and blur background
                     self.cardViewController.view.frame.origin.y = self.view.frame.height -  self.cardHeight
                     self.visualEffectView.effect = UIBlurEffect(style: .dark)

                 case .collapsed:
                     // If collapsed set popover y to the starting height and remove background blur
                     self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight

                     self.visualEffectView.effect = nil
                     

                 }
             }

             // Complete animation frame
             frameAnimator.addCompletion { _ in
                 self.cardVisible = !self.cardVisible
                 self.runningAnimations.removeAll()
             }

             // Start animation
             frameAnimator.startAnimation()

             // Append animation to running animations
             runningAnimations.append(frameAnimator)

             // Create UIViewPropertyAnimator to round the popover view corners depending on the state of the popover
             let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                 switch state {
                 case .expanded:
                     // If the view is expanded set the corner radius to 30
                     self.cardViewController.view.layer.cornerRadius = 30

                 case .collapsed:
                     // If the view is collapsed set the corner radius to 0
                     self.cardViewController.view.layer.cornerRadius = 0
                 }
             }

             // Start the corner radius animation
             cornerRadiusAnimator.startAnimation()

             // Append animation to running animations
             runningAnimations.append(cornerRadiusAnimator)

         }
     }

     // Function to start interactive animations when view is dragged
     func startInteractiveTransition(state:CardState, duration:TimeInterval) {

         // If animation is empty start new animation
         if runningAnimations.isEmpty {
             animateTransitionIfNeeded(state: state, duration: duration)
         }

         // For each animation in runningAnimations
         for animator in runningAnimations {
             // Pause animation and update the progress to the fraction complete percentage
             animator.pauseAnimation()
             animationProgressWhenInterrupted = animator.fractionComplete
         }
     }

     // Funtion to update transition when view is dragged
     func updateInteractiveTransition(fractionCompleted:CGFloat) {
         // For each animation in runningAnimations
         for animator in runningAnimations {
             // Update the fraction complete value to the current progress
             animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
         }
     }

     // Function to continue an interactive transisiton
     func continueInteractiveTransition (){
         // For each animation in runningAnimations
         for animator in runningAnimations {
             // Continue the animation forwards or backwards
             animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
         }
     }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(0.6)
        )
    }
}

