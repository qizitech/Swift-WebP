//
//  WebPEncoder+Platform.swift
//  WebP
//
//  Created by Namai Satoshi on 2016/10/23.
//  Copyright © 2016年 satoshi.namai. All rights reserved.
//

import Foundation

#if os(macOS)
    import AppKit
    import CoreGraphics

    extension WebPEncoder {
        public func encode(_ image: NSImage, config: WebPEncoderConfig, width: Int = 0, height: Int = 0) throws -> Data {
            let data = image.tiffRepresentation!
            let stride = Int(image.size.width) * MemoryLayout<UInt8>.size * 3 // RGB = 3byte
            let bitmap = NSBitmapImageRep(data: data)!
            let webPData = try encode(RGB: bitmap.bitmapData!, config: config,
                                      originWidth: Int(image.size.width), originHeight: Int(image.size.height), stride: stride,
                                      resizeWidth: width, resizeHeight: height)
            return webPData
        }
    }
#endif

#if os(iOS)
    import UIKit
    import CoreGraphics

    extension WebPEncoder {
        public func encode(_ image: UIImage, config: WebPEncoderConfig, width: Int = 0, height: Int = 0) throws -> Data {
            
            if #available(iOS 11.0, *) {
                let format = UIGraphicsImageRendererFormat.preferred()
                format.scale = 1
                let scaledSize = CGSize(width: image.size.width*image.scale, height: image.size.height*image.scale)
                let renderer = UIGraphicsImageRenderer(size: scaledSize, format:format)
                let scaledAndDecompressedImage = renderer.image { (context) in
                    image.draw(in: CGRect(origin: .zero, size: scaledSize))
                }
                
                let cgImage = scaledAndDecompressedImage.cgImage!
                let stride = cgImage.bytesPerRow
                let dataPtr = CFDataGetMutableBytePtr((cgImage.dataProvider!.data as! CFMutableData))!
                
                let webPData = try encode(RGBA: dataPtr, config: config,
                                          originWidth: Int(scaledAndDecompressedImage.size.width),
                                          originHeight: Int(scaledAndDecompressedImage.size.height), stride: stride)
                return webPData
            }
            else {
                return Data()
            }
        }
    }

#endif
