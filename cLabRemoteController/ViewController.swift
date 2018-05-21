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
        print("ip button HIT! text:", ipField.stringValue)
        self.socket.setConn(host: ipField.stringValue)
        /*
        if sockets exist, close them
        create new sockets according to input value
        connect them
        */
    }
    @IBAction func inputMethodControlAction(_ sender: Any) {
    }
    @IBOutlet weak var inputMethodControl: NSSegmentedControl!
    @IBOutlet weak var directionIndicator: NSSlider!
    @IBOutlet weak var powerLevelIndicator: NSLevelIndicator!
    
    var socket = SocketClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.imageDelegate = self
        //socket.setConn(host: "127.0.0.1")
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        //socket.imageDelegate = self
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

