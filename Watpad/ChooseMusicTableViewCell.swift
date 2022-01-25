
import UIKit

class ChooseMusicTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var music: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
