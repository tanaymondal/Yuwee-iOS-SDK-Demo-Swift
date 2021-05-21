//
//  AwsManager.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AwsManager : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

-(void)getAwsCredentialWithToken:(NSString*)token;

-(void)getMediaUrlWithRoomId:(NSString*)roomId
         withCompletionBlock:(OnInitFileShareCompletionHandler)completionBlock;

@end

NS_ASSUME_NONNULL_END
