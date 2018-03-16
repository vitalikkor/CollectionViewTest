//
//  CalendarMonthSupplementaryView.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/13/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import UIKit

class CalendarMonthSupplementaryView: UICollectionReusableView {
    
    override var reuseIdentifier: String? {
        return "SupplementaryCell"
    }
    
    @IBOutlet weak var dayTitleLabel: UILabel!
}
