//
// inception_v3.h
//
// This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import <CoreML/CoreML.h>
#include <stdint.h>

NS_ASSUME_NONNULL_BEGIN


/// Model Prediction Input Type
API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0))
@interface inception_v3Input : NSObject<MLFeatureProvider>

/// Mul__0 as color (kCVPixelFormatType_32BGRA) image buffer, 299 pixels wide by 299 pixels high
@property (readwrite, nonatomic) CVPixelBufferRef Mul__0;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithMul__0:(CVPixelBufferRef)Mul__0;
@end


/// Model Prediction Output Type
API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0))
@interface inception_v3Output : NSObject<MLFeatureProvider>

/// final_result__0 as dictionary of strings to doubles
@property (readwrite, nonatomic) NSDictionary<NSString *, NSNumber *> * final_result__0;

/// classLabel as string value
@property (readwrite, nonatomic) NSString * classLabel;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFinal_result__0:(NSDictionary<NSString *, NSNumber *> *)final_result__0 classLabel:(NSString *)classLabel;
@end


/// Class for model loading and prediction
API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0))
@interface inception_v3 : NSObject
@property (readonly, nonatomic, nullable) MLModel * model;
- (nullable instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error;

/**
    Make a prediction using the standard interface
    @param input an instance of inception_v3Input to predict from
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as inception_v3Output
*/
- (nullable inception_v3Output *)predictionFromFeatures:(inception_v3Input *)input error:(NSError * _Nullable * _Nullable)error;

/**
    Make a prediction using the convenience interface
    @param Mul__0 as color (kCVPixelFormatType_32BGRA) image buffer, 299 pixels wide by 299 pixels high:
    @param error If an error occurs, upon return contains an NSError object that describes the problem. If you are not interested in possible errors, pass in NULL.
    @return the prediction as inception_v3Output
*/
- (nullable inception_v3Output *)predictionFromMul__0:(CVPixelBufferRef)Mul__0 error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
