//
//  PredictionManagerBridge.m
//  CVApp
//
//  Created by Luca Pitzalis on 13/06/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(PredictionManager, NSObject)

RCT_EXTERN_METHOD(predict:(NSString *)base64 callback:(RCTResponseSenderBlock)callback)
@end

