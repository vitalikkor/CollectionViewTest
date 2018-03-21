//
//  CalendarMonthDecoratorView.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/13/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import UIKit

class CalendarMonthDecoratorView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        self.backgroundColor = UIColor.gray
    }
}
