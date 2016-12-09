//
//  PrinterController.swift
//  PrinterEngine
//
//  Created by Hyunwoo on 2016. 3. 9..
//  Copyright © 2016년 Nolgong. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum Font{
    case FontA, FontB
}

class PrinterController{
    static let sharedInstance = PrinterController()

    let pController:BXPrinterController
    let printer:BXPrinter
    var printerAddress:String = ""
    
    let convertToWidth = 16
    let printLevel: Int = 1050

    let MEMBER_COUNT_MIN: Int = 1
    var MEMBER_COUNT_MAX: Int = 1
    let SKILL_COUNT: Int = 4
    let MEMBER_COUNT_ZERO: Int = 0
    let ONE_LINE_STRING_MIN: Int = 0
    let ONE_LINE_STRING_MAX: Int = 10

    var delegate: BXPrinterControlDelegate!{
        get{
            return pController.delegate
        }
        set(newDelegate){
            pController.delegate = newDelegate
        }
    }

    private init(){
        self.pController = BXPrinterController()
        self.printer = BXPrinter()
    }

    func setConfigurationWithBluetooth()->Bool{
        pController.lookupCount = 5
        pController.AutoConnection = Int(BXL_CONNECTIONMODE_NOAUTO)
        pController.open()
        printer.connectionClass = UInt16(BXL_CONNECTIONCLASS_BT)
        printer.macAddress = NSUserDefaults.standardUserDefaults().objectForKey("printerMacAddress") as! String
        pController.target = printer
        print("target setting")
        print("searching problem = \(pController.selectTarget())")
        pController.textEncoding = BXL_TEXTENCODING_KSC5601.hashValue
        pController.textSize = Int(BXL_TS_0WIDTH | BXL_TS_0HEIGHT)
        print("pController macAddress \(printer.macAddress)")

        if pController.connect(){
            print("connect")
            print(BXL_SUCCESS)
            NSNotificationCenter.defaultCenter().postNotificationName("checkConnection", object: nil, userInfo: ["target":"printer", "status":true])
            return true
        } else{
            print("disconnected")
            NSNotificationCenter.defaultCenter().postNotificationName("checkConnection", object: nil, userInfo: ["target":"printer", "status":false])
            return false
        }
    }

    func setConfiguration()->Bool{
        pController.lookupCount = 5
        print("lookup count 5")
        pController.AutoConnection = Int(BXL_CONNECTIONMODE_NOAUTO)
        print("no Auto Connection")
        pController.open()
        print("controller open")
        printer.connectionClass = UInt16(BXL_CONNECTIONCLASS_ETHERNET)
        printer.address = NSUserDefaults.standardUserDefaults().objectForKey("printerIp") as! String

        print("address is \(printer.address)")
        printer.port = 9100
        pController.target = printer
        pController.selectTarget()
//        pController.textEncoding = BXL_TEXTENCODING_SINGLEBYTEFONT.hashValue
        pController.textEncoding = BXL_TEXTENCODING_KSC5601.hashValue
        pController.textSize = Int(BXL_TS_1WIDTH | BXL_TS_1HEIGHT)
        if pController.connect(){
            print("connect")
            print(BXL_SUCCESS)
            NSNotificationCenter.defaultCenter().postNotificationName("checkConnection", object: nil, userInfo: ["target":"printer", "status":true])
            return true
        } else{
            print("disconnected")
            NSNotificationCenter.defaultCenter().postNotificationName("checkConnection", object: nil, userInfo: ["target":"printer", "status":false])
            return false
        }
    }

    func connectPrinter(ip : String)->Bool{
        self.printerAddress = ip
        if let index = ip.lowercaseString.characters.indexOf(":") {
            print("Index: \(index)")
            NSUserDefaults.standardUserDefaults().setValue(ip, forKey: "printerMacAddress")
            return self.setConfigurationWithBluetooth()
        }
        else{
            NSUserDefaults.standardUserDefaults().setValue(ip, forKey: "printerIp")
            return self.setConfiguration()
        }
    }
    
    func connectPrinter()->Bool{
        if let index = printerAddress.lowercaseString.characters.indexOf(":") {
            print("Index: \(index)")
            NSUserDefaults.standardUserDefaults().setValue(printerAddress, forKey: "printerMacAddress")
            return self.setConfigurationWithBluetooth()
        }
        else{
            NSUserDefaults.standardUserDefaults().setValue(printerAddress, forKey: "printerIp")
            return self.setConfiguration()
        }
    }

