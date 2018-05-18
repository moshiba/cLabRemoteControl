//
//  Controller.swift
//  cLabRemoteController
//
//  Created by Tim Lu on 2018/5/18.
//  Copyright © 2018 Demilab. All rights reserved.
//

import Foundation
import GameController

class Controller {
    var PhysicalCtrl: GCController?
    
    init() {
        //self.PhysicalCtrl = GameController.GCController()
    }
    
    func getPhysicalControllers() {
        GCController.startWirelessControllerDiscovery() {
            // Completion handler, with paramarers and return value as declared
            () in
            if (GCController.controllers().count == 0) {
                print("[GCCtrl Discovery] Found nothing")
            }
        }
    }
    
    func choosePhysicalController() {
        if (GCController.controllers().count == 0) {
            print("[GCCtrlArray EMPTY] Fallback to keyboard control")
        } else {
            // Read controller profiles then apply filter
        }
    }
}
