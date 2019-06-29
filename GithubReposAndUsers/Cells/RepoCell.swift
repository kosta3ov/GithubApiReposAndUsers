//
//  RepoCell.swift
//  GithubReposAndUsers
//
//  Created by Константин Трехперстов on 27.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import UIKit

class RepoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var starsCountLabel: UILabel!
    @IBOutlet weak var forksCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(viewData: RepoViewData) {
        self.titleLabel.text = viewData.name
        self.descriptionLabel.text = viewData.description
        self.starsCountLabel.text = String(viewData.watchers)
        self.forksCountLabel.text = String(viewData.forks)
    }

}
