//
//  PurchaseOrderTableViewCell.swift
//  Core Data App
//
//  Created by Mauricio Dias on 24/5/21.
//

import UIKit

class PurchaseOrderTableViewCell: UITableViewCell {
    @IBOutlet weak var orderIDLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
