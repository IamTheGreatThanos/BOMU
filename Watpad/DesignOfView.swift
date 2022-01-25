import Foundation
import UIKit

@IBDesignable class DesignOfView : UIView {
    
    @IBInspectable var cornerRadius : CGFloat = 15
    @IBInspectable var shadowOffsetWidth : Int = 0
    @IBInspectable var shadowOffsetHeight : Int = -4

    
    override func layoutSubviews() {
        layer.borderWidth = 0.5
        layer.borderColor = #colorLiteral(red: 0.1026927348, green: 0.1026927348, blue: 0.1026927348, alpha: 0.2455211901)
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        layer.shadowOpacity = 0.2
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        
    }
    
}
