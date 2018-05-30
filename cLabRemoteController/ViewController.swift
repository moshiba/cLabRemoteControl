//
//  ViewController.swift
//  cLabRemoteController
//
//  Created by Tim Lu on 2018/5/18.
//  Copyright © 2018 Demilab. All rights reserved.
//

import Cocoa
import ImageIO

class ViewController: NSViewController {
    @IBOutlet weak var imageCell: NSImageView!
    @IBOutlet weak var ipField: NSTextField!
    @IBAction func ipFieldFilled(_ sender: Any) {
        guard (ipField.stringValue != "") else {
            print("ipField empty value")
            return
        }
        print("ip button HIT! text:", ipField.stringValue)
        self.socket.setConn(host: ipField.stringValue)
    }
    @IBAction func inputMethodControlAction(_ sender: Any) {
        if (inputMethodControl.isSelected(forSegment: 0)) {  // Keyboard

        } else if (inputMethodControl.isSelected(forSegment: 1)) {  // Game Controller

        } else {
            print("input selection button reports weird activity")
        }
    }
    @IBOutlet weak var inputMethodControl: NSSegmentedControl!
    @IBOutlet weak var directionIndicator: NSSlider!
    @IBOutlet weak var powerLevelIndicator: NSLevelIndicator!


    // Cmd is made of tuple (RightWheelDutyCycle, LeftWheelDutyCycle)
    var commandRepeater = Timer()

    /* Backup Controls */
    let cmdRepeatFreq = 0.35
    @objc func FdWrapper() {
        self.socket.sendCommand(cmd: "80, 80")
    }
    @objc func BkWrapper() {
        self.socket.sendCommand(cmd: "-80, -80")
    }
    @objc func RtWrapper() {
        self.socket.sendCommand(cmd: "-100, 100")
    }
    @objc func LtWrapper() {
        self.socket.sendCommand(cmd: "100, -100")
    }
    @IBAction func FdButtonPressed(_ sender: Any) {
        if (self.commandRepeater.isValid) {
            self.commandRepeater.invalidate()
        }
        self.commandRepeater = Timer.scheduledTimer(timeInterval: cmdRepeatFreq, target: self, selector: #selector(FdWrapper), userInfo: "commandRepeater", repeats: true)
        //self.socket.sendCommand(cmd: "80, 80")
    }
    @IBAction func BkButtonPressed(_ sender: Any) {
        if (self.commandRepeater.isValid) {
            self.commandRepeater.invalidate()
        }
        self.commandRepeater = Timer.scheduledTimer(timeInterval: cmdRepeatFreq, target: self, selector: #selector(BkWrapper), userInfo: "commandRepeater", repeats: true)
        //self.socket.sendCommand(cmd: "-80, -80")
    }
    @IBAction func RtButtonPressed(_ sender: Any) {
        if (self.commandRepeater.isValid) {
            self.commandRepeater.invalidate()
        }
        self.commandRepeater = Timer.scheduledTimer(timeInterval: cmdRepeatFreq, target: self, selector: #selector(RtWrapper), userInfo: "commandRepeater", repeats: true)
        //self.socket.sendCommand(cmd: "-80, 80")
    }
    @IBAction func LtButtonPressed(_ sender: Any) {
        if (self.commandRepeater.isValid) {
            self.commandRepeater.invalidate()
        }
        self.commandRepeater = Timer.scheduledTimer(timeInterval: cmdRepeatFreq, target: self, selector: #selector(LtWrapper), userInfo: "commandRepeater", repeats: true)
        //self.socket.sendCommand(cmd: "80, -80")
    }
    @IBAction func StopButtonPressed(_ sender: NSButton) {
        self.socket.sendCommand(cmd: "0, 0")
        self.commandRepeater.invalidate()
    }
    

    let socket = SocketClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        //socket.imageDelegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        socket.imageDelegate = self
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension ViewController: ImageDelegate {
    func receivedMessage(message: String) {
        print("view got msg:", message)
    }
}
