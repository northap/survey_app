//
//  ViewController.swift
//  SurveyApp
//
//  Created by North on 7/21/2559 BE.
//  Copyright © 2559 North. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import MBProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var takeSurveyButton: UIButton!
    
    let timeToChangeSurvey = 5
    let apiAccessToken = "6eebeac3dd1dc9c97a06985b6480471211a777b39aa4d0e03747ce6acc4a3369"
    var surveyArray = [Survey]()
    var surveyIndex: Int! = 0
    var timer: NSTimer!
    var pageControl: CSPageControl = CSPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()

        self.loadSurvey()
    }
    
    override func viewDidLayoutSubviews() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        self.pageControl.frame = CGRect(x: screenSize.width - 50, y: (self.navigationController?.navigationBar.frame.size.height)! - 10, width: 50, height: screenSize.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        
        self.title = "SURVEYS"
        
        self.hideUI()
        
        //Navigation Bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColorFromRGB(0x182852)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(refreshAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-alt"), style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
        //Page Control
        self.pageControl.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        self.pageControl.dotSize = 10
        self.pageControl.dotSpacing = 10
        self.pageControl.activeStyle = CSPageControlStyle.Filled
        self.pageControl.inactiveStyle = CSPageControlStyle.Outline
        self.pageControl.activeColor = UIColor.whiteColor()
        self.pageControl.userInteractionEnabled = false
        self.view.addSubview(pageControl)
    
        //Button
        self.takeSurveyButton.layer.cornerRadius = 20
    }
    
    func loadSurvey() {
        
        let loadingNoti = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNoti.mode = MBProgressHUDMode.Indeterminate
        
        Alamofire.request(.GET, "https://www-staging.usay.co/app/surveys.json", parameters: ["access_token": self.apiAccessToken])
            .responseArray { (response: Response<[Survey], NSError>) in
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
                switch response.result {
                case .Success(let surveyArray):
                    self.surveyArray = surveyArray
                    self.pageControl.numberOfPages = surveyArray.count
                    
                    self.changeSurvey(true)
                    
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.timeToChangeSurvey), target: self, selector: #selector(self.updateSurvey), userInfo: nil, repeats: true)
                    
                case .Failure(let error):
                    let alert = UIAlertController(title: "Error", message: String(error), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        }
    }
    
    func changeSurvey(highResImage: Bool) {
        
        self.pageControl.currentPage = self.surveyIndex
        self.pageControl.updateCurrentPageDisplay()
        
        let survey: Survey = self.surveyArray[self.surveyIndex]
        
        self.titleLabel.text = survey.title
        self.descriptionLabel.text = survey.description
        
        let getResImageString = (highResImage) ? "" : "l"
        
        if let url = NSURL(string: survey.cover_image_url! + getResImageString) {
            if let data = NSData(contentsOfURL: url) {
                self.coverImageView.image = UIImage(data: data)
            }
        }
        
        self.showUI()
        
        self.surveyIndex = self.surveyIndex + 1
        
        if (self.surveyIndex == self.surveyArray.count) {
            self.surveyIndex = 0
        }
        
    }
    
    func updateSurvey() {
        self.changeSurvey(true)
    }
    
    func refreshAction() {
        self.hideUI()
        
        if (self.timer != nil) {
            self.timer!.invalidate()
            self.timer = nil
        }
        
        self.surveyIndex = 0
        
        self.loadSurvey()
    }
    
    func hideUI() {
        self.titleLabel.hidden = true
        self.descriptionLabel.hidden = true
        self.takeSurveyButton.hidden = true
        self.coverImageView.hidden = true
        self.pageControl.hidden = true
    }
    
    func showUI() {
        self.titleLabel.hidden = false
        self.descriptionLabel.hidden = false
        self.takeSurveyButton.hidden = false
        self.coverImageView.hidden = false
        self.pageControl.hidden = false
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}

