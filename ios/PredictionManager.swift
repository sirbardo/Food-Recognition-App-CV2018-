//
//  PredictionManager.swift
//  CVApp
//
//  Created by Luca Pitzalis on 13/06/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import UIKit
import CoreML

extension UIImage {
  public func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
    //Calculate the size of the rotated view's containing box for our drawing space
    let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
    let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
    rotatedViewBox.transform = t
    let rotatedSize: CGSize = rotatedViewBox.frame.size
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize)
    let bitmap: CGContext = UIGraphicsGetCurrentContext()!
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    //Rotate the image context
    bitmap.rotate(by: (degrees * CGFloat.pi / 180))
    //Now, draw the rotated/scaled image into the context
    bitmap.scaleBy(x: 1.0, y: -1.0)
    bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
  }
  
  
  public func fixedOrientation() -> UIImage {
    if imageOrientation == UIImageOrientation.up {
      return self
    }
    
    var transform: CGAffineTransform = CGAffineTransform.identity
    
    switch imageOrientation {
    case UIImageOrientation.down, UIImageOrientation.downMirrored:
      transform = transform.translatedBy(x: size.width, y: size.height)
      transform = transform.rotated(by: CGFloat.pi)
      break
    case UIImageOrientation.left, UIImageOrientation.leftMirrored:
      transform = transform.translatedBy(x: size.width, y: 0)
      transform = transform.rotated(by: CGFloat.pi/2)
      break
    case UIImageOrientation.right, UIImageOrientation.rightMirrored:
      transform = transform.translatedBy(x: 0, y: size.height)
      transform = transform.rotated(by: -CGFloat.pi/2)
      break
    case UIImageOrientation.up, UIImageOrientation.upMirrored:
      break
    }
    
    switch imageOrientation {
    case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
      transform.translatedBy(x: size.width, y: 0)
      transform.scaledBy(x: -1, y: 1)
      break
    case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
      transform.translatedBy(x: size.height, y: 0)
      transform.scaledBy(x: -1, y: 1)
    case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
      break
    }
    
    let ctx: CGContext = CGContext(data: nil,
                                   width: Int(size.width),
                                   height: Int(size.height),
                                   bitsPerComponent: self.cgImage!.bitsPerComponent,
                                   bytesPerRow: 0,
                                   space: self.cgImage!.colorSpace!,
                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    ctx.concatenate(transform)
    
    switch imageOrientation {
    case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
      ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
    default:
      ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      break
    }
    
    let cgImage: CGImage = ctx.makeImage()!
    
    return UIImage(cgImage: cgImage)
  }
}


@objc(PredictionManager)

class PredictionManager : NSObject{
  
  let model : inception_v3! = inception_v3()
  
  @objc func predict(_ base64: String?, callback: (NSObject) -> () )->Void
  {
    var decodedimage : UIImage!
    
    if (base64?.isEmpty)! {
      return
    }else {
      let temp = base64?.components(separatedBy: ",")
      let dataDecoded : Data = Data(base64Encoded: temp![0], options: .ignoreUnknownCharacters)!
      decodedimage = UIImage(data: dataDecoded)
    }
    
    //decodedimage = decodedimage.fixedOrientation().imageRotatedByDegrees(degrees: 0)
    
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
    decodedimage.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer : CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
    guard (status == kCVReturnSuccess) else {
      return
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
    
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
    
    context?.translateBy(x: 0, y: newImage.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)
    
    UIGraphicsPushContext(context!)
    newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

    guard let prediction = try? model.prediction(fromMul__0: pixelBuffer!) else {
      return
    }
    let predictionString = prediction.classLabel
    
    callback([["prediction": predictionString]] as NSObject)
  }
  
}
