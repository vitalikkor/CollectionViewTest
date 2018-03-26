//
//  ViewController.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/13/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {

    let dataSource = CalendarMonthViewDataSource()
    
    lazy var headerView: CalendarMonthHeaderView = {
        let view = CalendarMonthHeaderView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        let viewModel = dataSource.headerViewModel()
        view.setupData(with: viewModel)
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let customLayout = CalendarMonthViewCustomLayout()
        customLayout.dataSource = self
        let collection = UICollectionView(frame: .zero, collectionViewLayout: customLayout)
        collection.backgroundColor = UIColor.white
        collection.showsVerticalScrollIndicator = false
        collection.bounces = false
        collection.isPagingEnabled = true
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.register(CalendarMonthEventViewCell.self, forCellWithReuseIdentifier: CalendarMonthEventViewCell.identifier)
        collectionView.register(CalendarMonthSupplementaryView.self, forSupplementaryViewOfKind:  CalendarMonthViewCustomLayout.Element.supplementaryView.kind, withReuseIdentifier: CalendarMonthSupplementaryView.identifier)
        collectionView.reloadData()
    }
    
    private func setupHeaderView() {
        self.view.addSubview(headerView)
        headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.monthSections.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.monthSections[section].visibleEvents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarMonthEventViewCell.identifier, for: indexPath) as! CalendarMonthEventViewCell
        let viewModel = dataSource.monthEventViewModel(for: indexPath)
        cell.setupData(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: CalendarMonthViewCustomLayout.Element.supplementaryView.kind, withReuseIdentifier: CalendarMonthSupplementaryView.identifier, for: indexPath) as! CalendarMonthSupplementaryView
        let viewModelForSupplementaryView = dataSource.supplementaryViewModel(for: indexPath.section)
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

