//
//  ViewController.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/13/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {

    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource = DataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(CalendarMonthEventViewCell.self, forCellWithReuseIdentifier: "CalendarMonthEventViewCell")
        collectionView.register(CalendarMonthSupplementaryView.self, forSupplementaryViewOfKind:  CalendarMonthViewCustomLayout.Element.supplementaryView.kind, withReuseIdentifier: "SupplementaryCell")
        let customLayout = CalendarMonthViewCustomLayout()
        customLayout.dataSource = self
        collectionView.collectionViewLayout = customLayout
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.monthSections.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.monthSections[section].events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarMonthEventViewCell", for: indexPath) as! CalendarMonthEventViewCell
        let eventType = dataSource.monthSections[indexPath.section].events[indexPath.row].event
        let title: String
        switch eventType {
            case .callEvent(let call):
                title = call.accountName
            case .generalEvent(let generalEvent):
                title = generalEvent.description
            case .totEvent(let totEvent):
                title = totEvent.spanType.rawValue
        }
        cell.titleLabel.text = title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: CalendarMonthViewCustomLayout.Element.supplementaryView.kind, withReuseIdentifier: "SupplementaryCell", for: indexPath) as! CalendarMonthSupplementaryView
        supplementaryView.dateInterval = dataSource.monthSections[indexPath.section].dateInteval
        supplementaryView.dateFormatter = dataSource.monthFormatter
        return supplementaryView
    }

}
//
extension ViewController: CalendarMonthViewCustomLayoutDataSource {
    func layoutParams(for indexPath: IndexPath) -> MonthSectionEventLayout {
        return dataSource.monthSections[indexPath.section].events[indexPath.row].sectionLayout
    }
//    func doesCellPlacedEarlier(cellIndexPath: IndexPath) -> Bool {
//        let eventStartDateBeginning = dateInterval(by: cellIndexPath).start.getStartOfDay()
//        let currentCellDate = dataSource.threeMonthsdateRange[cellIndexPath.section]
//        return eventStartDateBeginning < currentCellDate
//    }
//
//    func daysDurationCell(with indexPath: IndexPath) -> Int {
//        let currentSectionDate = dataSource.threeMonthsdateRange[indexPath.section]
//        let endEventDate = dateInterval(by: indexPath).end.getEndOfDay()!
//        var count = 0
//        var minimalDaysDuration = 1
//        IteratableDateInterval(DateInterval(start: currentSectionDate, end: endEventDate), Calendar.Component.day, Calendar.current).forEach {_ in
//            count += 1
//        }
//        return max(count,minimalDaysDuration)
//    }
//
//    func dateInterval(by indexPath: IndexPath) -> DateInterval {
//        let event = dataSource.eventsInSection(indexPath.section)[indexPath.row]
//        switch event {
//            case .callEvent(let call):
//                return call.dateInterval
//            case .generalEvent(let generalEvent):
//                return generalEvent.dateInterval
//            case .totEvent(let totEvent):
//                return totEvent.dateInterval
//        }
//    }

    
}

