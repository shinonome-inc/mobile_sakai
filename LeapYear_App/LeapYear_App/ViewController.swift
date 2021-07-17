//
//  ViewController.swift
//  LeapYear_App
//
//  Created by Sakai Syunya on 2020/07/15.
//  Copyright © 2020 Sakai Syunya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var Yearlabel: UILabel!
    @IBOutlet weak var field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func isLeap(year: Int) -> Bool{
        if(year%400 == 0 || (year % 4 == 0 && year % 100 != 0)){
            return true
        }else{
            return false
        }
    }
    
    @IBAction func ChangeTextButton(_ sender: Any) {
        var num = 0
        
        if let val:Int = Int(field.text!){
            num = val
        }
        
        if isLeap(year: num){
            Yearlabel.text = "is LeapYear"
        
        }else{
            Yearlabel.text = "is not LeapYear"
        }
    }
    
}

