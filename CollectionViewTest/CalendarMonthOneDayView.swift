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
    func moreItemsDidTap(view: UIView, date: Date)
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
    
    private lazy var moereItemsLabel: UILabel = {
        let label = UILabel(frame: self.frame)
        label.textColor = UIColor.blue
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = "more..."
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    func setupData(date: Date, dateformatter: DateFormatter, numberOfHiddenItems: Int) {
        if numberOfHiddenItems > 0 {
            moereItemsLabel.isHidden = false
        } else {
            moereItemsLabel.isHidden = true
        }
        titleLabel.text = dateformatter.string(from: date)
        self.date = date
    }
    
    private func initialSetup() {
        titleLabel.removeFromSuperview()
        self.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
        self.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector( didTap(recognizer:))))
        self.addSubview(moereItemsLabel)
        let margingGuide = self.layoutMarginsGuide
        moereItemsLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        moereItemsLabel.leadingAnchor.constraint(equalTo: margingGuide.leadingAnchor).isActive = true
        moereItemsLabel.trailingAnchor.constraint(equalTo: margingGuide.trailingAnchor).isActive = true
        moereItemsLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        moereItemsLabel.isHidden = true
        moereItemsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector( didTap(recognizer:))))
    }
    
    @objc private func didTap(recognizer: UITapGestureRecognizer) {
        guard let recognizerView = recognizer.view, let date = self.date else { return }
        if recognizer.view == moereItemsLabel {
            delegate?.moreItemsDidTap(view: recognizerView, date: date)
        } else if recognizer.view == self {
            delegate?.dayDidTap(view: recognizerView, date: date)
        }
        
    }
}
