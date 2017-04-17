//
//  FlowersViewController.swift
//  HTHorizontalSelectionListExample
//
//  Created by Erik Ackermann on 3/25/15.
//  Copyright (c) 2015 Hightower. All rights reserved.
//

import UIKit

@objc class FlowersViewController: UIViewController, HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource {

    var selectionList : HTHorizontalSelectionList?
    let flowers : [UIImageView] = [UIImageView(image: UIImage(named: "flower1.jpeg")),
        UIImageView(image: UIImage(named: "flower2.jpeg")),
        UIImageView(image: UIImage(named: "flower3.jpeg")),
        UIImageView(image: UIImage(named: "flower4.jpeg")),
        UIImageView(image: UIImage(named: "flower5.jpeg")),
        UIImageView(image: UIImage(named: "flower6.jpeg")),
        UIImageView(image: UIImage(named: "flower7.jpeg")),
        UIImageView(image: UIImage(named: "flower8.jpeg"))]
    var selectedFlowerView : UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = UIRectEdge()

        let selectionList = HTHorizontalSelectionList(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 80))
        selectionList.delegate = self
        selectionList.dataSource = self

        selectionList.selectionIndicatorStyle = .buttonBorder
        selectionList.selectionIndicatorColor = UIColor.blue
        selectionList.bottomTrimHidden = true

        selectionList.buttonInsets = UIEdgeInsetsMake(3, 10, 3, 10);

        view.addSubview(selectionList)

        let selectedFlowerView = UIImageView()
        selectedFlowerView.image = flowers[selectionList.selectedButtonIndex].image
        selectedFlowerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectedFlowerView)

        view.addConstraint(NSLayoutConstraint(item: selectedFlowerView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0))

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[selectionList]-margin-[selectedFlowerView]",
            options: NSLayoutFormatOptions(),
            metrics: ["margin" : 50],
            views: ["selectionList" : selectionList, "selectedFlowerView" : selectedFlowerView]))

        self.selectionList = selectionList
        self.selectedFlowerView = selectedFlowerView
    }

    // MARK: - HTHorizontalSelectionListDataSource Protocol Methods

    func numberOfItems(in selectionList: HTHorizontalSelectionList) -> Int {
        return flowers.count
    }

    func selectionList(_ selectionList: HTHorizontalSelectionList, viewForItemWith index: Int) -> UIView? {
        return flowers[index]
    }

    // MARK: - HTHorizontalSelectionListDelegate Protocol Methods

    func selectionList(_ selectionList: HTHorizontalSelectionList, didSelectButtonWith index: Int) {
        // update the view for the corresponding index
        selectedFlowerView?.image = flowers[index].image
    }

}
