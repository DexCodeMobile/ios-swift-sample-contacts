//
//  KContactViewController.swift
//  SwiftSampleContacts
//
//  Created by Dexter Kim on 2014-12-22.
//  Copyright (c) 2014 DexMobile. All rights reserved.
//

import UIKit
import Alamofire

class KContactViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Const variables
    let navTitle = "Swift Sample Contacts"
    let sectionHeight: CGFloat = 35.0
    let sectionTextFont: CGFloat = 20.0
    let randomUserURL: String = "http://api.randomuser.me/?results=500"
    let refreshControl = UIRefreshControl()
    
    // Data handling variables
    var usersByOrder = [String : Array<User>]()
    var sortedKeys = Array<String>()
    var imageCache = [String : UIImage]()
    
    enum POPULATION_TYPE: Int {
        case FirstPopulate
        case Refresh
    }
    
    // Initialization for views
    func setupView() {
        self.navigationItem.title = navTitle
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        
        var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .Vertical
        layout.headerReferenceSize = CGSizeMake(0, sectionHeight)
        
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(KContactCollectionViewCell.self, forCellWithReuseIdentifier: "KContactCollectionViewCell")
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "KContactCollectionReusableView")
        collectionView.backgroundColor = UIColor.whiteColor()
        
        refreshControl.tintColor = UIColor.darkGrayColor()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
    }
    
    // populate data from Random User
    func populateUsers(popType: POPULATION_TYPE) {
        
        popType == POPULATION_TYPE.FirstPopulate ? SVProgressHUD.show() : refreshControl.beginRefreshing()
        
        Alamofire.request(.GET, randomUserURL.URLString)
            .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                println("\(bytesRead), \(totalBytesRead), \(totalBytesExpectedToRead)")
                
                if totalBytesRead == totalBytesExpectedToRead {
                    println("Finish to read")
                    self.usersByOrder.removeAll(keepCapacity: false)
                    self.collectionView!.reloadData()
                }
            }
            .responseCollection({ (request, response, users: [User]?, error) in
                if (users?.isEmpty == nil) {
                    println("There is no list")
                } else if error == nil {
                    
                    var varUsers = users!
                    for user: User in varUsers {
                        // First character of the first name is the key of user data
                        let firstChar = String(Array(user.name.first)[0])
                        if ((self.usersByOrder[firstChar]) == nil) {
                            let userArray = [User](arrayLiteral: user)
                            self.usersByOrder[firstChar] = userArray
                        } else {
                            var userArray = self.usersByOrder[firstChar]! as [User]
                            userArray.append(user)
                            self.usersByOrder[firstChar] = userArray
                        }
                    }
                    
                    // sort keys
                    self.sortedKeys = Array(self.usersByOrder.keys)
                    self.sortedKeys.sort({ $0 < $1 })
                    
                    self.collectionView.reloadData()
                    
                    SVProgressHUD.dismiss()
                    self.refreshControl.endRefreshing()
                } else {
                    println(error)
                }
            })
    }
    
    // Refresh by scrolling down
    func handleRefresh() {
        populateUsers(POPULATION_TYPE.Refresh)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        populateUsers(POPULATION_TYPE.FirstPopulate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "DetailSegue" {
            if let detailVC: KDetailViewController = segue.destinationViewController as? KDetailViewController {
                if let indexPath = collectionView.indexPathsForSelectedItems().first as? NSIndexPath {
                    let key = self.sortedKeys[indexPath.section] as String
                    if let userinfo = self.usersByOrder[key] {
                        detailVC.userInfo = userinfo[indexPath.row]
                        // just pass the cached image directly so that avoid to re-download it
                        detailVC.imageCach = self.imageCache
                        let userName = userinfo[indexPath.row].name
                        detailVC.navigationItem.title = userName.first + " " + userName.last
                    }
                }
            }
        }
    }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(0, sectionHeight)
    }
    
    
    // MARK: - UICollectionViewDatasource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.usersByOrder.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = self.sortedKeys[section] as String
        return self.usersByOrder[key]!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("KContactCollectionViewCell", forIndexPath: indexPath) as KContactCollectionViewCell
        
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        cell.backgroundColor = UIColor.whiteColor()
        
        let key = self.sortedKeys[indexPath.section] as String
        let userInfo = self.usersByOrder[key]![indexPath.row]
        let userName = userInfo.name.first + " " + userInfo.name.last
        cell.textLabel.text = userName
        
        // Just for testing.
        // It would show a image using the initial of the user's name if there was no image
        if (indexPath.row % 10 == 0) {
            cell.imageView.setImageWithString(userName)
            return cell
        }
        
        // Downlaod images and caches them in the background
        var image = self.imageCache[userInfo.picture.medium]
        if (image == nil) {
            var imgURL = NSURL(string: userInfo.picture.medium);
            
            let request: NSURLRequest = NSURLRequest(URL: imgURL!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    
                    self.imageCache[userInfo.picture.medium] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = collectionView.cellForItemAtIndexPath(indexPath) as? KContactCollectionViewCell {
                            cellToUpdate.imageView.image = image
                        }
                    })
                }
                else {
                    cell.imageView.setImageWithString(userName)
                    println("Error: \(error.localizedDescription)")
                }
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = collectionView.cellForItemAtIndexPath(indexPath) as? KContactCollectionViewCell {
                    cellToUpdate.imageView.image = image
                }
            })
        }
        
        return cell
    }
    
    // Section Header View
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if(kind == UICollectionElementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "KContactCollectionReusableView", forIndexPath: indexPath) as UICollectionReusableView
            headerView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
            if headerView.subviews.count == 0 {
                let lblWidth: CGFloat = 30
                headerView.addSubview(UILabel(frame:CGRectMake(10,0,lblWidth,sectionHeight)))
            }
            let lab = headerView.subviews[0] as UILabel
            lab.text = self.sortedKeys[indexPath.section].uppercaseString
            lab.textAlignment = .Center
            lab.font = UIFont.boldSystemFontOfSize(sectionTextFont)
            return headerView
        } else {
            assert(false, "Invalid SupplementaryElementOfKind")
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        self.performSegueWithIdentifier("DetailSegue", sender: cell);
    }
}