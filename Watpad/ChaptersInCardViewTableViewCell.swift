import UIKit

class ChaptersInCardViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var audio: UILabel!
    @IBOutlet weak var goToButton: UIButton!
    @IBOutlet weak var selectionIndicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
