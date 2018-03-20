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
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: self.frame)
        label.textColor = UIColor.black
        label.font = UIFont.italicSystemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) var dateString: String = "" {
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
    
    private(set) var dayViews: [OneDayView] = []
    
    init(dateInterval: DateInterval, dateFormatter: DateFormatter, frame: CGRect = .zero) {
        super.init(frame: frame)
        self.dateInterval = dateInterval
        self.dateFormatter = dateFormatter
        initialSetup()
    }
    
    private func initialSetup() {
        var daysInsideWeekInterval = [Date]()
        dayViews.forEach{$0.removeFromSuperview()}
        dayViews.removeAll()
        IteratableDateInterval(dateInterval).forEach{ daysInsideWeekInterval.append($0)}
        daysInsideWeekInterval.sort{$0<$1}
        let viewsCount = max(daysInsideWeekInterval.count, 1)
        let dayViewSize = CGSize(width: self.frame.width/CGFloat(viewsCount), height: self.frame.height)
        daysInsideWeekInterval.enumerated().forEach { (index, date) in
            let dayViewframe = CGRect(origin: CGPoint(x: CGFloat(index)*dayViewSize.width, y: 0), size: dayViewSize)
            let oneDayView = OneDayView(dateString: dateFormatter.string(from: date), frame: dayViewframe)
            oneDayView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(oneDayView)
            self.dayViews.append(oneDayView)
            oneDayView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            oneDayView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            oneDayView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            if index == 0 {
                oneDayView.widthAnchor.constraint(equalToConstant: dayViewSize.width).isActive = true
                oneDayView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            } else if index == viewsCount - 1 {
                oneDayView.widthAnchor.constraint(equalTo: dayViews[0].widthAnchor, multiplier: 1)
                oneDayView.leadingAnchor.constraint(equalTo: dayViews[index-1].trailingAnchor).isActive = true
                oneDayView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            } else {
                oneDayView.widthAnchor.constraint(equalTo: dayViews[index-1].widthAnchor, multiplier: 1).isActive = true
                oneDayView.leadingAnchor.constraint(equalTo: dayViews[index-1].trailingAnchor).isActive = true
            }
        }
    }
    
    
    
}
