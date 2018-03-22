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
        collectionView.showsVerticalScrollIndicator = false
        collectionView.collectionViewLayout = customLayout
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
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
        return dataSource.monthSections[section].visibleEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarMonthEventViewCell", for: indexPath) as! CalendarMonthEventViewCell
        let viewModel = dataSource.monthEventViewModel(for: indexPath)
        cell.setupData(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: CalendarMonthViewCustomLayout.Element.supplementaryView.kind, withReuseIdentifier: "SupplementaryCell", for: indexPath) as! CalendarMonthSupplementaryView
        let viewModelForSupplementaryView = dataSource.supplementaryViewModel(for: indexPath)
        supplementaryView.setupData(with: viewModelForSupplementaryView)
        supplementaryView.delegate = self
        return supplementaryView
    }

}

extension ViewController: CalendarMonthViewCustomLayoutDataSource {
    var columnsCountPerScreen: Int {
        return dataSource.daysCountPerWeek
    }
    
    var sectionsCountPerScreen: Int {
        return dataSource.weeksCountPerPage
    }
    
    var maxItemsCountInSectionsPerColumn: Int {
        return dataSource.maxEventsPerDay
    }
    
    func layoutParams(for indexPath: IndexPath) -> MonthSectionEventLayout {
        return dataSource.monthSections[indexPath.section].visibleEvents[indexPath.row].sectionLayout
    }
}

extension ViewController: CalendarMonthSupplementaryViewDelegate {
    func dayDidTap(sectionIndex: Int, view: UIView, date: Date) {
        
    }
    
    func moreItemsDidTap(sectionIndex: Int, view: UIView, date: Date) {
        
    }

}

