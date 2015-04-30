//
//  VideoPlayerViewController.m
//  DPHeroSlider
//
//  Created by MAC 52 on 02/04/15.
//  Copyright (c) 2015 Jitendra Mishra. All rights reserved.
//

/********************************************************************************************************************
 * DPCustomSlider	: VideoPlayerViewController.m
 * Abstract			: View Controller for managing initialization and playback of AVPlayer.
 * Author			: Jitendra Mishra
 *********************************************************************************************************************/

#import "VideoPlayerViewController.h"
#import "VideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

/* Asset keys */
NSString * const kTracksKey = @"tracks";
NSString * const kPlayableKey = @"playable";

/* PlayerItem keys */
NSString * const kStatusKey         = @"status";
NSString * const kCurrentItemKey	= @"currentItem";

@interface VideoPlayerViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) VideoPlayerView *playerView;

@end

static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

@implementation VideoPlayerViewController

@synthesize URL = _URL;
@synthesize player = _player;
@synthesize playerItem = _playerItem;
@synthesize playerView = _playerView;


#pragma mark - UIView lifecycle

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: loadView
//@Abstract		: Overridden method used to create the view programmetically.
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)loadView {
    VideoPlayerView *playerView = [[VideoPlayerView alloc] init];
    self.view = playerView;
    self.view.backgroundColor = [UIColor blackColor];
    self.playerView = playerView;
}


#pragma mark - Memory Management

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: dealloc
//@Abstract		: Overridden method used for last-minute cleanup of view controller.
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc {
    [self.player removeObserver:self forKeyPath:kCurrentItemKey];
    [self.player.currentItem removeObserver:self forKeyPath:kStatusKey];
	[self.player pause];
    
    self.URL = nil;
    self.player = nil;
    self.playerItem = nil;
    self.playerView = nil;
    
}


#pragma mark - Private methods

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: prepareToPlayAsset:withKeys:
//@Abstract		: Method used to setup AVPlayer source asset, check if its playable and play the file.
//@Param		: asset - AVURLAsset object which provides access to the AVAsset model for timed audiovisual media referenced by URL
//              : requestedKeys - NSArray object containing keys to check status of asset. For ex. if the asset is playable etc.
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys {
    for (NSString *thisKey in requestedKeys) {
		NSError *error = nil;
		AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
		if (keyStatus == AVKeyValueStatusFailed) {
			return;
		}
	}
    
    if (!asset.playable) {
        return;
    }
	
	if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];            
		
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
	
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.playerItem addObserver:self 
                       forKeyPath:kStatusKey 
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
		
    if (![self player]) {
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];	
        [self.player addObserver:self 
                      forKeyPath:kCurrentItemKey 
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
    }
    
    if (self.player.currentItem != self.playerItem) {
        [[self player] replaceCurrentItemWithPlayerItem:self.playerItem];
    }
}


#pragma mark - Key Valye Observing

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: observeValueForKeyPath:ofObject:change:context:
//@Abstract		: Method is used to get notified of any change on player or player item properties like URL, status etc
//@Param		: path - NSString value - the key for which change is observed
//              : object - The object involved in change observation
//              : change - NSDictionary containing all the change details on object
//              : context - The context in which change occured
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString*) path 
                      ofObject:(id)object 
                        change:(NSDictionary*)change 
                       context:(void*)context {
	if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            [self.player play];
        }
	} else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext) {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (newPlayerItem) {
            [self.playerView setPlayer:self.player];
            [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
        }
	} else {
		[super observeValueForKeyPath:path ofObject:object change:change context:context];
	}
}


#pragma mark - Public methods

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: setURL:
//@Abstract		: Setter method for URL of AVPlayer. Creates new AVURLAsset with give URL value
//@Param		: URL - NSURL object for new URL
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setURL:(NSURL*)URL {
    _URL = [URL copy];
    

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_URL options:nil];
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];

    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{		 
         dispatch_async( dispatch_get_main_queue(), 
                        ^{
                            [self prepareToPlayAsset:asset withKeys:requestedKeys];
                        });
     }];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: URL
//@Abstract		: Getter method for URL of AVPlayer
//@Param		: NA
//@Returntype	: NSURL - The URL for AVURLAsset
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (NSURL*)URL {
	return _URL;
}

@end
