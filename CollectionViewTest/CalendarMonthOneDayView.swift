//
//  CalendarMonthOneDayView.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/21/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation
import UIKit

protocol CalendarMonthOneDayViewDelegate: class {
    func dayDidTap(view: UIView, date: Date)
}

class CalendarMonthOneDayView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: self.frame)
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    weak var delegate: CalendarMonthOneDayViewDelegate?
    
    var doesInsideSelectedMonth: Bool = false {
        didSet{
            if doesInsideSelectedMonth {
                titleLabel.textColor = UIColor.black
            } else {
                titleLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    var doesCurrentDate: Bool = false {
        didSet{
            if doesCurrentDate {
                titleLabel.textColor = UIColor.blue
            }
        }
    }
    
    private(set) var dateFormatter: DateFormatter?
    private(set) var date: Date?
    
    func setupData(date: Date, dateformatter: DateFormatter) {
        titleLabel.text = dateformatter.string(from: date)
        self.date = date
    }
    
    private func initialSetup() {
        titleLabel.removeFromSuperview()
        self.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector( didTap(recognizer:)))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didTap(recognizer: UITapGestureRecognizer) {
        if let recognizerView = recognizer.view, let date = self.date {
            delegate?.dayDidTap(view: recognizerView, date: date)
        }
    }
}
