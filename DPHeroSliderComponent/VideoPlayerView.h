//
//  VideoPlayerView.h
//  DPHeroSlider
//
//  Created by MAC 52 on 02/04/15.
//  Copyright (c) 2015 Jitendra Mishra. All rights reserved.
//

/********************************************************************************************************************
 * DPCustomSlider	: VideoPlayerView.h
 * Abstract			: Class is subclass of UIView containing an AVPlayer.
 * Author			: Jitendra Mishra
 *********************************************************************************************************************/

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface VideoPlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
