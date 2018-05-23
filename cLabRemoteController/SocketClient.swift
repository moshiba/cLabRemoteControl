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
    let streamPort:  UInt32 = 8888
    let commandPort: UInt32 = 8889
    let maxReadLength:  Int = 16384

    weak var imageDelegate: ImageDelegate?

    var host: String!
    var imageInputStream: InputStream!
    var commandOutputStream: OutputStream!

    override init() {
        print("on Main thread?", Thread.isMainThread)
        print("multi thread?", Thread.isMultiThreaded())
    }

    func setConn(host: String) {
        if imageInputStream != nil {
            if (imageInputStream.streamStatus.rawValue != 6) {
                imageInputStream.close()
            }
        }
        if commandOutputStream != nil {
            if (commandOutputStream.streamStatus.rawValue != 6) {
                commandOutputStream.close()
            }
        }
        
        self.host = host
        print("connection set for HOST:", self.host)

        var imgReadStream: Unmanaged<CFReadStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           self.host as CFString,
                                           self.streamPort,
                                           &imgReadStream,
                                           nil)
        var cmdWriteStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           self.host as CFString,
                                           self.commandPort,
                                           nil,
                                           &cmdWriteStream)

        imageInputStream = imgReadStream!.takeRetainedValue()
        commandOutputStream = cmdWriteStream!.takeRetainedValue()

        // img stream delegation
        imageInputStream.delegate = self

        imageInputStream.schedule(in: .current, forMode: .commonModes)
        commandOutputStream.schedule(in: .current, forMode: .commonModes)

        imageInputStream.open()
        commandOutputStream.open()
    }

    func sendCommand(cmd: String) {
        // Cmd is made of tuple (RightWheelDutyCycle, LeftWheelDutyCycle)
        
        // Constructs command with keyword in front, seperated by commas
        let command = "NCTUEEclass20htlu, \(cmd)".data(using: .ascii)!
        _ = command.withUnsafeBytes{commandOutputStream.write($0, maxLength: command.count)}
    }

    deinit {
        print("socket CLIENT destruct STARTS")
        imageInputStream.close()
        commandOutputStream.close()

        imageInputStream.delegate = nil
        imageInputStream = nil
        commandOutputStream = nil
        print("socket CLIENT destruct ENDS")
    }
}

extension SocketClient: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
            case Stream.Event.hasBytesAvailable:
                readAvailableBytes(stream: aStream as! InputStream)
                //print("new message received: HBA")
                print("delegate: [MSG STARTS]")
                break

            case Stream.Event.endEncountered:
                //print("new message received: EE")
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
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: self.maxReadLength)

        while stream.hasBytesAvailable {
            let numberOfBytesRead = imageInputStream.read(buffer, maxLength: self.maxReadLength)

            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    print("stream error: numberOfBytesRead < 0")
                    break
                }
            }

            // Construct the Message object
            if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                // Notify interested parties
                print("msg constructed:", message)

                imageDelegate?.receivedMessage(message: message)

                print("notify others")
            }
        }
        //buffer.deallocate()
    }

    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> String? {
        guard let stringArray = String(bytesNoCopy: buffer,
                                       length: length,
                                       encoding: .ascii,
                                       freeWhenDone: true)?.components(separatedBy: " "),  // split ImgByteStr by
            let imageStr = stringArray.first else {
                print("string array: nil")
                return nil
        }
        print("rcve photo")
        // FIXME: 
        print("string array", stringArray, ", imageStr", imageStr)
        
        
        //image = CGImage(jpegDataProviderSource: CGDataProvider(url: "localhost:8888" as! CFURL)!, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
        return imageStr // image
    }
}
