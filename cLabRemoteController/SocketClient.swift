//
//  socketClient.swift
//  cLabRemoteController
//
//  Created by Tim Lu on 2018/5/20.
//  Copyright © 2018 Demilab. All rights reserved.
//

import Foundation

class SocketClient : NSObject{
    private var host: String;
    var streamSocket: SocketPort;
    var commandSocket: SocketPort;
    private var streamClientDelegate: StreamClientDelegate;
    
    init(host: String) {
        print("on Main thread?", Thread.isMainThread)
        print("multi thread?", Thread.isMultiThreaded())
        self.host = host
        streamClientDelegate = StreamClientDelegate()
        print("stream delegate constructed")
        streamSocket = SocketPort.init()
        print("stream socket port opened")
        streamSocket.setDelegate(streamClientDelegate)
        print("stream socket delegate assigned")
        commandSocket = SocketPort.init()
        print("command socket opened")
        RunLoop.current.add(streamSocket, forMode: RunLoopMode.commonModes);
        print("stream socket added to runloop")
        RunLoop.current.add(commandSocket, forMode: RunLoopMode.commonModes);
        print("command socket added to socket")
        //RunLoop.current.run();
        print("runloop starts to run")
    }
    
    func setConn(host: String) {
        // Invalidate previous socket instance
        streamSocket.invalidate()
        commandSocket.invalidate()
        RunLoop.current.remove(streamSocket, forMode: RunLoopMode.commonModes)
        RunLoop.current.remove(commandSocket, forMode: RunLoopMode.commonModes)
        
        self.host = host
        self.streamSocket = SocketPort.init(remoteWithTCPPort: 8888, host: self.host)!
        print("assign new stream socket")
        self.commandSocket = SocketPort.init(remoteWithTCPPort: 8889, host: self.host)!
        print("assign new command socket")
        self.streamSocket.setDelegate(streamClientDelegate)
        print("stream socket assign new delegate")
        RunLoop.current.add(streamSocket, forMode: RunLoopMode.commonModes);
        RunLoop.current.add(commandSocket, forMode: RunLoopMode.commonModes);
    }
    
    func sendCommand(cmd: String) {
        // Guarantees to send in 0.1 second
        // Reserves 1Kb for header
        //commandSocket.send(before: Date.init(timeIntervalSinceNow: 0.1), components: , from: , reserved: 1024)
        // send ("NCTUEEclass20htlu," + cmd)
    }
    
    deinit {
        print("socket CLIENT destruct STARTS")
        RunLoop.current.remove(streamSocket, forMode: RunLoopMode.commonModes)
        RunLoop.current.remove(commandSocket, forMode: RunLoopMode.commonModes)
        streamSocket.invalidate()
        commandSocket.invalidate()
        print("socket CLIENT destruct ENDS")
    }
}

class StreamClientDelegate: NSObject, PortDelegate{
    var image: CGImage?
    func handle(_ message: PortMessage) {
        print("got image!")
        print(message)
        // decode image
        //image = CGImage(jpegDataProviderSource: CGDataProvider(url: "localhost:8888" as! CFURL)!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
        print("image decoded!")
    }
}
