//
//  CollectionViewCell.swift
//  CollectionViewTest
//
//  Created by Vitaliy Korobitsyn on 3/13/18.
//  Copyright © 2018 Vitaliy Korobitsyn. All rights reserved.
//

import UIKit

class CalendarMonthEventViewCell: UICollectionViewCell, SingleReuseIdentifier {
    
    private let imageSize: CGSize = CGSize(width: 20, height: 20)
    private let contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 1, bottom: 1, trailing: 1)
    private let borderWidth:CGFloat = 0.6
    private let cornerRadius: CGFloat = 2
    private var eventTypeImageViewWidthConstraint: NSLayoutConstraint?
    private var accountTypeImageViewWidthConstraint: NSLayoutConstraint?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = ""
        label.numberOfLines = 1
        label.textColor = UIColor.black
        label.font = UIFont.italicSystemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var eventTypeImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var accountTypeImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text?.removeAll()
        borderColor = UIColor.clear
        textColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    var textColor: UIColor = UIColor.black {
        didSet {
            titleLabel.textColor = textColor
        }
    }
    var accountTypeImage: UIImage? {
        didSet{
            if accountTypeImage == nil {
                accountTypeImageView.isHidden = true
                accountTypeImageViewWidthConstraint?.constant = 0
            } else {
                accountTypeImageView.isHidden = false
                accountTypeImageViewWidthConstraint?.constant = imageSize.width
            }
            accountTypeImageView.image = accountTypeImage
        }
    }
    
    var eventTypeImage: UIImage? {
        didSet{
            if eventTypeImage == nil {
                eventTypeImageView.isHidden = true
                eventTypeImageViewWidthConstraint?.constant = 0
            } else {
                eventTypeImageView.isHidden = false
                eventTypeImageViewWidthConstraint?.constant = imageSize.width
            }
            eventTypeImageView.image = eventTypeImage
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawBorders()
    }

    private(set) var viewModel: CalendarMonthEventViewModel?
    
    private func initialSetup() {
        self.clipsToBounds = true
        self.addSubview(eventTypeImageView)
        eventTypeImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentInsets.leading).isActive = true
        eventTypeImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: contentInsets.top).isActive = true
        eventTypeImageViewWidthConstraint = eventTypeImageView.widthAnchor.constraint(equalToConstant: imageSize.width)
        eventTypeImageViewWidthConstraint?.isActive = true
        eventTypeImageView.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true

        self.addSubview(accountTypeImageView)
        accountTypeImageView.leadingAnchor.constraint(equalTo: eventTypeImageView.trailingAnchor).isActive = true
        accountTypeImageView.centerYAnchor.constraint(equalTo: eventTypeImageView.centerYAnchor).isActive = true
        accountTypeImageViewWidthConstraint = accountTypeImageView.widthAnchor.constraint(equalToConstant: imageSize.width)
        accountTypeImageViewWidthConstraint?.isActive = true
        accountTypeImageView.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true

        self.addSubview(titleLabel)
        let laedingToImage = titleLabel.leadingAnchor.constraint(equalTo: accountTypeImageView.trailingAnchor)
        laedingToImage.isActive = true
        laedingToImage.priority = .init(900)
        titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: accountTypeImageView.centerYAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: self.trailingAnchor, constant: -contentInsets.trailing).isActive = true
        
    }
    
    private func drawBorders() {
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        //draw top solid line
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        path.lineWidth = contentInsets.top
        path.move(to: CGPoint(x: 0, y: contentInsets.top/2))
        path.addLine(to: CGPoint(x: self.frame.width, y: contentInsets.top/2))
        layer.path = path.cgPath
        layer.strokeColor = borderColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = contentInsets.top
        self.layer.addSublayer(layer)
    }
    
    func setupData(with viewModel: CalendarMonthEventViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = viewModel.titleText
        self.textColor = viewModel.textColor
        self.backgroundColor = viewModel.backGroundColor
        self.borderColor = viewModel.borderColor
        self.accountTypeImage = viewModel.accountTypeImage
        self.eventTypeImage = viewModel.eventTypeImage
        setNeedsDisplay()
    }
}
