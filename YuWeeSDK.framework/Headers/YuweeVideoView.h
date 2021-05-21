//
//  YuweeVideoView.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "YuweeLocalVideoView.h"
#import "YuweeRemoteVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YuweeVideoView : UIView{
  // Auto-adjust to the screen size
  CGRect screenSize;
}

@property(nonatomic,strong) YuweeLocalVideoView *localVideoView;
@property(nonatomic,strong) YuweeRemoteVideoView *remoteVideoView;

- (void)initialize;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)setViewOfControlsOrigin:(UIView *)viewOfControls;

@end

NS_ASSUME_NONNULL_END
