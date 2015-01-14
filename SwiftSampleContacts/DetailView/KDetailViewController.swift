//
//  KDetailViewController.swift
//  SwiftSampleContacts
//
//  Created by Dexter Kim on 2014-12-22.
//  Copyright (c) 2014 DexMobile. All rights reserved.
//

import UIKit

class KDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var userInfo: User!
    var imageCach = [String : UIImage]()
    var userImgView: KCImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhone: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Index of TableView Row
    enum ITEMLIST: Int {
        case Gender
        case Location
        case Cell
        case Email
        case DOB
        
        static let count = [Gender, Location, Cell, Email, DOB].count
    }
    
    // Initialize Views
    func setupViews() {
        backgroundView.layer.cornerRadius = backgroundView.frame.size.height/2;
        backgroundView.layer.masksToBounds = true;
        backgroundView.layer.borderWidth = 0;
        
        let width = backgroundView.frame.size.width-10;
        let height = backgroundView.frame.size.height-10;
        let x = backgroundView.frame.size.width/2 - width/2;
        let y = backgroundView.frame.size.height/2 - height/2;
        userImgView = KCImageView(frame: CGRect(x: x, y: y, width: width, height: height))
        userImgView.basicSetting()
        backgroundView.addSubview(userImgView)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func updateUserInfo() {
        let userName = userInfo.name.first + " " + userInfo.name.last
        let key = userInfo.picture.medium as String
        var image = imageCach[key]
        if (image != nil) {
            userImgView.image = imageCach[key]
        } else {
            let userName = userInfo.name.first + " " + userInfo.name.last
            userImgView.setImageWithString(userName)
        }
        
        self.userName.text = userName
        self.userPhone.text = userInfo.phone
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUserInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }

    //MARK: - UITableViewDatasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ITEMLIST.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("infoCell") as UITableViewCell
        
        if let titleView = cell.viewWithTag(10) {
            if let valueView = cell.viewWithTag(11) {
                return cell
            }
        }
        
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        let lblTitle = UILabel()
        lblTitle.tag = 10
        cell.addSubview(lblTitle)
        let x: CGFloat = lblTitle.frame.origin.x+lblTitle.frame.size.width
        let lblValue = UILabel()
        lblValue.tag = 11
        lblValue.numberOfLines = 2
        lblValue.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.addSubview(lblValue)
                
        lblTitle.setTranslatesAutoresizingMaskIntoConstraints(false)
        lblValue.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        var viewsDict = Dictionary <String, UIView>()
        viewsDict["lblTitle"] = lblTitle
        viewsDict["lblValue"] = lblValue
        
        cell.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-10-[lblTitle(80)]-[lblValue]-|", options: nil, metrics: nil, views: viewsDict))
        
        cell.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-[lblTitle]-|", options: nil, metrics: nil, views: viewsDict))
        
        cell.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-[lblValue]-|", options: nil, metrics: nil, views: viewsDict))
        
        let itemlist: ITEMLIST = ITEMLIST(rawValue: indexPath.row)!
        switch (itemlist) {
        case .Gender:
            lblTitle.text = "Gender"
            lblValue.text = userInfo.gender
        case .Location:
            lblTitle.text = "Location"
            let street = userInfo.location.street
            let city = userInfo.location.city
            let state = userInfo.location.state
            let zip = userInfo.location.zip
            lblValue.text = "\(street), \(city), \(state), \(zip)"
        case .Email:
            lblTitle.text = "Email"
            lblValue.text = userInfo.email
        case .Cell:
            lblTitle.text = "Cell"
            lblValue.text = userInfo.cell
        case .DOB:
            lblTitle.text = "DOB"
            lblValue.text = userInfo.dob
        }
        
        return cell
    }
}
