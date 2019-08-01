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
            let cgImage = convertUIImageToCGImageWithRGBA(image)
            let stride = cgImage.bytesPerRow
            let dataPtr = CFDataGetMutableBytePtr((cgImage.dataProvider!.data as! CFMutableData))!
            let webPData = try encode(RGBA: dataPtr, config: config,
                                      originWidth: Int(image.size.width), originHeight: Int(image.size.height), stride: stride,
                                      resizeWidth: width, resizeHeight: height)
            return webPData
        }
        
        private func convertUIImageToCGImageWithRGBA(_ image: UIImage) -> CGImage {
            
            //Fix orientation if needed
            var transform: CGAffineTransform = .identity
            let imageOrientation = image.imageOrientation
            let size = image.size
            
            switch imageOrientation {
            case .down, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: size.height)
                transform = transform.rotated(by:.pi)
                break
            case .left, .leftMirrored:
                transform = transform.translatedBy(x: size.width, y: 0)
                transform = transform.rotated(by:.pi/2)
                break
            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0, y: size.height)
                transform = transform.rotated(by:-.pi/2)
                break
            case .up, .upMirrored:
                break
            @unknown default:
                break
            }
            
            switch imageOrientation {
            case .upMirrored, .downMirrored:
                transform.translatedBy(x: size.width, y: 0)
                transform.scaledBy(x: -1, y: 1)
                break
            case .leftMirrored, .rightMirrored:
                transform.translatedBy(x: size.height, y: 0)
                transform.scaledBy(x: -1, y: 1)
            case .up, .down, .left, .right:
                break
            @unknown default:
                break
            }
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                    bitsPerComponent: 8, bytesPerRow: Int(size.width) * 4,
                                    space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
            context.concatenate(transform)
            
            let rect:CGRect
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                rect = CGRect(x: 0, y: 0, width: size.height, height: size.width)
                
                break
            default:
                rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                break
            }
            
            
            context.draw(image.cgImage!, in: rect)
            
            return context.makeImage()!
        }
    }

#endif
