//
// inception_v3.m
//
// This file was automatically generated and should not be edited.
//

#import "inception_v3.h"

@implementation inception_v3Input

- (instancetype)initWithMul__0:(CVPixelBufferRef)Mul__0 {
    if (self) {
        _Mul__0 = Mul__0;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"Mul__0"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"Mul__0"]) {
        return [MLFeatureValue featureValueWithPixelBuffer:_Mul__0];
    }
    return nil;
}

@end

@implementation inception_v3Output

- (instancetype)initWithFinal_result__0:(NSDictionary<NSString *, NSNumber *> *)final_result__0 classLabel:(NSString *)classLabel {
    if (self) {
        _final_result__0 = final_result__0;
        _classLabel = classLabel;
    }
    return self;
}

- (NSSet<NSString *> *)featureNames {
    return [NSSet setWithArray:@[@"final_result__0", @"classLabel"]];
}

- (nullable MLFeatureValue *)featureValueForName:(NSString *)featureName {
    if ([featureName isEqualToString:@"final_result__0"]) {
        return [MLFeatureValue featureValueWithDictionary:_final_result__0 error:nil];
    }
    if ([featureName isEqualToString:@"classLabel"]) {
        return [MLFeatureValue featureValueWithString:_classLabel];
    }
    return nil;
}

@end

@implementation inception_v3

- (nullable instancetype)initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable * _Nullable)error {
    self = [super init];
    if (!self) { return nil; }
    _model = [MLModel modelWithContentsOfURL:url error:error];
    if (_model == nil) { return nil; }
    return self;
}

- (nullable instancetype)init {
    NSString *assetPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"inception_v3" ofType:@"mlmodelc"];
    return [self initWithContentsOfURL:[NSURL fileURLWithPath:assetPath] error:nil];
}

- (nullable inception_v3Output *)predictionFromFeatures:(inception_v3Input *)input error:(NSError * _Nullable * _Nullable)error {
    id<MLFeatureProvider> outFeatures = [_model predictionFromFeatures:input error:error];
    inception_v3Output * result = [[inception_v3Output alloc] initWithFinal_result__0:(NSDictionary<NSString *, NSNumber *> *)[outFeatures featureValueForName:@"final_result__0"].dictionaryValue classLabel:[outFeatures featureValueForName:@"classLabel"].stringValue];
    return result;
}

- (nullable inception_v3Output *)predictionFromMul__0:(CVPixelBufferRef)Mul__0 error:(NSError * _Nullable * _Nullable)error {
    inception_v3Input *input_ = [[inception_v3Input alloc] initWithMul__0:Mul__0];
    return [self predictionFromFeatures:input_ error:error];
}

@end