    func isConnected() -> Bool{
        return pController.connect()
    }
    

    func printText(text: String){
        setFontSize(0, height: 0)
        pController.attribute = Int(BXL_FT_DEFAULT)
        pController.printText(text)
    }

    func printText(){
        pController.printText("Connect")
    }

    func printlnText(text : String){
        pController.printText(text)
        lineFeed(1)
    }
    
    func printlnText() -> Bool{
        print("ENTER print text")
        print("PRINT START : \(pController.state)")
        let printState = pController.printText("text")
        pController.printText("테스트")
        print("PRINT DOING : \(printState)")
        if pController.state == 0 && printState == 0 {
            lineFeed(8)
            return true
        }
        return false
    }

    //사용시 feed와 align의 순서가 중요하다. feed>align>print 순으로 하면 print 위로 적용시키려던 feed가 적용되지 않는다.
    func lineFeed(lines : Int) -> Bool{
        if pController.lineFeed(lines) == 0 {
            return true
        }
        return false
    }

    func lineFeed() -> Int{
        return pController.lineFeed(8)
    }

    func cut() -> Int{
        return pController.cutPaper()
    }

    func setAlign(align: Int){
        pController.alignment = align
    }

    func setFontSize(width:Int, height:Int){
        pController.textSize = width * convertToWidth + height
    }

    func setAttribute(font:Font, bold:Bool, underLine:Bool, invert:Bool){
        var option = Int(BXL_FT_DEFAULT)
        if font==Font.FontB{
            option += Int(BXL_FT_FONTB)
        }
        if bold{
            option += Int(BXL_FT_BOLD)
        }
        if underLine{
            option += Int(BXL_FT_UNDERLINE)
        }
        if invert{
            option += Int(BXL_FT_REVERSE)
        }
        pController.attribute = option.hashValue
    }


    func printDate(unixTime:Double){
        let date: String = convertDate(unixTime)
        printText(date)
    }

    func printDate(){
        let date: String = convertDate()
        printText(date)
    }

    func convertDate(unixTime:Double) -> String{
        let responseDate = NSDate(timeIntervalSince1970:unixTime)
        let dateFormatter = NSDateFormatter()
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
        dateFormatter.dateFormat = "yyyy/MM/dd h:mma"
        dateFormatter.locale = NSLocale(localeIdentifier: "ko_KR")
        let convertDate = dateFormatter.stringFromDate(responseDate)

        return convertDate
    }

    func convertDate() -> String{
        let responseDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.AMSymbol = "am"
        dateFormatter.PMSymbol = "pm"
        dateFormatter.dateFormat = "yyyy/MM/dd h:mma"
        dateFormatter.locale = NSLocale(localeIdentifier: "ko_KR")
        let convertDate = dateFormatter.stringFromDate(responseDate)

        return convertDate
    }

    func printHyphen(){
        pController.alignment = BXL_ALIGNMENT_CENTER.hashValue
        setFontSize(0, height: 0)
        pController.attribute = Int(BXL_FT_DEFAULT)
        self.printText("- - - - - - - - - - - - - - - - - - - -")
        self.lineFeed(1)
    }

    func printAsterisk(){
        pController.alignment = BXL_ALIGNMENT_CENTER.hashValue
        setFontSize(0, height: 0)
        pController.attribute = Int(BXL_FT_DEFAULT)
        self.printText("* * * * * * * * * * * * * * * * * * * *")
        self.lineFeed(1)
    }
    
    
    func printCandleMsgs(msgs: JSON){
        
        let totalCount = msgs["count"].intValue - 1
        let cards = msgs["cards"].arrayValue
        

        
        for index in 0...totalCount{
            setFontSize(0, height: 0)
            pController.alignment = BXL_ALIGNMENT_LEFT.hashValue
            pController.lineFeed(1)
            pController.printText("이름 : " + cards[index]["message"].stringValue)
            pController.lineFeed(1)
            pController.printText("의견 : " + cards[index]["message"].stringValue)
            pController.lineFeed(1)
            printAsterisk()
        }
        pController.cutPaper()

    }

}
