//
//  CustomLayout.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/13/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import UIKit

protocol CalendarMonthViewCustomLayoutDataSource: class {
    func dateInterval(by indexPath: IndexPath) -> DateInterval
    func daysDurationCell(with indexPath: IndexPath) -> Int
    func doesCellPlacedEarlier(cellIndexPath: IndexPath) -> Bool
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
    //Config
    let columnsCountPerScreen: CGFloat = 7
    let rowsCountPerScreen: CGFloat = 5
    let separatorLineWidth: CGFloat = 0.6
    let cellHeight: CGFloat = 25
    let verticalCellsDistance: CGFloat = 2
    let cellsInsetsInsideTile = UIEdgeInsets(top: 40, left: 0, bottom: 30, right: 0)
    
    var maxVisibleCellPerSection: Int {
        let tileFrame = CGRect(origin: .zero, size: tileSize)
        let frameToPresentCells = UIEdgeInsetsInsetRect(tileFrame, cellsInsetsInsideTile)
        let count = frameToPresentCells.height/(cellHeight + verticalCellsDistance).rounded(FloatingPointRoundingRule.down)
        return Int(count)
    }
    
    var totalRowsCount: Int {
        guard let maxIndex = collectionView?.numberOfSections else { return 0 }
        let computedRowsCount = Int(matrixPosition(by: maxIndex - 1).row) + 1
        return max(computedRowsCount, Int(rowsCountPerScreen))
    }
    
    var totalColumnsCount: Int {
        guard let maxIndex = collectionView?.numberOfSections else { return 0 }
        let computedColumnsCount = Int(matrixPosition(by: maxIndex - 1).column) + 1
        return max(computedColumnsCount, Int(columnsCountPerScreen))
    }
    
    var tileSize: CGSize  {
        let collectionViewSize: CGSize = collectionView?.bounds.size ?? .zero
        return CGSize(width: collectionViewSize.width/columnsCountPerScreen, height: collectionViewSize.height/rowsCountPerScreen)
    }
    
    private var oldBounds = CGRect.zero
    
    private var contentHeight: CGFloat = 0

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
        self.register(UINib.init(nibName: "CalendarMonthDecoratorView", bundle: nil), forDecorationViewOfKind: Element.decoratorVerticalView.kind)
        self.register(UINib.init(nibName: "CalendarMonthDecoratorView", bundle: nil), forDecorationViewOfKind: Element.decoratorHorizontalView.kind)
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
            let row = matrixPosition(by: section).row
            let column = matrixPosition(by: section).column
            let locationX = tileSize.width * column
            let locationY = tileSize.height * row
            let supplementaryAttribut = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: Element.supplementaryView.kind, with: indexPath)
            supplementaryAttribut.frame = CGRect(origin: CGPoint(x: locationX, y: locationY), size: tileSize)
            supplementaryAttribut.zIndex = Zindex.supplementaryView
            cashedAttributs[Element.supplementaryView]?[indexPath] = supplementaryAttribut
            fillCellsAttributes(for: section)
        }
        contentHeight = tileSize.height*CGFloat(totalRowsCount)
        fillSeparatorsAttributes()
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if oldBounds.size != newBounds.size {
            cashedAttributs.removeAll(keepingCapacity: true)
        }
        return true
    }
    
    private func fillCellsAttributes(for section: Int) {
        guard let collectionView = collectionView, let dataSource = dataSource else { return }
        let maxVisibleCells = maxVisibleCellPerSection
        var processedVerticalIndex = 0
        let doesCellOnFirstColumn = matrixPosition(by: section).column == 0
        guard let currentTileFrame = frameToDrawCells(inside: section) else { return }
        let cellsFramesIntersectsCurrentTile: [CGRect] = cashedAttributs[.cellView]?.filter({ (_, atribute) -> Bool in
            return atribute.frame.intersects(currentTileFrame)
        }).map {$0.value.frame} ?? []
        for item in 0..<collectionView.numberOfItems(inSection: section) {
            let indexPath = IndexPath(item: item, section: section)
            
            if dataSource.doesCellPlacedEarlier(cellIndexPath: indexPath) && !doesCellOnFirstColumn {
                processedVerticalIndex += 1
                continue
            }
            guard let initialCellFrame = initialCellRect(for: indexPath) else { continue }
            var floatFrame = initialCellFrame
            repeat {
                floatFrame = initialCellFrame.offsetBy(dx: 0, dy: CGFloat(processedVerticalIndex)*(cellHeight + verticalCellsDistance))
                processedVerticalIndex += 1
                if !doesFrameIntersects(targetFrame: floatFrame, with: cellsFramesIntersectsCurrentTile) {
                    break
                }
            } while processedVerticalIndex < maxVisibleCells
            if processedVerticalIndex > maxVisibleCells {
                return
            }
            let cellAttribut = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            cellAttribut.frame = floatFrame
            cellAttribut.zIndex = Zindex.cellView
            cashedAttributs[Element.cellView]?[indexPath] = cellAttribut
        }
    }
    
    private func doesFrameIntersects(targetFrame: CGRect, with frames: [CGRect]) -> Bool {
        for frame in frames {
            if frame.intersects(targetFrame) {
                return true
            }
        }
        return false
    }
    
    private func initialCellRect(for indexPath: IndexPath) -> CGRect? {
        guard let daysDuration = self.dataSource?.daysDurationCell(with: indexPath),
        let tileRect = frameToDrawCells(inside: indexPath.section), let collectionView = collectionView
            else { return nil }
        let length = CGFloat(daysDuration)*tileSize.width
        let cellSize = CGSize(width: length, height: cellHeight)
        var cellFrame = CGRect(origin: tileRect.origin, size: cellSize)
        if collectionView.bounds.maxX >= cellFrame.maxX {//.contains(cellFrame) {
            return cellFrame
        } else {
            cellFrame.size.width = collectionView.bounds.maxX - cellFrame.origin.x
            return cellFrame
        }
    }
    
    private func frameToDrawCells(inside section: Int) -> CGRect? {
        let tileIndexPath = IndexPath(item: 0, section: section)
        if let tileFrame = cashedAttributs[Element.supplementaryView]?[tileIndexPath]?.frame {
            return UIEdgeInsetsInsetRect(tileFrame, cellsInsetsInsideTile)
        }
        return nil
    }

    private func fillSeparatorsAttributes(){
        //add horizontal view-separator
        for row in 0...(totalRowsCount) {
            let indexPath = IndexPath(row: 0, section: row)
            let rawLocationY = tileSize.height * CGFloat(row)
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
            let rawLocationX = tileSize.width * CGFloat(column)
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
    
    //returns row, column started from 0
    private func matrixPosition(by sectionIndex: Int) -> (row: CGFloat, column: CGFloat) {
        let index = CGFloat(sectionIndex) + 1 // +1 to conform range interval started from 1
        let remaiderDiv = index.truncatingRemainder(dividingBy: columnsCountPerScreen )
        let rowNumber = (index/columnsCountPerScreen ).rounded(FloatingPointRoundingRule.up)
        let columnNumber = remaiderDiv == 0 ? index/(rowNumber) : remaiderDiv
        return ((rowNumber - 1),(columnNumber - 1)) // -1 to conform range interval started from 0
    }
    
}
