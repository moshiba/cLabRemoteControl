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
    
    @IBAction func StopSocketButtonPress(_ sender: Any) {
        socket.setConn(host: "127.0.0.1")
        RunLoop.current.run()
        print("socket set connection towards 127.0.0.1")
    }
    var socket = SocketClient(host: "127.0.0.1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.streamSocket = SocketPort.init(remoteWithTCPPort: 8888, host: self.host)!;
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }


}

