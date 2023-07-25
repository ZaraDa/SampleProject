//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Zara Davtian on 25.07.23.
//

import UIKit

class FeedImageCell: UITableViewCell {


    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var feedImageView: UIImageView!
    @IBOutlet var locationContainer: UIStackView!
    @IBOutlet var descriptionLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
