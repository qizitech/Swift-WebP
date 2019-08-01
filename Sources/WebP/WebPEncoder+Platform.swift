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
        
        enum WebPEncoderImageError:Error {
            case failedToPrepare
        }
        public func encode(_ image: UIImage, config: WebPEncoderConfig, width: Int = 0, height: Int = 0) throws -> Data {
            if let cgImage = convertUIImageToCGImageWithRGBA(image) {
                let stride = cgImage.bytesPerRow
                let dataPtr = CFDataGetMutableBytePtr((cgImage.dataProvider!.data as! CFMutableData))!
                let webPData = try encode(RGBA: dataPtr, config: config,
                                          originWidth: Int(image.size.width), originHeight: Int(image.size.height), stride: stride,
                                          resizeWidth: width, resizeHeight: height)
                return webPData
            }
            else {
                throw WebPEncoderImageError.failedToPrepare
            }
        }
        
        private func convertUIImageToCGImageWithRGBA(_ image: UIImage) -> CGImage? {
            
            guard let cgImage = image.cgImage else {
                return nil
            }
            
            //Fix orientation if needed
            var transform: CGAffineTransform = .identity
            let imageOrientation = image.imageOrientation
            let size = image.size
            
            switch imageOrientation {
            case .down, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: size.height)
                transform = transform.rotated(by: .pi)
            case .left, .leftMirrored:
                transform = transform.translatedBy(x: size.width, y: 0)
                transform = transform.rotated(by: .pi / 2.0)
            case .right, .rightMirrored:
                transform = transform.translatedBy(x: 0, y: size.height)
                transform = transform.rotated(by: .pi / -2.0)
            case .up, .upMirrored:
                break
            @unknown default:
                break
            }
            
            // Flip image one more time if needed to, this is to prevent flipped image
            switch imageOrientation {
            case .upMirrored, .downMirrored:
                transform = transform.translatedBy(x: size.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            case .leftMirrored, .rightMirrored:
                transform = transform.translatedBy(x: size.height, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
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
            
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
            default:
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                break
            }
            
            return context.makeImage()
        }
    }

#endif
