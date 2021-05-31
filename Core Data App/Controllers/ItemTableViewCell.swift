//
//  ItemTableViewCell.swift
//  Core Data App
//
//  Created by Mauricio Dias on 25/5/21.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var itemIDLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var invoiceNumberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
