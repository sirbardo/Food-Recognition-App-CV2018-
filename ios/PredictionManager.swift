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

@objc(PredictionManager)

class PredictionManager : NSObject{
  
  let model : inception_v3! = inception_v3()
  let bboxModel : bounding_boxes = bounding_boxes()
  
  @objc func predict(_ base64: String?, callback: (NSObject) -> () )->Void
  {
    var decodedImage : UIImage!
    
    if (base64?.isEmpty)! {
      return
    }else {
      let temp = base64?.components(separatedBy: ",")
      let dataDecoded : Data = Data(base64Encoded: temp![0], options: .ignoreUnknownCharacters)!
      decodedImage = UIImage(data: dataDecoded)
    }
    
    let imagebbox = computeBoundingBox(imageToCrop: decodedImage)
    let croppedImage = imagebbox!.0
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
    croppedImage.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
    let modelInputImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer : CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(modelInputImage.size.width), Int(modelInputImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
    guard (status == kCVReturnSuccess) else {
      return
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
    
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixelData, width: Int(modelInputImage.size.width), height: Int(modelInputImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
    
    context?.translateBy(x: 0, y: modelInputImage.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)
    
    UIGraphicsPushContext(context!)
    modelInputImage.draw(in: CGRect(x: 0, y: 0, width: modelInputImage.size.width, height: modelInputImage.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    
    
    guard let prediction = try? model.prediction(fromMul__0: pixelBuffer!) else {
      return
    }
    let predictionString = prediction.classLabel
    let bboxedImage = decodedImage.drawRectangle(rect: imagebbox!.1)
    
    
    callback([["prediction": predictionString, "bboxImage": bboxedImage.base64()!]] as NSObject)
  }
  
  func computeBoundingBox(imageToCrop: UIImage) -> (UIImage, CGRect)?{
    
    let scaleX = imageToCrop.size.width/224
    let scaleY = imageToCrop.size.height/224

    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 224, height: 224), true, 2.0)
    imageToCrop.draw(in: CGRect(x: 0, y: 0, width: 224, height: 224))
    let modelInputImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer : CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(modelInputImage.size.width), Int(modelInputImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
    guard (status == kCVReturnSuccess) else {
      return nil
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
    
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixelData, width: Int(modelInputImage.size.width), height: Int(modelInputImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
    
    context?.translateBy(x: 0, y: modelInputImage.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)
    
    UIGraphicsPushContext(context!)
    modelInputImage.draw(in: CGRect(x: 0, y: 0, width: modelInputImage.size.width, height: modelInputImage.size.height))
    UIGraphicsPopContext()
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    
    guard let prediction = try? bboxModel.prediction(fromImage: pixelBuffer!) else {
      return nil
    }
    
    
    
    let bboxMA = prediction.x1y1x2y2
    let x1 = (bboxMA[0] as! CGFloat) * scaleX
    let x2 = (bboxMA[2] as! CGFloat) * scaleX
    let y1 = (bboxMA[1] as! CGFloat) * scaleY
    let y2 = (bboxMA[3] as! CGFloat) * scaleY
    
    let boundingBox = CGRect(x: x1, y: y1, width: x2-x1, height: y2-y1)
    
    
    let croppedImage = imageToCrop.crop(rect: boundingBox)

    
    return (croppedImage, boundingBox)
  }
  
}

extension UIImage {
  func crop( rect: CGRect) -> UIImage {
    var rect = rect
    rect.origin.x*=self.scale
    rect.origin.y*=self.scale
    rect.size.width*=self.scale
    rect.size.height*=self.scale
    
    let imageRef = self.cgImage!.cropping(to: rect)
    let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
    return image
  }
  
  func drawRectangle(rect: CGRect) -> UIImage {
    let imageSize = self.size
    let scale: CGFloat = 0
    UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
    self.draw(at: CGPoint.zero)
    
    let rectangle = rect
    let path = UIBezierPath(rect: rectangle)
    path.lineWidth = 15
    UIColor.yellow.setStroke()
    path.stroke()

    let boundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return boundedImage!
  }
  
  public func base64() -> String? {
    var imageData: Data?
    imageData = UIImagePNGRepresentation(self)

    return imageData?.base64EncodedString()
  }
  
}
