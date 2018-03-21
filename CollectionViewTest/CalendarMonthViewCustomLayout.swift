//
//  CustomLayout.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/13/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import UIKit

protocol CalendarMonthViewCustomLayoutDataSource: class {
    var maxItemsInSectionsPerColumn: Int {get}
    func layoutParams(for indexPath: IndexPath) -> MonthSectionEventLayout
}

class CalendarMonthViewCustomLayout: UICollectionViewLayout {

    enum Zindex {
        static let cellView = 2 // the Toppest view
        static let supplementaryView = 1
        static let decoratorView = 0
    }

    enum Element: String {
        case supplementaryView
        case decoratorVerticalView
        case decoratorHorizontalView
        case cellView

        var kind: String {
            return "Kind\(self.rawValue.capitalized)"
        }
    }
    weak var dataSource: CalendarMonthViewCustomLayoutDataSource?

    private let columnsCountPerScreen: Int = 7
    private let sectionsCountPerScreen: Int = 5
    private let separatorLineWidth: CGFloat = 0.6
    private let verticalCellsDistance: CGFloat = 2
    private let cellsLeftInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    private let cellsRightInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
    private let preferredCellHeight: CGFloat = 40
    private var oldBounds = CGRect.zero
    private var contentHeight: CGFloat = 0
    
    let sectionInsets = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    
    var cellHeight: CGFloat {
        guard let maxItemsInSections = dataSource?.maxItemsInSectionsPerColumn else { return 0.0 }
        let computedHeight = (sectionSize.height - sectionInsets.top)/(CGFloat(maxItemsInSections + 1) + verticalCellsDistance)
        return min(preferredCellHeight,computedHeight)
    }
    
    var columnWidth: CGFloat {
        return (collectionView?.frame.width ?? 0)/CGFloat(totalColumnsCount)
    }
    
    var totalSectionsCount: Int {
        return collectionView?.numberOfSections ?? 0
    }
    
    var totalColumnsCount: Int {
        return columnsCountPerScreen
    }
    
