//
//  VideoPlayerView.m
//  DPHeroSlider
//
//  Created by MAC 52 on 02/04/15.
//  Copyright (c) 2015 Jitendra Mishra. All rights reserved.
//

/********************************************************************************************************************
 * DPCustomSlider	: VideoPlayerView.m
 * Abstract			: Class is subclass of UIView containing an AVPlayer.
 * Author			: Jitendra Mishra
 *********************************************************************************************************************/

#import "VideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoPlayerView

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: layerClass
//@Abstract		: Overriding default layer of view to use AVPlayerLayer as Core Animation layer for its backing store.
//@Param		: NA
//@Returntype	: AVPlayerLayer class used to create the view’s Core Animation layer.
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

+ (Class)layerClass {
	return [AVPlayerLayer class];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: player
//@Abstract		: Getter method for AVPlayer object
//@Param		: NA
//@Returntype	: AVPlayer object.
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (AVPlayer*)player {
	return [(AVPlayerLayer*)[self layer] player];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: setPlayer:
//@Abstract		: Setter for AVPlayer object
//@Param		: player - AVPlayer type of object
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setPlayer:(AVPlayer*)player {
	[(AVPlayerLayer*)[self layer] setPlayer:player];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: setVideoFillMode:
//@Abstract		: Method is used for defining how the video is displayed within an AVPlayerLayer bounds rect
//@Param		: fillMode - NSString value which is used for settinhg video fill mode.
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setVideoFillMode:(NSString *)fillMode {
	AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
	playerLayer.videoGravity = fillMode;
}

@end
