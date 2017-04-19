//
//  TwoButtonViewController.swift
//  HTHorizontalSelectionListExample
//
//  Created by Erik Ackermann on 4/8/16.
//  Copyright © 2016 Hightower. All rights reserved.
//

import UIKit

@objc class TwoButtonViewController: UIViewController, HTHorizontalSelectionListDelegate, HTHorizontalSelectionListDataSource {

    var selectionList : HTHorizontalSelectionList?
    let titles : [String] = ["Button 1", "Button 2", "Button 3", "Button 4", "Button 5"]
    var selectedTitleLabel : UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge()

        let selectionList = HTHorizontalSelectionList(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 80))
        selectionList.delegate = self
        selectionList.dataSource = self

        selectionList.selectionIndicatorStyle = .buttonBorder
//        selectionList.selectionIndicatorColor = UIColor.red
        selectionList.bottomTrimHidden = true

        selectionList.centerButtons = true
        selectionList.evenlySpaceButtons = false

        selectionList.buttonInsets = UIEdgeInsetsMake(3, 10, 3, 10);

        view.addSubview(selectionList)

        let selectedTitleLabel = UILabel()
        selectedTitleLabel.text = titles[selectionList.selectedButtonIndex]
        selectedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectedTitleLabel)

        view.addConstraint(NSLayoutConstraint(item: selectedTitleLabel,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: view,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0.0))

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[selectionList]-margin-[selectedFlowerView]",
            options: NSLayoutFormatOptions(),
            metrics: ["margin" : 50],
            views: ["selectionList" : selectionList, "selectedFlowerView" : selectedTitleLabel]))

        self.selectionList = selectionList
        self.selectedTitleLabel = selectedTitleLabel
    }

    // MARK: - HTHorizontalSelectionListDataSource Protocol Methods

    func numberOfItems(in selectionList: HTHorizontalSelectionList) -> Int {
        return titles.count
    }

    func selectionList(_ selectionList: HTHorizontalSelectionList, titleForItemWith index: Int) -> String? {
        return titles[index]
    }

    // MARK: - HTHorizontalSelectionListDelegate Protocol Methods

    func selectionList(_ selectionList: HTHorizontalSelectionList, didSelectButtonWith index: Int) {
        // update the view for the corresponding index
        selectedTitleLabel?.text = titles[index]
    }

}
