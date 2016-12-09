//
//  PrinterSettingViewController.swift
//  AccIdPrinter
//
//  Created by Bae on 2016. 7. 5..
//  Copyright © 2016년 nolgong. All rights reserved.
//

import UIKit
import SwiftyJSON

class PrinterSettingViewController: UIViewController {

    @IBOutlet weak var savedServIp: UILabel!
    @IBOutlet weak var savedServPort: UILabel!
    @IBOutlet weak var currentIp: UILabel!
    @IBOutlet weak var inputServIp: UITextField!
    @IBOutlet weak var inputServPort: UITextField!
    
    @IBOutlet weak var savedPrinterIp: UILabel!
    @IBOutlet weak var inputPrinterIp: UITextField!
    @IBOutlet weak var logViewer: UITextView!
    
    private let kTimeoutInSeconds:NSTimeInterval = 10 // seconds
    private var timer:NSTimer?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logViewer.text = "Current domain is : \(HTTPClient.sharedInstance.domain)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    @IBAction func setPrinterIp(sender: UIButton) {
        if !inputPrinterIp.text!.isEmpty{
            savedPrinterIp.text = inputPrinterIp.text
            NSUserDefaults.standardUserDefaults().setValue(savedPrinterIp.text!, forKey: "savedPrinterIp")
        }
        if PrinterController.sharedInstance.connectPrinter(savedPrinterIp.text!){
            outputLog("프린터가 연결되었습니다.")
        }else {
            outputLog("프린터가 연결되지 않았습니다.")
        }
    }
    
    @IBAction func testText(sender: UIButton) {
        outputLog("출력 결과")
        let resultCode = PrinterController.sharedInstance.printlnText()
        outputLog("\(resultCode)")
        if !resultCode {
            if PrinterController.sharedInstance.connectPrinter(savedPrinterIp.text!){
                outputLog("프린터가 연결되었습니다.")
            }else {
                outputLog("프린터가 연결되지 않았습니다.")
            }
        }
    }
    
    @IBAction func testCut(sender: UIButton) {
        outputLog("출력 결과")
        let resultCode = PrinterController.sharedInstance.cut()
        outputLog("\(resultCode)")
        if resultCode != 0 {
            if PrinterController.sharedInstance.connectPrinter(savedPrinterIp.text!){
                outputLog("프린터가 연결되었습니다.")
            }else {
                outputLog("프린터가 연결되지 않았습니다.")
            }
        }
    }
    @IBAction func testFeed(sender: UIButton) {
        outputLog("출력 결과")
        let resultCode = PrinterController.sharedInstance.lineFeed()
        outputLog("\(resultCode)")
        if resultCode != 0 {
            if PrinterController.sharedInstance.connectPrinter(savedPrinterIp.text!){
                outputLog("프린터가 연결되었습니다.")
            }else {
                outputLog("프린터가 연결되지 않았습니다.")
            }
        }
    }
    @IBAction func printStatus(sender: UIButton) {
        outputLog("Server IP Address : \(HTTPClient.sharedInstance.domain)")
    }
    
    @IBAction func clearLogViewer(sender: UIButton) {
        self.logViewer.text = ""
    }
    
    func outputLog(text:String){
        let previousLog = self.logViewer.text!
        self.logViewer.text = previousLog + "\n" + text
    }
    
    func startFetching() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(kTimeoutInSeconds,
                                                            target:self,
                                                            selector:#selector(PrinterSettingViewController.fetch),
                                                            userInfo:nil,
                                                            repeats:true)
    }
    
    func stopFetching() {
        let previousLog = self.logViewer.text!
        self.timer!.invalidate()
        self.logViewer.text = previousLog + "\n stop fetching!"
    }
    
    func fetch() {
        let previousLog = self.logViewer.text!
        HTTPClient.sharedInstance.getMsgs { (response) in
            if let msgs = response {
                PrinterController.sharedInstance.printCandleMsgs(msgs)
            }
        }
        self.logViewer.text = previousLog + "\n start fetching!"
    }
    
    
    @IBAction func startPolling(sender: AnyObject) {
        let previousLog = self.logViewer.text!
        self.logViewer.text = previousLog + "\n start polling"
        startFetching()
    }
    
    @IBAction func stopPolling(sender: AnyObject) {
        stopFetching()
    }
    

}
