import MessageUI
import UIKit

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var contactName: UILabel!
    
    @IBOutlet weak var phoneNumber: UILabel!
    
    @IBOutlet weak var email: UILabel!
    
    
    @IBAction func sendEmail(_ sender: UIButton) {
        currentInstanceofContactTableViewController!.displayMessageUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}



