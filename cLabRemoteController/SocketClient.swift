//
//  socketClient.swift
//  cLabRemoteController
//
//  Created by Tim Lu on 2018/5/20.
//  Copyright © 2018 Demilab. All rights reserved.
//

import Foundation

protocol ImageDelegate: class {
    func receivedMessage(message: String)
}

class SocketClient : NSObject{
    var host: String
    let streamPort: UInt32 = 8888
    let commandPort: UInt32 = 8889
    
    var imageInputStream: InputStream!
    var imageOutputStream: OutputStream!
    
    var commandInputStream: InputStream!
    var commandOutputStream: OutputStream!
    
    weak var imageDelegate: ImageDelegate?
    
    let maxReadLength: Int = 15360
    
    //private var streamClientDelegate: StreamClientDelegate;
    
    override init() {
        print("on Main thread?", Thread.isMainThread)
        print("multi thread?", Thread.isMultiThreaded())
        self.host = "127.0.0.1"
    }
    
    func setConn(host: String) {
        /*
        imageInputStream.close()
        imageOutputStream.close()
        commandInputStream.close()
        commandOutputStream.close()
        */
        
        self.host = host
        print("connection set for HOST:", self.host)
        
        // img
        var imgReadStream:  Unmanaged<CFReadStream>?
        var imgWriteStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, self.host as CFString, self.streamPort, &imgReadStream, &imgWriteStream)
        
        // cmd
        //var cmdReadStream:  Unmanaged<CFReadStream>?
        //var cmdWriteStream: Unmanaged<CFWriteStream>?
        //CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, self.host as CFString, self.commandPort, &cmdReadStream, &cmdWriteStream)
        
        // cmd
        imageInputStream  = imgReadStream!.takeRetainedValue()
        imageOutputStream = imgWriteStream!.takeRetainedValue()
        
        // img
        //commandInputStream  = cmdReadStream!.takeRetainedValue()
        //commandOutputStream = cmdWriteStream!.takeRetainedValue()
        
        imageInputStream.delegate = self
        
        imageInputStream.schedule(in: .current, forMode: .commonModes)
        imageOutputStream.schedule(in: .current, forMode: .commonModes)
        //commandInputStream.schedule(in: .current, forMode: .commonModes)
        //commandOutputStream.schedule(in: .current, forMode: .commonModes)
        
        imageInputStream.open()
        imageOutputStream.open()
        //commandInputStream.open()
        //commandOutputStream.open()
    }
    
    func sendCommand(cmd: String) {
        let command = "NCTUEEclass20htlu,\(cmd)".data(using: .ascii)!  // Constructs command with keyword in front
        _ = command.withUnsafeBytes{commandOutputStream.write($0, maxLength: command.count)}
    }
    
    deinit {
        print("socket CLIENT destruct STARTS")
        imageInputStream.close()
        imageOutputStream.close()
        //commandInputStream.close()
        //commandOutputStream.close()
        print("socket CLIENT destruct ENDS")
    }
}

extension SocketClient: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
            case Stream.Event.hasBytesAvailable:
                readAvailableBytes(stream: aStream as! InputStream)
                print("new message received: HBA")
            
            case Stream.Event.endEncountered:
                print("new message received: EE")
            
            case Stream.Event.errorOccurred:
                print("error occurred")
            
            case Stream.Event.hasSpaceAvailable:
                print("has space available")
            
            default:
                print("some other event...")
                break
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: self.maxReadLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = imageInputStream.read(buffer, maxLength: self.maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
            
            //Construct the Message object
            
            if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                //Notify interested parties
                imageDelegate?.receivedMessage(message: message)
            }
        }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> String? {
        guard let stringArray = String(bytesNoCopy: buffer,
                                       length: length,
                                       encoding: .ascii,
                                       freeWhenDone: true)?.components(separatedBy: " "),  // split ImgByteStr by
            let imageStr = stringArray.first else {
                return nil
        }
        print("string array", stringArray)
        //image = CGImage(jpegDataProviderSource: CGDataProvider(url: "localhost:8888" as! CFURL)!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
        return imageStr // image
    }
}
