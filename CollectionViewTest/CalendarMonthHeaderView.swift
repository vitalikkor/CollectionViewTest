//
//  CalendarMonthHeaderView.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/23/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import Foundation
import UIKit

class CalendarMonthHeaderView: UIView {

    private(set) var dateInterval: DateInterval?
    private(set) var dateFormatter: DateFormatter?
    private(set) var lineWidth: CGFloat = 0.6
    
    private lazy var weekDayNamesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()
    
    func setupData(with viewModel: CalendarMonthHeaderViewModel) {
        self.backgroundColor = viewModel.colorBackground
        self.dateFormatter = viewModel.dateFormatter
        self.dateInterval = viewModel.dateInterval
        initialSetup()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //draw only left border and bottom long line
        let graphicContext = UIGraphicsGetCurrentContext()
        weekDayNamesStackView.arrangedSubviews.forEach{ subView in
            graphicContext?.move(to: CGPoint(x: subView.frame.maxX - lineWidth/2, y: 0))
            graphicContext?.addLine(to: CGPoint(x: subView.frame.maxX - lineWidth/2, y: subView.frame.maxY))
        }
        graphicContext?.move(to: CGPoint(x: 0, y: rect.maxY-lineWidth/2))
        graphicContext?.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY-lineWidth/2))
        graphicContext?.setStrokeColor(UIColor.gray.cgColor)
        graphicContext?.setLineWidth(lineWidth)
        graphicContext?.strokePath()
    }
    
    private func initialSetup() {
        guard let dateInterval = self.dateInterval,
            let dateFormatter = self.dateFormatter
            else { return }
        var daysInsideWeekInterval = [Date]()
        weekDayNamesStackView.arrangedSubviews.forEach{$0.removeFromSuperview()}
        self.addSubview(weekDayNamesStackView)
        weekDayNamesStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        weekDayNamesStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        weekDayNamesStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        weekDayNamesStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        IteratableDateInterval(dateInterval).forEach{ daysInsideWeekInterval.append($0)}
        daysInsideWeekInterval.sort{$0<$1}
        daysInsideWeekInterval.enumerated().forEach { (index, date) in
            let weekDayNameLabel = UILabel()
            weekDayNameLabel.text = dateFormatter.string(from: date)
            weekDayNameLabel.textAlignment = .center
            weekDayNameLabel.translatesAutoresizingMaskIntoConstraints = false
            weekDayNamesStackView.addArrangedSubview(weekDayNameLabel)
        }
        setNeedsDisplay()
    }
}
