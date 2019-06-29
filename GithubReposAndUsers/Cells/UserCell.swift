//
//  UserCell.swift
//  GithubReposAndUsers
//
//  Created by Константин Трехперстов on 27.06.2019.
//  Copyright © 2019 Константин Трехперстов. All rights reserved.
//

import UIKit

enum CellIdentifiers: String {
    case UserCell, RepoCell, LoadingCell
}



class UserCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(viewData: UserViewData) {
        self.avatarImageView.kf.setImage(with: viewData.avatarURL, placeholder: UIImage(named: "blank-avatar"))
        self.nameLabel.text = viewData.name
        self.followersLabel.text = "\(viewData.followers) followers"
        self.followingLabel.text = "\(viewData.following) following"
    }
}
