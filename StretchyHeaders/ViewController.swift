//
//  ViewController.swift
//  StretchyHeaders
//
//  Created by Matthew Cheok on 21/9/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

import UIKit

private let kTableHeaderHeight: CGFloat = 300
private let kTableHeaderCutAway: CGFloat = 0

class ViewController: UITableViewController {
    var headerView: UIView!
    var headerMaskLayer: CAShapeLayer!
    
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var controlsContainer: UIView!
    
    lazy var segmentControl: YSSegmentedControl = {
        let segmented = YSSegmentedControl(
            frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 50),
            titles: [
                "Seshes",
                "Drafts",
                "Collaboration"
            ])
        segmented.delegate = self
        segmented.swipeSelector = self.tableView
        
        return segmented
    }()
    
    let items = [
        NewsItem(category: .World, summary: "Climate change protests, divestments meet fossil fuels realities"),
        NewsItem(category: .Europe, summary: "Scotland's 'Yes' leader says independence vote is 'once in a lifetime'"),
        NewsItem(category: .MiddleEast, summary: "Airstrikes boost Islamic State, FBI director warns more hostages possible"),
        NewsItem(category: .Africa, summary: "Nigeria says 70 dead in building collapse; questions S. Africa victim claim"),
        NewsItem(category: .AsiaPacific, summary: "Despite UN ruling, Japan seeks backing for whale hunting"),
        NewsItem(category: .Americas, summary: "Officials: FBI is tracking 100 Americans who fought alongside IS in Syria"),
        NewsItem(category: .World, summary: "South Africa in $40 billion deal for Russian nuclear reactors"),
        NewsItem(category: .Europe, summary: "'One million babies' created by EU student exchanges"),
    ]
    
    func updateHeaderView() {
        let effectiveHeight = kTableHeaderHeight-kTableHeaderCutAway / 2
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        
        if tableView.contentOffset.y < -effectiveHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + kTableHeaderCutAway / 2
        } else if tableView.contentOffset.y > -effectiveHeight && tableView.contentOffset.y < 0 {
            headerRect.origin.y = tableView.contentOffset.y;
            headerRect.size.height = -tableView.contentOffset.y;
            //tableView.contentInset = UIEdgeInsets(top: -tableView.contentOffset.y + kTableHeaderCutAway / 2, left: 0, bottom: 0, right: 0)
        } else if tableView.contentOffset.y > -effectiveHeight {
            //tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        headerView.frame = headerRect
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: headerRect.width, y: 0))
        path.addLineToPoint(CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLineToPoint(CGPoint(x: 0, y: headerRect.height-kTableHeaderCutAway))
        headerMaskLayer?.path = path.CGPath
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension

        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        let effectiveHeight = kTableHeaderHeight-kTableHeaderCutAway / 2
        tableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
        
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.blackColor().CGColor
        
        headerView.layer.mask = headerMaskLayer
        updateHeaderView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateHeaderView()
        initSegmentControl()
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ (context) -> Void in
            [self]
            self.updateHeaderView()
            self.tableView.reloadData()
        }, completion: { (context) -> Void in
        })
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return segmentControl
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsItemCell
        cell.newsItem = item
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    private func initSegmentControl() {
        if segmentContainer.subviews.count == 0 {
            segmentContainer.addSubview(segmentControl)
        }
    }
}

var previousTabIndex = 0
extension ViewController: YSSegmentedControlDelegate {
    func segmentedControlDidPressedItemAtIndex(segmentedControl: YSSegmentedControl, index: Int) {
        if previousTabIndex != index {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: previousTabIndex > index ? .Right : .Left)
        }
        previousTabIndex = index
    }
}

