//
//  CalendarMonthSupplementaryView.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/13/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import UIKit

protocol CalendarMonthSupplementaryViewDelegate: class {
    func dayDidTap(date: Date)
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
    
    private(set) var dateInterval: DateInterval?
    private(set) var dateFormatter: DateFormatter?
    private(set) var selectedMonthInterval: DateInterval?
    
    private lazy var weekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    private(set) var dayViews: [CalendarMonthOneDayView] = []
    
    weak var delegate: CalendarMonthSupplementaryViewDelegate?
    private func initialSetup() {
        guard let dateInterval = self.dateInterval,
            let selectedMonthInterval = self.selectedMonthInterval,
            let dateFormatter = self.dateFormatter
            else { return }
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
            let oneDayView = CalendarMonthOneDayView()
            oneDayView.doesInsideSelectedMonth = selectedMonthInterval.contains(date)
            oneDayView.doesCurrentDate = date == Date().getStartOfDay(timeZone: dateFormatter.timeZone)
            oneDayView.setupData(date: date, dateformatter: dateFormatter)
            oneDayView.delegate = self
            oneDayView.translatesAutoresizingMaskIntoConstraints = false
            weekStackView.addArrangedSubview(oneDayView)
        }
    }
    
    func update(with dateInterval: DateInterval, selectedMonthInterval: DateInterval, dateFormatter: DateFormatter) {
        self.dateInterval = dateInterval
        self.dateFormatter = dateFormatter
        self.selectedMonthInterval = selectedMonthInterval
        initialSetup()
    }
}

extension CalendarMonthSupplementaryView: CalendarMonthOneDayViewDelegate {

    func dayDidTap(view: UIView, date: Date) {
        delegate?.dayDidTap(date: date)
    }
}
