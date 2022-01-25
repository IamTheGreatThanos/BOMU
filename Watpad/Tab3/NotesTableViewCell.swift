import UIKit

class NotesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookText: UILabel!
    @IBOutlet weak var fromBook: UILabel!
    @IBOutlet weak var lineImage: UIImageView!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
