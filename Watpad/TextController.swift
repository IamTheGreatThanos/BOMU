import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import Foundation

class TextController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var backBG: UIImageView!
    @IBOutlet weak var musicOutlet: UIButton!
    @IBOutlet weak var editOutlet: UIButton!
    @IBOutlet weak var chaptersOutlet: UIButton!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    let defaults = UserDefaults.standard
    var chapterText = NSAttributedString()
    var mainText = ""
    var buttonsShown = 1
    var textArray = [NSAttributedString]()
    var words = [JSON]()
    var selectedColor = "1"
    
    var currentTextView = 0
    let preferredLanguage = NSLocale.preferredLanguages[0].prefix(2)
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.set("Montserrat-Regular", forKey: "FontName")
        defaults.set("Montserrat", forKey: "FontFamily")
        setupCard()
        titleLabel.text = defaults.string(forKey: "SelectedBookChapter")
        getText()
        swipeGesture()
        addCustomMenu()
        textView.isEditable = false
        textView.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TextController.textViewTap(recognzier:)))
        textView.addGestureRecognizer(tapGestureRecognizer)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(blackFun), name: Notification.Name("Black"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(whiteFun), name: Notification.Name("White"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(plusFun), name: Notification.Name("Plus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(minusFun), name: Notification.Name("Minus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeFont), name: Notification.Name("ChangeFont"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getTextWithNotification), name: Notification.Name("GetText"), object: nil)
    }
    
    func addCustomMenu() {
        if self.preferredLanguage == "en" {
            let addNotesVar = UIMenuItem(title: "Add to notes", action: #selector(addNote))
            UIMenuController.shared.menuItems = [addNotesVar]
        }
        else if self.preferredLanguage == "ru" {
            let addNotesVar = UIMenuItem(title: "Добавить в заметки", action: #selector(addNote))
            UIMenuController.shared.menuItems = [addNotesVar]
        }

        
    }
    
    @objc func addNote() {
        if let range = textView.selectedTextRange, let selectedText = textView.text(in: range) {
            if selectedText.count != 0{
                addNoteFunc(text: selectedText)
            }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func cutText(fontName: String, fontSize: CGFloat, color: String){
        var txt = ""
        var txtArr = mainText.split(separator: " ")
        var currentTxt = txtArr[0] + " "
        
        for i in 1..<txtArr.count{
            if i % Int(2200/textView.font!.pointSize) == 0{
                txt += currentTxt + "± "
                currentTxt = txtArr[i] + " "
            }
            else{
                currentTxt += txtArr[i] + " "
            }
        }
        
        txt += currentTxt
        
        
        let attributedText = NSMutableAttributedString.init(string: txt)
        // Font default
        let mainFont = UIFont(name: fontName, size: fontSize)
        let rangeFont = (txt as NSString).range(of: txt)
        attributedText.addAttribute(NSAttributedString.Key.font, value: mainFont, range: rangeFont)
        if color == "1"{
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.62), range: rangeFont)
        }
        else{
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), range: rangeFont)
        }
        
        // Add Color
//        for i in self.words{
//            let arrRange = i["range"].arrayValue
//            let length = arrRange[1].intValue-arrRange[0].intValue
//            if i["word"].string != nil{
//                if i["type"].string == "music"{
//                    let range = (txt as NSString).range(of: i["word"].stringValue)
//                    if arrRange[0].intValue + length < attributedText.length-1{
////                                    let currentWord = attributedText.attributedSubstring(from: range).string
//                        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName + "-Bold", size: textView.font!.pointSize), range: range)
////                            if currentWord == i["word"].string{
////                                attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: hexStringToUIColor(hex: i["color"].string!), range: range)
////                            }
//                    }
//                }
//                else{
//                    let range = (txt as NSString).range(of: i["word"].stringValue)
////                        let range = NSMakeRange(arrRange[0].intValue, length)
//                    if arrRange[0].intValue + length < attributedText.length-1{
////                                    let currentWord = attributedText.attributedSubstring(from: range).string
//                        attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: hexStringToUIColor(hex: i["color"].string!), range: range)
////                            if currentWord == i["word"].string{
////                                attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: hexStringToUIColor(hex: i["color"].string!), range: range)
////                            }
//                    }
//                }
//            }
//        }
//        textView.attributedText = attributedText
        
        print(self.words)
        
        for i in self.words{
            if i["type"].string == "music"{
                let arrRange = i["range"].arrayValue
                let length = arrRange[1].intValue-arrRange[0].intValue

                let range = (txt as NSString).range(of: i["word"].stringValue)
                attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: defaults.string(forKey: "FontName")!, size: textView.font!.pointSize+1), range: range)
            }
            else{
                let arrRange = i["range"].arrayValue
                let length = arrRange[1].intValue-arrRange[0].intValue

                let range = (txt as NSString).range(of: i["word"].stringValue)
                attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: hexStringToUIColor(hex: i["color"].string!), range: range)
            }
            

