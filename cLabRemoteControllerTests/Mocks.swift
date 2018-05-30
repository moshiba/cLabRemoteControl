//
//  Mocks.swift
//  cLabRemoteControllerTests
//
//  Created by Tim Lu on 2018/5/23.
//  Copyright © 2018 Demilab. All rights reserved.
//

import Foundation

protocol ImageDelegate: class {
    func receivedMessage(message: Message)
}

class Message {
    var leftPower:  String
    var rightPower: String
    
    init(leftPower: String, rightPower: String) {
        self.leftPower  = leftPower
        self.rightPower = rightPower
    }
}

class MockServer: NSObject{
    let host: String = "localhost"
    let streamPort:  UInt32 = 8888
    let commandPort: UInt32 = 8889
    let maxReadLength:  Int = 1024
    let buffer: UnsafeMutablePointer<UInt8>

    var commandInputStream: InputStream!
    var imageOutputStream: OutputStream!
    
    weak var commandDelegate: ImageDelegate?
    
    override init() {
        buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        var commandReadStream: Unmanaged<CFReadStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           host as CFString,
                                           commandPort,
                                           &commandReadStream,
                                           nil)
        var imageWriteStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           host as CFString,
                                           streamPort,
                                           nil,
                                           &imageWriteStream)
        commandInputStream = commandReadStream!.takeRetainedValue()
        imageOutputStream = imageWriteStream!.takeRetainedValue()
        
        commandInputStream.schedule(in: .current, forMode: .commonModes)
        imageOutputStream.schedule(in: .current, forMode: .commonModes)
        
        commandInputStream.open()
        imageOutputStream.open()
    }
    
    func tearDown() {
        commandInputStream.close()
        imageOutputStream.close()
        
        //commandInputStream.delegate = nil
        commandInputStream = nil
        imageOutputStream = nil
    }
    
    deinit {
        commandInputStream.close()
        imageOutputStream.close()
        
        //commandInputStream.delegate = nil
        commandInputStream = nil
        imageOutputStream = nil
    }
}

extension MockServer: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
            print("delegate: [MSG STARTS]")
            break
            
        case Stream.Event.endEncountered:
            print("delegate: [MSG ENDS]")
            break
            
        case Stream.Event.errorOccurred:
            print("delegate: error occurred")
            break
            
        case Stream.Event.hasSpaceAvailable:
            print("delegate: has space available")
            break
            
        case Stream.Event.openCompleted:
            print("delegate: open completed")
            break
            
        default:
            print("delegate: some other event..., eventCode \(eventCode)")
            break
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        while stream.hasBytesAvailable {
            let numberOfBytesRead = commandInputStream.read(buffer, maxLength: self.maxReadLength)
        
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    print("stream error: numberOfBytesRead < 0")
                    break
                }
            }
            
            if let msg = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                // Notify interested parties
                commandDelegate?.receivedMessage(message: msg)
            }
            
        }
    }
    
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Message? {
        guard let stringArray = String(bytesNoCopy: buffer,
                                       length: length,
                                       encoding: .ascii,
                                       freeWhenDone: true)?.components(separatedBy: ",")  // split ImgByteStr by
            else {
                print("string array: nil")
                return nil
        }
        let passphrase = stringArray[0]
        let rightDutyCycle = stringArray[1]
        let leftDutyCycle  = stringArray[2]
        
        if passphrase == "NCTUEEclass20htlu" {
            print("received: Left Power \(leftDutyCycle)%, Right Power \(rightDutyCycle)%")
            return Message(leftPower: leftDutyCycle,
                           rightPower: rightDutyCycle)
        } else {
            return nil
        }
    }
}
