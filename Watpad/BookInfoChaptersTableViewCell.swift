
import UIKit

class BookInfoChaptersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chapterTitle: UILabel!
    @IBOutlet weak var audio: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
