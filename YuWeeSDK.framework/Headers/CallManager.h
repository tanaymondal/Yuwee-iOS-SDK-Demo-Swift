//
//  CallManager.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CallParams.h"
#import "YuWeeProtocol.h"
#import "ChatManager.h"
#import "YuweeVideoView.h"
#import "YuweeRemoteVideoView.h"
#import "YuweeLocalVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CallManager : NSObject <UIGestureRecognizerDelegate>

+ (nonnull instancetype)sharedInstance;
- (nonnull instancetype)init NS_UNAVAILABLE;

/// Initiate new one to one or group call.
- (void)setUpCall:(nonnull CallParams *)callParams withClassListnerObject:(nonnull id <YuWeeCallSetUpDelegate>)listenerObject;

/// Set delegate for call related callbacks.
- (void)setCallManagerDelegate:(nonnull id <YuWeeCallManagerDelegate>)listenerObject;

/// Set delegate for when member added in call. (Use Yuwee Meeting for group/schedule call).
- (void)setOnMemberAddedOnCallDelegate:(nonnull id <YuWeeOnMemberAddedOnCallDelegate>)listenerObject;

/// Set delegate to receive incoming call events.
- (void)setIncomingCallEventDelegate:(nonnull id <YuWeeIncomingCallEventDelegate>)listenerObject;

/// Add new member on call. (Use Yuwee Meeting for group call).
- (void)addMemberOnCall:(nonnull NSArray *)arrNewPaticipants andGroupName:(nullable NSString *)strGroupName withCompletionBlock:(AddMembersInGroupCompletionBlock _Nonnull)completionBlock;

/// Hangup call.
- (void)hangUpCallWithCompletionBlockHandler:(nonnull CallHangUpCompletionBlock)completionBlock;

/// Init call.
/// YuweeLocalVideoView: To show own video.
/// YuweeRemoteVideoView: To show remote video.
- (void)initCallWithLocalView:(nonnull YuweeLocalVideoView *)localView withRemoteView:(nonnull YuweeRemoteVideoView *)remoteView;

/// When you receive incoming call and you don't accept it, then you can call this method
/// after certain time to notify caller that, you didn't accept/reject the call and timeout happened.
- (void)timeOutIncomingCall;

/// Call this method to notify caller that call is ringing.
- (void)notifyRingingWithCallId:(nonnull NSString*)callId withRoomId:(nonnull NSString*)roomId;

/// Start capturing video.
- (void)startVideoSource;

/// Stop capturing video.
- (void)stopVideoSource;

/// Enable or Disbale video.
- (void)setVideoEnabled:(BOOL)isEnabled;

/// Switch camera between front and back.
- (void)switchCamera;

/// Set audio output to Seaker, Earpiece, Wired Headset
- (void)setAudioOutputType:(AudioOutputType)audioOutputType;

/// Enable or Disable audio.
- (void)setAudioEnabled:(BOOL)isEnabled;

/// Reject incoming call.
- (void)rejectIncomingCall:(nonnull NSDictionary *)dictResponceForCurrentCall;

/// Accept incoming call.
- (void)acceptIncomingCall:(nonnull NSDictionary *)dictResponceForCurrentCall;

/// Get all recent call list.
/// Skip: No of calls you want to skip for pagination.
/// skip=0 (get first 20 calls), skip = 20 (get next 20 calls) and so on...
- (void)getRecentCall:(nonnull NSString*)skip withCompletionBlock:(nonnull FetchRecentCallCompletionBlock)completionBlock;

/// Join ongoing group/schedule call. (Use Yuwee Meeting for group/schedule call).
- (void)joinOngoingCall:(nonnull NSString *)callId MediaType:(MediaType)mediaType withCompletionHandler:(RecentCallCompletionBlock)completionBlock;

/// Join schedule call. (Use Yuwee Meeting for group/schedule call).
- (void)joinMeeting:(NSString *)callId withGroup:(BOOL)isGroup GroupId:(nullable NSString *)groupId ConferenceId:(nullable NSString *)conferenceId MediaType:(MediaType)mediaType withCompletionHandler:(SecheduleCallCompletionBlock)completionBlock;


#pragma mark - ScheduleManager Methods

/// Set schedule call delegate. (Use Yuwee Meeting for group/schedule call).
- (void)setOnScheduleCallEventsDelegate:(nonnull id <YuWeeScheduleCallManagerDelegate>)listenerObject;

/// Schedule a new meeting. (Use Yuwee Meeting for group/schedule call).
- (void)scheduleMeeting:(nonnull NSDictionary *)dictCallParamsObj withCompletionBlock:(ScheduleCallCompletionBlock)completionBlock;

/// Delete scheduled meeting. (Use Yuwee Meeting for group/schedule call).
- (void)deleteMeeting:(nonnull NSDictionary*)dictRequest withCompletionBlock:(ScheduleCallCompletionBlock)completionBlock;

/// Join schedule meeting. (Use Yuwee Meeting for group/schedule call).
- (void)joinMeetingWithCallId:(nonnull NSString*)callId withMediaType:(nonnull NSString*)mediaType;

/// Get all upcoming scheduled meeting. (Use Yuwee Meeting for group/schedule call).
- (void)getAllUpcomingCalls:(ScheduleCallCompletionBlock)completionBlock;

@property (assign,nonatomic) BOOL isCallTypeVideo;
@property (assign,nonatomic) BOOL isScreenSharingOn;
@property (strong, nonatomic,nonnull) YuweeVideoView *videoView;
@property (strong, nonatomic,nonnull) YuweeVideoView *screenView;

@end

NS_ASSUME_NONNULL_END
