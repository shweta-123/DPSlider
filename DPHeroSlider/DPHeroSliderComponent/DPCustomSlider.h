//
//  DPCustomSlider.h
//  DPHeroSlider
//
//  Created by MAC 52 on 02/04/15.
//  Copyright (c) 2015 Jitendra Mishra. All rights reserved.
//

/********************************************************************************************************************
 * DPCustomSlider	: DPCustomSlider.h
 * Abstract			: It is the main class for Slider Component. The class offers to create an endless slideshow of images or videos. The class contains methods to set the data source file i.e. images/videos and transition methods to move to next or previous slide. Fade and Slide animations are supported for transition. The component is fully customizable by setting specific properties i.e. animation, transition speed, enable/disable gestures etc.
 * Author			: Jitendra Mishra
 *********************************************************************************************************************/

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DPCustomSliderTransitionType) {
    DPCustomSliderTransitionFade,
    DPCustomSliderTransitionSlide
};

typedef NS_ENUM(NSInteger, DPCustomSliderGestureType) {
    DPCustomSliderGestureTap,
    DPCustomSliderGestureSwipe,
    DPCustomSliderGestureAll
};

typedef NS_ENUM(NSUInteger, DPCustomSliderPosition) {
    DPCustomSliderPositionTop,
    DPCustomSliderPositionBottom
};

typedef NS_ENUM(NSUInteger, DPCustomSliderState) {
    DPCustomSliderStateStopped,
    DPCustomSliderStateStarted
};

typedef NS_ENUM(NSUInteger, DPCustomSliderType) {
    DPCustomSliderTypeImage,
    DPCustomSliderTypeVideo
};

@class DPCustomSlider;
@protocol DPCustomSliderDelegate <NSObject>
@optional
- (void) DPCustomSliderDidShowNext:(DPCustomSlider *) slider;
- (void) DPCustomSliderDidShowPrevious:(DPCustomSlider *) slider;
- (void) DPCustomSliderWillShowNext:(DPCustomSlider *) slider;
- (void) DPCustomSliderWillShowPrevious:(DPCustomSlider *) slider;
@end

@protocol DPCustomSliderDataSource <NSObject>
- (id)slideShow:(DPCustomSlider *)slideShow fileForPosition:(DPCustomSliderPosition)position;
@end

@interface DPCustomSlider : UIView
@property (nonatomic, unsafe_unretained) IBOutlet id <DPCustomSliderDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<DPCustomSliderDataSource> dataSource;
@property  float delay;
@property  float transitionDuration;
@property  (atomic) DPCustomSliderTransitionType transitionType;
@property  (atomic) DPCustomSliderType sliderType;
@property  (nonatomic) NSUInteger currentIndex;
@property (nonatomic,strong)NSMutableArray *dataArray;
- (void)initializeSlider;
- (void) addGesture:(DPCustomSliderGestureType)gestureType;
- (void) start;
- (void) stop;
@end
