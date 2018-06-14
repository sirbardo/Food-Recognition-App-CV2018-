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
  
  @objc func predict(_ base64: String?)->String
  {
    var decodedimage : UIImage!
    
    if (base64?.isEmpty)! {
      return "Error!"
    }else {
      // !!! Separation part is optional, depends on your Base64String !!!
      let temp = base64?.components(separatedBy: ",")
      let dataDecoded : Data = Data(base64Encoded: temp![1], options: .ignoreUnknownCharacters)!
      decodedimage = UIImage(data: dataDecoded)
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 299), true, 2.0)
    decodedimage.draw(in: CGRect(x: 0, y: 0, width: 299, height: 299))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
    var pixelBuffer : CVPixelBuffer?
    let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
    guard (status == kCVReturnSuccess) else {
      return "Error"
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
    
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) //3
    
    context?.translateBy(x: 0, y: newImage.size.height)
    context?.scaleBy(x: 1.0, y: -1.0)
    
    UIGraphicsPushContext(context!)
    
    guard let prediction = try? model.prediction(fromMul__0: pixelBuffer!) else {
      return "Can't Predict"
    }
    
    return prediction.classLabel
  }
  
  
  
}
