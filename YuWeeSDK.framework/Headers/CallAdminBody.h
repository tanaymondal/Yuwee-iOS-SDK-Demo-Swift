//
//  CallAdminBody.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallAdminBody : NSObject

@property (strong,nonatomic) NSString *userId;
@property (assign,nonatomic) BOOL isCallAdmin;

@end

NS_ASSUME_NONNULL_END
