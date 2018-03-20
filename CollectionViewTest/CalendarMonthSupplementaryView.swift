//
//  CalendarMonthSupplementaryView.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/13/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import UIKit

class OneDayView: UIView {
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
        label.font = UIFont.italicSystemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var dateString: String = "" {
        didSet {
            titleLabel.text = dateString
        }
    }
    
    init(dateString: String, frame: CGRect = .zero) {
        super.init(frame: frame)
        self.dateString = dateString
        initialSetup()
    }
    
    private func initialSetup() {
        titleLabel.removeFromSuperview()
        titleLabel.text = dateString
        self.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 50).isActive = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector( didTap(recognizer:)))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didTap(recognizer: UITapGestureRecognizer) {
        
    }
}

class CalendarMonthSupplementaryView: UICollectionReusableView {
    
    override var reuseIdentifier: String? {
        return "SupplementaryCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    var dateInterval: DateInterval = DateInterval() {
        didSet {
            initialSetup()
        }
    }
    
    var dateFormatter: DateFormatter = DateFormatter() {
        didSet {
            initialSetup()
        }
    }
    private lazy var weekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    private(set) var dayViews: [OneDayView] = []
    
    
    private func initialSetup() {
        var daysInsideWeekInterval = [Date]()
        weekStackView.arrangedSubviews.forEach{$0.removeFromSuperview()}
        dayViews.removeAll()
        self.addSubview(weekStackView)
        weekStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        weekStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        weekStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        weekStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        IteratableDateInterval(dateInterval).forEach{ daysInsideWeekInterval.append($0)}
        daysInsideWeekInterval.sort{$0<$1}
        daysInsideWeekInterval.enumerated().forEach { (index, date) in
            let oneDayView = OneDayView(dateString: dateFormatter.string(from: date))
            oneDayView.translatesAutoresizingMaskIntoConstraints = false
            weekStackView.addArrangedSubview(oneDayView)
        }
    }
    
    private func update() {
        
    }
    
    
    
}