//            let range = NSMakeRange(arrRange[0].intValue, length)
//            let currentWord = attributedText.attributedSubstring(from: range).string
//            if currentWord == i["word"].string{
//                print("Equal")
//                attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: self.hexStringToUIColor(hex: i["color"].string!), range: range)
//            }
        }
        
        self.textArray = self.splitAttributedString(inputString: attributedText, seperateBy: "±")
        if currentTextView < self.textArray.count{
            self.textView.attributedText = self.textArray[currentTextView]
        }
        else if self.textArray.count-1 >= 0{
            self.textView.attributedText = self.textArray[self.textArray.count-1]
            self.currentTextView = self.textArray.count-1
        }
        else{
            self.textView.attributedText = self.textArray[0]
            self.currentTextView = 0
        }
    }
    
    func splitAttributedString(inputString: NSAttributedString, seperateBy: String) -> [NSAttributedString] {
        let input = inputString.string
        let separatedInput = input.components(separatedBy: seperateBy)
        var output = [NSAttributedString]()
        var start = 0
        for sub in separatedInput {
            let range = NSMakeRange(start, sub.utf16.count)
            let attribStr = inputString.attributedSubstring(from: range)
            output.append(attribStr)
            start += range.length + seperateBy.count
        }
        return output
    }
    
    func swipeGesture(){
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))

        leftSwipe.direction = .left
        rightSwipe.direction = .right

        textView.addGestureRecognizer(leftSwipe)
        textView.addGestureRecognizer(rightSwipe)
    }

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer)
    {
        if (sender.direction == .left)
        {
            if currentTextView < textArray.count-1{
                UIView.animate(withDuration: 0.5, animations: {
                    self.textView.alpha = 0.0
                })
                currentTextView += 1
                self.textView.attributedText = textArray[currentTextView]
                UIView.animate(withDuration: 0.5, animations: {
                    self.textView.alpha = 1.0
                })
//               print("Swipe Left")
            }
        }
        else if (sender.direction == .right)
        {
            if currentTextView > 0{
                UIView.animate(withDuration: 0.5, animations: {
                    self.textView.alpha = 0.0
                })
                currentTextView -= 1
                self.textView.attributedText = textArray[currentTextView]
                UIView.animate(withDuration: 0.5, animations: {
                    self.textView.alpha = 1.0
                })
//               print("Swipe Right")
            }
        }
    }
    
    @objc func getTextWithNotification() {
        getText()
        titleLabel.text = defaults.string(forKey: "SelectedBookChapter")
    }
    
    func getText(){
        let headers: HTTPHeaders = [
            "Authorization": "Token " + defaults.string(forKey: "Token")!,
            "Accept": "application/json"
        ]
        
        AF.request(GlobalVariables.url + "books/text/" + defaults.string(forKey: "SelectedBookChapterID")!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                let json = try? JSON(data: response.data!)
//                print(json)
                if json != nil{
                    self.words = json!["words"].arrayValue
                    self.mainText = json!["text"].string!
                    self.cutText(fontName: "Montserrat-Regular", fontSize: self.textView.font!.pointSize, color: self.selectedColor)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc func blackFun (notification: NSNotification){
        mainView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.62)
        textView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.62)
        textView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        titleLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        selectedColor = "2"
        UIApplication.shared.statusBarStyle = .lightContent
        if defaults.string(forKey: "FontName") != nil{
            cutText(fontName: defaults.string(forKey: "FontName")!, fontSize: textView.font!.pointSize, color: selectedColor)
        }
        else{
            defaults.set("Montserrat", forKey: "FontFamily")
            cutText(fontName: "Montserrat-Regular", fontSize: textView.font!.pointSize, color: selectedColor)
        }
    }
    
    @objc func whiteFun (notification: NSNotification){
        mainView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.62)
        titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.62)
        selectedColor = "1"
        UIApplication.shared.statusBarStyle = .default
        if defaults.string(forKey: "FontName") != nil{
            cutText(fontName: defaults.string(forKey: "FontName")!, fontSize: textView.font!.pointSize, color: selectedColor)
        }
        else{
            defaults.set("Montserrat", forKey: "FontFamily")
            cutText(fontName: "Montserrat-Regular", fontSize: textView.font!.pointSize, color: selectedColor)
        }
    }
    
    @objc func minusFun (notification: NSNotification){
        self.textView.decreaseFontSize()
        if defaults.string(forKey: "FontName") != nil{
            cutText(fontName: defaults.string(forKey: "FontName")!, fontSize: textView.font!.pointSize, color: selectedColor)
        }
        else{
            defaults.set("Montserrat", forKey: "FontFamily")
            cutText(fontName: "Montserrat-Regular", fontSize: textView.font!.pointSize, color: selectedColor)
        }
    }
    
    @objc func plusFun (notification: NSNotification){
        self.textView.increaseFontSize()
        if defaults.string(forKey: "FontName") != nil{
            cutText(fontName: defaults.string(forKey: "FontName")!, fontSize: textView.font!.pointSize, color: selectedColor)
        }
        else{
            defaults.set("Montserrat", forKey: "FontFamily")
            cutText(fontName: "Montserrat-Regular", fontSize: textView.font!.pointSize, color: selectedColor)
        }
    }
    
    @objc func changeFont (notification: NSNotification){
        cutText(fontName: defaults.string(forKey: "FontName")!, fontSize: textView.font!.pointSize, color: selectedColor)
    }
    
    // MARK: Text View Tap Gesture
    @objc
    func textViewTap(recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
            // Animate card when tap finishes
        case .ended:
            if buttonsShown == 1{
                UIView.animate(withDuration: 0.5, animations: {
                    self.backButtonOutlet.alpha = 0.0
                    self.backBG.alpha = 0.0
                    self.musicOutlet.alpha = 0.0
                    self.chaptersOutlet.alpha = 0.0
                    self.musicOutlet.alpha = 0.0
                    self.editOutlet.alpha = 0.0
                    self.titleLabel.alpha = 0.0
                    self.topConstraint.constant = 10
                })
                buttonsShown = 0
            }
            else{
                UIView.animate(withDuration: 0.5, animations: {
                    self.backButtonOutlet.alpha = 1.0
                    self.backBG.alpha = 1.0
                    self.musicOutlet.alpha = 1.0
                    self.chaptersOutlet.alpha = 1.0
                    self.musicOutlet.alpha = 1.0
                    self.editOutlet.alpha = 1.0
                    self.titleLabel.alpha = 1.0
                    self.topConstraint.constant = 60
                })
                buttonsShown = 1
            }
        default:
            break
        }
    }
    
    @IBAction func textEditButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("DisplayEditView"), object: nil)
        animateTransitionIfNeeded(state: nextState, duration: 0.9)
    }
    
    @IBAction func chaptersButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("DisplayChaptersView"), object: nil)
        animateTransitionIfNeeded(state: nextState, duration: 0.9)
    }
    
    @IBAction func musicButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("DisplayMusicView"), object: nil)
        animateTransitionIfNeeded(state: nextState, duration: 0.9)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
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

//        cardViewController.handleArea.layer.shadowColor = UIColor.black.cgColor
//        cardViewController.handleArea.layer.shadowOffset = CGSize(width: 0, height: -4)
//        cardViewController.handleArea.layer.shadowOpacity = 0.2
//        let shadowPath = UIBezierPath(roundedRect: cardViewController.handleArea.bounds, cornerRadius: 15)
//        cardViewController.handleArea.layer.shadowPath = shadowPath.cgPath
    
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

