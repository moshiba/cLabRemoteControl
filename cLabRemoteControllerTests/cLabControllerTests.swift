//
//  cLabControllerTests.swift
//  cLabRemoteControllerTests
//
//  Created by Tim Lu on 2018/5/23.
//  Copyright © 2018 Demilab. All rights reserved.
//

import XCTest
@testable import cLabRemoteController

class socketClientTests: XCTestCase {

    var server: MockServer!
    var client: SocketClient!
    
    override func setUp() {
        super.setUp()
        server = MockServer()
        client = SocketClient()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        server.tearDown()
    }

    func testConnectionSetup() {
        client.setConn(host: "localhost")
        XCTAssertEqual(client.host, "localhost")
        XCTAssertEqual(client.imageInputStream.streamStatus.rawValue, 1)
        XCTAssertEqual(client.commandOutputStream.streamStatus.rawValue, 1)
    }
    
    func testSendMessage() {
        client.setConn(host: "localhost")
        client.sendCommand(cmd: "hohoho")
        
    }
}

extension socketClientTests: ImageDelegate {
    
    func receivedMessage(message: Message) {
        print("view got msg:", message)
    }
}
