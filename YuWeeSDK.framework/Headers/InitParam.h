//
//  InitParam.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InitParam : NSObject

@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSString *accessToken;

@end

NS_ASSUME_NONNULL_END
