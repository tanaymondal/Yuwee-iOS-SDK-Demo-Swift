//
//  UserManager.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"
#import "CallManager.h"
#import "InitParam.h"
#import "ScheduleManager.h"
#import "ChatManager.h"
#import "NotificationManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserManager : NSObject

+ (instancetype)sharedInstance;
- (nonnull instancetype)init NS_UNAVAILABLE;

/// Create user with YuWee
/// User Name: Name of the user
/// Email: Email of the user
/// Password: Password with minimum 6 characters
- (void)createUserWithName:(nonnull NSString*)strUserName
                     Email:(nonnull NSString*)strEmail
                  Password:(nonnull NSString*)strPassword
       withCompletionBlock:(CreateUserCompletionBlock)createUserCompletionHandler;

/// Register for Push and Voip Notification
/// APNS: APNS token needed to receive chat messages
/// VOIP: Voip token needed to receive call notification
- (void)registerPushTokenAPNS:(NSString*)strAPNS
                         VOIP:(NSString*)strVOIP
          withCompletionBlock:(OnRegisterPushTokenCompletionBlock)registerTokenCompletionHandler;

/// Create Yuwee session (Login)
/// Email: Email of the user
/// Password: Password of the user
/// Expiry Time: Time after which session shoule be expired. It should be provided in seconds
- (void)createSessionViaCredentialsWithEmail:(nonnull NSString *)strEmail
                                    Password:(nonnull NSString *)strPassword
                                  ExpiryTime:(nonnull NSString *)expiryTime
                         withCompletionBlock:(LoginCompletionBlock)loginCompletionHandler;

/// Create session using token. This method is useful when login is performed from server side
/// InitParam.userInfo: "user" Dictionary of login response
/// InitParam.accessToken: "accessToken" String of login response
- (void)createSessionViaToken:(nonnull InitParam *)initParam
          withCompletionBlock:(OnCreateSessionViaTokenCompletionBlock)completionHandler;

/// Check wheather user is logged in on yuwee or not.
- (BOOL)isLoggedIn;

/// Logout from yuwee.
- (void)logout;

@end

NS_ASSUME_NONNULL_END
