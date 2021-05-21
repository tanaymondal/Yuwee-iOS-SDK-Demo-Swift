//
//  ConnectionManager.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConnectionManager : NSObject
+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

/// Check if yuwee connected to server or not.
- (BOOL) isConnected;

/// Call this method to force reconnect yuwee to server.
- (void) forceReconnect;

/// Call this method to disconnect yuwee with server.
- (void) disconnect;

/// Set connection delegate to get all event about yuwee connection with server.
- (void) setConnectionDelegate:(id <YuWeeConnectionDelegate>) yuweeConnectionDelegate;
@end

NS_ASSUME_NONNULL_END
