//
//  CitationTableViewCell.swift
//  CiteCam
//
//  This file handles interaction for the citation list.
//
//  Main functions:
//  Handle touch interaction.
//
//  Created by Jason Yue 11/17/16
//

import UIKit

class CitationTableViewCell: UITableViewCell {
    
    // Connect the UI to the code.
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    // Initialization.
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Handle touch interaction on citation list.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