    var sectionSize: CGSize  {
        let collectionViewSize: CGSize = collectionView?.bounds.size ?? .zero
        return CGSize(width: collectionViewSize.width, height: collectionViewSize.height/CGFloat(sectionsCountPerScreen))
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.frame.width ?? 0, height: contentHeight)
    }

    override init() {
        super.init()
        initialSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }

    private func initialSetup() {
        self.register(CalendarMonthDecoratorView.self, forDecorationViewOfKind: Element.decoratorVerticalView.kind)
        self.register(CalendarMonthDecoratorView.self, forDecorationViewOfKind: Element.decoratorHorizontalView.kind)
    }

    private var cashedAttributs: [ Element : [IndexPath : UICollectionViewLayoutAttributes]] = [:]
    private var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()


    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        visibleLayoutAttributes.removeAll(keepingCapacity: true)
        for (_, element) in cashedAttributs {
            for (_, attribute) in element {
                if attribute.frame.intersects(rect) {
                    visibleLayoutAttributes.append(attribute)
                }
            }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cashedAttributs[Element.cellView]?[indexPath]
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cashedAttributs[Element.supplementaryView]?[indexPath]
    }

    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let element = Element(rawValue: elementKind) {
            return cashedAttributs[element]?[indexPath]
        }
        return nil
    }


    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView,
            cashedAttributs.isEmpty else {
                return
        }
        resetCashe()
        oldBounds = collectionView.bounds
        for section in 0..<collectionView.numberOfSections {
            //handle day's tiles attributes
            let indexPath = IndexPath(item: 0, section: section)
            let locationY = sectionSize.height*CGFloat(section)
            let supplementaryAttribut = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Element.supplementaryView.kind, with: indexPath)
            supplementaryAttribut.frame = CGRect(origin: CGPoint(x: 0, y: locationY), size: sectionSize)
            supplementaryAttribut.zIndex = Zindex.supplementaryView
            cashedAttributs[Element.supplementaryView]?[indexPath] = supplementaryAttribut
            fillCellsAttributes(for: section)
        }
        contentHeight = sectionSize.height*CGFloat(totalSectionsCount)
        fillSeparatorsAttributes()
        
    }

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds.size != newBounds.size {
            cashedAttributs.removeAll(keepingCapacity: true)
        }
        return true
    }
    
    private func fillCellsAttributes(for section: Int) {
        guard let collectionView = collectionView, let dataSource = self.dataSource else { return }
        for i in 0..<collectionView.numberOfItems(inSection: section) {
            let indexPath = IndexPath(item: i, section: section)
            let layoutParams = dataSource.layoutParams(for: indexPath)
            let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let columnNumber = CGFloat(layoutParams.column)
            let origin = CGPoint(x: max(0, columnNumber)*columnWidth, y:
                CGFloat(layoutParams.row)*(cellHeight+verticalCellsDistance)+sectionInsets.top+CGFloat(section)*sectionSize.height)
            let size = CGSize(width: CGFloat(layoutParams.duration)*columnWidth, height: cellHeight)
            var frame = CGRect(origin: origin, size: size)
            clipToBounds(frame: &frame, bounds: collectionView.bounds)
            cellAttributes.frame = applyCellInsets(with: frame, layoutParams: layoutParams)
            cellAttributes.zIndex = Zindex.cellView
            cashedAttributs[Element.cellView]?[indexPath] = cellAttributes
        }
    }
    
    private func clipToBounds(frame: inout CGRect, bounds: CGRect) {
        if frame.minX < 0 {
            frame.origin.x = 0
        }
        if frame.maxX > bounds.size.width {
            frame.size.width = bounds.size.width - frame.origin.x
        }
    }
    
    private func applyCellInsets(with frame: CGRect, layoutParams: MonthSectionEventLayout) -> CGRect {
        var resultFrame = frame
        if layoutParams.column >= 0 {
            resultFrame = UIEdgeInsetsInsetRect(resultFrame, cellsLeftInset)
        }
        if max(0, layoutParams.column) + layoutParams.duration <= columnsCountPerScreen {
            resultFrame = UIEdgeInsetsInsetRect(resultFrame, cellsRightInset)
        }
        return resultFrame
    }

    private func fillSeparatorsAttributes(){
        guard let sectionCount = collectionView?.numberOfSections else { return }
        //add horizontal view-separator
        for row in 0..<sectionCount {
            let indexPath = IndexPath(row: 0, section: row)
            let rawLocationY = sectionSize.height * CGFloat(row)
            let locationY = row == 0 ? rawLocationY : rawLocationY - separatorLineWidth
            let horizontalLineSize = CGSize(width: collectionViewContentSize.width, height: separatorLineWidth)
            let decoratorHorizontalAttribut = UICollectionViewLayoutAttributes(forDecorationViewOfKind: Element.decoratorHorizontalView.kind, with: indexPath)
            decoratorHorizontalAttribut.frame = CGRect(origin: CGPoint(x: 0, y: locationY), size: horizontalLineSize)
            decoratorHorizontalAttribut.zIndex = Zindex.decoratorView
            cashedAttributs[Element.decoratorHorizontalView]?[indexPath] = decoratorHorizontalAttribut
        }
        //add vertical view-separator
        for column in 0...(totalColumnsCount) {
            let indexPath = IndexPath(row: 0, section: column)
            let rawLocationX = sectionSize.width/CGFloat(columnsCountPerScreen) * CGFloat(column)
            let locationX = column == 0 ? rawLocationX : rawLocationX - separatorLineWidth
            let decoratorVerticalAttribut = UICollectionViewLayoutAttributes(forDecorationViewOfKind: Element.decoratorVerticalView.kind, with: indexPath)
            let verticalLineSize = CGSize(width: separatorLineWidth, height:  collectionViewContentSize.height)
            decoratorVerticalAttribut.frame = CGRect(origin: CGPoint(x: locationX, y: 0), size: verticalLineSize)
            decoratorVerticalAttribut.zIndex = Zindex.decoratorView
            cashedAttributs[Element.decoratorVerticalView]?[indexPath] = decoratorVerticalAttribut
        }
    }

    private func resetCashe() {
        cashedAttributs.removeAll(keepingCapacity: true)
        cashedAttributs[Element.supplementaryView] = [IndexPath:UICollectionViewLayoutAttributes]()
        cashedAttributs[Element.decoratorVerticalView] = [IndexPath:UICollectionViewLayoutAttributes]()
        cashedAttributs[Element.decoratorHorizontalView] = [IndexPath:UICollectionViewLayoutAttributes]()
        cashedAttributs[Element.cellView] = [IndexPath:UICollectionViewLayoutAttributes]()
    }
    
}

