//
//  CollectionViewCell.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/13/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import UIKit

class CalendarMonthEventViewCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: contentView.frame)
        label.text = ""
        label.textColor = UIColor.black
        label.font = UIFont.italicSystemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.addSubview(titleLabel)
        let margins = self.layoutMarginsGuide
        titleLabel.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        self.backgroundColor = UIColor.yellow
    }
    
    
}
