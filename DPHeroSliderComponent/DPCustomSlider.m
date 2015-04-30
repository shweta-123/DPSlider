//
//  DPCustomSlider.m
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

#import "DPCustomSlider.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VideoPlayerViewController.h"

#define kSwipeTransitionDuration 0.5

typedef NS_ENUM(NSInteger, DPCustomSliderSlideMode) {
    DPCustomSliderSlideModeForward,
    DPCustomSliderSlideModeBackward
};

@interface DPCustomSlider()
@property (atomic) BOOL doStop;
@property (atomic) BOOL isAnimating;
@property (strong,nonatomic) UIImageView * topImageView;
@property (strong,nonatomic) UIImageView * bottomImageView;
@property (strong,nonatomic)MPMoviePlayerController *topMoviePlayer;
@property (strong,nonatomic)VideoPlayerViewController *bottomMoviePlayer;
@property (nonatomic,strong)UIPageControl *pageControl;
@property (nonatomic,strong)UIView *pageControlBackgroundView;
@property  (atomic) UIViewContentMode fileContentMode;
@property  (strong,nonatomic) NSMutableArray * files;
@property  (readonly, nonatomic) DPCustomSliderState state;
@end

@implementation DPCustomSlider

@synthesize delegate;
@synthesize delay;
@synthesize transitionDuration;
@synthesize transitionType;
@synthesize files;

///////////////////////////////////////////////////////////////////////////////////////////////////
////@Method		: awakeFromNib
////@Abstract	: Used to set default values of objects after the view is loaded.
////@Param		: NA
////@Returntype	: void
////@Author		: Jitendra Mishra
///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)awakeFromNib
{
    self.clipsToBounds = YES;
    self.files = [NSMutableArray array];
    self.currentIndex = 0;
    self.delay = 3;
    self.transitionDuration = 1;
    self.transitionType = DPCustomSliderTransitionSlide;
    self.doStop = YES;
    self.isAnimating = NO;
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: setDefaultValues
//@Abstract		: This method is used to initialize the properties with default values
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) initializeSlider
{
    if (self.sliderType == DPCustomSliderTypeImage) {
        self.topImageView = [[UIImageView alloc] init];
        self.bottomImageView = [[UIImageView alloc] init];
        self.topImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bottomImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.topImageView.clipsToBounds = YES;
        self.bottomImageView.clipsToBounds = YES;
        [self addSubview:self.bottomImageView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.bottomImageView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.bottomImageView}]];
        [self addSubview:self.topImageView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.topImageView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.topImageView}]];
        [self setFileContentMode:UIViewContentModeScaleAspectFit];
    }
    else{
        self.topMoviePlayer = [[MPMoviePlayerController alloc] init];
        self.topMoviePlayer.controlStyle = MPMovieControlStyleNone;
        self.topMoviePlayer.movieSourceType = MPMovieSourceTypeFile;
        VideoPlayerViewController *player = [[VideoPlayerViewController alloc] init];
        self.bottomMoviePlayer = player;
        self.topMoviePlayer.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.bottomMoviePlayer.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.topMoviePlayer.view.clipsToBounds = YES;
        self.bottomMoviePlayer.view.clipsToBounds = YES;
        [self addSubview:self.bottomMoviePlayer.view];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.bottomMoviePlayer.view}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.bottomMoviePlayer.view}]];
        
        [self addSubview:self.topMoviePlayer.view];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.topMoviePlayer.view}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.topMoviePlayer.view}]];
    }
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControlBackgroundView = [[UIView alloc] init];
    self.pageControlBackgroundView.backgroundColor = [UIColor clearColor];
    
    self.pageControl.clipsToBounds = YES;
    self.pageControlBackgroundView.clipsToBounds = YES;
    
    [self addSubview:self.pageControlBackgroundView];
    [self.pageControlBackgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.pageControl];
    [self.pageControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.pageControl}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self.pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    NSLayoutConstraint *width = [NSLayoutConstraint
                                 constraintWithItem:self.pageControlBackgroundView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:0
                                 toItem:self.pageControl
                                 attribute:NSLayoutAttributeWidth
                                 multiplier:1.0
                                 constant:0];
    NSLayoutConstraint *height = [NSLayoutConstraint
                                  constraintWithItem:self.pageControlBackgroundView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:0
                                  toItem:self.pageControl
                                  attribute:NSLayoutAttributeHeight
                                  multiplier:1.0
                                  constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:self.pageControlBackgroundView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.pageControl
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.f];
    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:self.pageControlBackgroundView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.pageControl
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    [self addConstraints:@[width,height,leading,top]];
    [self addFilesFromResources:self.dataArray];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: pageChanged:
//@Abstract		: This method is called when the current page of Page Control is changed on user tap
//@Param		: sender - The UIPageControl object
//@Returntype	: IBAction
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)pageChanged:(id)sender {
    UIPageControl *pager = sender;
    NSInteger page = pager.currentPage;
    if (self.currentIndex < page) {
        [self next];
    }
    else{
        [self previous];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: fileContentMode:
//@Abstract		: This method is used to set the content mode of image view when the Slider is operating in Image mode
//@Param		: mode - UIViewContentMode value for images
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) fileContentMode:(UIViewContentMode)mode
{
    self.topImageView.contentMode = mode;
    self.bottomImageView.contentMode = mode;
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: imagesContentMode:
//@Abstract		: This is getter method for Image content mode property
//@Param		: NA
//@Returntype	: UIViewContentMode value
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (UIViewContentMode) imagesContentMode
{
    return self.topImageView.contentMode;
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: imagesContentMode:
//@Abstract		: This method is used to add different gestures to the view of Slider Component
//@Param		: gestureType - DPCustomSliderGestureType to be added to the view
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) addGesture:(DPCustomSliderGestureType)gestureType
{
    switch (gestureType)
    {
        case DPCustomSliderGestureTap:
            [self addGestureTap];
            break;
        case DPCustomSliderGestureSwipe:
            [self addGestureSwipe];
            break;
        case DPCustomSliderGestureAll:
            [self addGestureTap];
            [self addGestureSwipe];
            break;
        default:
            break;
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: removeGestures
//@Abstract		: This method is used to remove all the gestures on view
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) removeGestures
{
    self.gestureRecognizers = nil;
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: addFilesFromResources:
//@Abstract		: This method is used to setup the data source and initial display of component
//@Param		: theFiles - NSArray containing details of images/videos to be used in Slider
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) addFilesFromResources:(NSArray *) theFiles
{
    self.pageControl.numberOfPages = theFiles.count;
    if (self.sliderType == DPCustomSliderTypeImage) {
        self.topMoviePlayer.view.hidden = true;
        self.bottomMoviePlayer.view.hidden = true;
    }
    else{
        self.topMoviePlayer.view.hidden = false;
        self.bottomMoviePlayer.view.hidden = false;
    }
    for(id file in theFiles){
        [self addFile:file];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: setFilesDataSource:
//@Abstract		: The setter method for fileDataSource
//@Param		: array - NSMutableArray containing details of images/videos to be used in Slider
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) setFilesDataSource:(NSMutableArray *)array {
    self.files = array;
    if (self.sliderType == DPCustomSliderTypeImage) {
        self.topImageView.image = [UIImage imageNamed:[array firstObject]];
    }
    else{
        self.topMoviePlayer.contentURL = [array firstObject];
        [self.topMoviePlayer play];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: addFile:
//@Abstract		: This method is used internally to setup the data source array and initial state of Slider
//@Param		: id - The file object which is image name for image mode and video URL for video mode of Slider component
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) addFile:(id) file
{
    [self.files addObject:file];
    if (self.sliderType == DPCustomSliderTypeImage) {
        if([self.files count] == 1){
            self.topImageView.image = [UIImage imageNamed:file];
        }else if([self.files count] == 2){
            self.bottomImageView.image = [UIImage imageNamed:file];
        }
    }
    else{
        if([self.files count] == 1){
            self.topMoviePlayer.contentURL = file;
            [self.topMoviePlayer play];
        }else if([self.files count] == 2){
            self.bottomMoviePlayer.URL = file;
        }
    }
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: emptyAndAddFilesFromResources:
//@Abstract		: This method is used to reset the data source of Slider. It replaces all the existing file with new ones.
//@Param		: theFiles - Arrauy containing details of new files to be used as data source of Slider
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) emptyAndAddFilesFromResources:(NSArray *)theFiles
{
    [self.files removeAllObjects];
    self.currentIndex = 0;
    [self addFilesFromResources:theFiles];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: start
//@Abstract		: The method is called to start the slide transition
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) start
{
    self.doStop = NO;
    [self next];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: next
//@Abstract		: The method is called to setup and move to the next slide
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) next
{
    if(! self.isAnimating && ([self.files count] >1 || self.dataSource)) {
        
        if ([self.delegate respondsToSelector:@selector(DPCustomSliderWillShowNext:)]) [self.delegate DPCustomSliderWillShowNext:self];
        
        // Next Slide
        if (self.sliderType == DPCustomSliderTypeImage) {
            if (self.dataSource) {
                self.topImageView.image = [UIImage imageNamed:[self.dataSource slideShow:self fileForPosition:DPCustomSliderPositionTop]];
                self.bottomImageView.image = [UIImage imageNamed:[self.dataSource slideShow:self fileForPosition:DPCustomSliderPositionBottom]];
            } else {
                NSUInteger nextIndex = (self.currentIndex+1)%[self.files count];
                self.topImageView.image = [UIImage imageNamed:self.files[self.currentIndex]];
                self.bottomImageView.image = [UIImage imageNamed:self.files[nextIndex]];
                self.currentIndex = nextIndex;
            }
        }
        else{
            if (self.dataSource) {
                self.topMoviePlayer.contentURL = [self.dataSource slideShow:self fileForPosition:DPCustomSliderPositionTop];
                self.bottomMoviePlayer.URL = [self.dataSource slideShow:self fileForPosition:DPCustomSliderPositionBottom];
            } else {
                NSUInteger nextIndex = (self.currentIndex+1)%[self.files count];
                self.topMoviePlayer.movieSourceType = MPMovieSourceTypeFile;
                self.topMoviePlayer.contentURL = self.files[self.currentIndex];
                [self.topMoviePlayer play];
                self.bottomMoviePlayer.URL = self.files[nextIndex];
                self.currentIndex = nextIndex;
            }
            
        }
        
        // Animate
        switch (transitionType) {
            case DPCustomSliderTransitionFade:
                [self animateFade];
                break;
                
            case DPCustomSliderTransitionSlide:
                [self animateSlide:DPCustomSliderSlideModeForward];
                break;
                
        }
        
        // Call delegate
        if([delegate respondsToSelector:@selector(DPCustomSliderDidShowNext:)]){
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, transitionDuration * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [delegate DPCustomSliderDidShowNext:self];
                self.pageControl.currentPage = self.currentIndex;
            });
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: previous
//@Abstract		: The method is called to setup and go back to the previous slide
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) previous
{
    if(! self.isAnimating && ([self.files count] >1 || self.dataSource)){
        
        if ([self.delegate respondsToSelector:@selector(DPCustomSliderWillShowPrevious:)]) [self.delegate DPCustomSliderWillShowPrevious:self];
        
        // Previous Slide
        if (self.sliderType == DPCustomSliderTypeImage) {
            if (self.dataSource) {
                self.topImageView.image = [UIImage imageNamed:[self.dataSource slideShow:self fileForPosition:DPCustomSliderPositionTop]];
                self.bottomImageView.image = [UIImage imageNamed:[self.dataSource slideShow:self fileForPosition:DPCustomSliderPositionBottom]];
            } else {
                NSUInteger prevIndex;
                if(self.currentIndex == 0){
                    prevIndex = [self.files count] - 1;
                }else{
                    prevIndex = (self.currentIndex-1)%[self.files count];
                }
                self.topImageView.image = [UIImage imageNamed:self.files[self.currentIndex]];
                self.bottomImageView.image = [UIImage imageNamed:self.files[prevIndex]];
                self.currentIndex = prevIndex;
            }
            
        }
        else{
            if (self.dataSource) {
                self.topMoviePlayer.contentURL = [self.dataSource slideShow:self fileForPosition:DPCustomSliderPositionTop];
                self.bottomMoviePlayer.URL = [self.dataSource slideShow:self fileForPosition:DPCustomSliderPositionBottom];
            } else {
                NSUInteger prevIndex;
                if(self.currentIndex == 0){
                    prevIndex = [self.files count] - 1;
                }else{
                    prevIndex = (self.currentIndex-1)%[self.files count];
                }
                self.topMoviePlayer.contentURL = self.files[self.currentIndex];
                [self.topMoviePlayer play];
                self.bottomMoviePlayer.URL = self.files[prevIndex];
                self.currentIndex = prevIndex;
            }
            [self.topMoviePlayer play];
        }
        
        // Animate
        switch (transitionType) {
            case DPCustomSliderTransitionFade:
                [self animateFade];
                break;
                
            case DPCustomSliderTransitionSlide:
                [self animateSlide:DPCustomSliderSlideModeBackward];
                break;
        }
        
        // Call delegate
        if([delegate respondsToSelector:@selector(DPCustomSliderDidShowPrevious:)]){
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, transitionDuration * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [delegate DPCustomSliderDidShowPrevious:self];
                self.pageControl.currentPage = self.currentIndex;
            });
        }
    }
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: animateFade
//@Abstract		: The method is used to setup and apply fade animation on slide transition. Works in image mode only
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) animateFade
{
    self.isAnimating = YES;
    if (self.sliderType == DPCustomSliderTypeImage) {
        [UIView animateWithDuration:transitionDuration
                         animations:^{
                             self.topImageView.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             
                             self.topImageView.image = self.bottomImageView.image;
                             self.topImageView.alpha = 1;
                             
                             self.isAnimating = NO;
                             
                             if(! self.doStop){
                                 [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(next) object:nil];
                                 [self performSelector:@selector(next) withObject:nil afterDelay:delay];
                             }
                         }];
    }
    else{
        [UIView animateWithDuration:transitionDuration
                         animations:^{
                             self.topMoviePlayer.view.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             
                             self.topMoviePlayer.contentURL = self.bottomMoviePlayer.URL;
                             self.topMoviePlayer.view.alpha = 1;
                             
                             self.isAnimating = NO;
                             
                             if(! self.doStop){
                                 [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(next) object:nil];
                                 [self performSelector:@selector(next) withObject:nil afterDelay:delay];
                             }
                         }];
    }
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: animateSlide:
//@Abstract		: The method is used to setup and apply slide animation for slide transition
//@Param		: mode - The mode of Slider i.e. image or video
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) animateSlide:(DPCustomSliderSlideMode) mode
{
    self.isAnimating = YES;
    if (self.sliderType == DPCustomSliderTypeImage) {
        if(mode == DPCustomSliderSlideModeBackward){
            self.bottomImageView.transform = CGAffineTransformMakeTranslation(- self.bottomImageView.frame.size.width, 0);
        }else if(mode == DPCustomSliderSlideModeForward){
            self.bottomImageView.transform = CGAffineTransformMakeTranslation(self.bottomImageView.frame.size.width, 0);
        }
        [UIView animateWithDuration:transitionDuration
                         animations:^{
                             if(mode == DPCustomSliderSlideModeBackward){
                                 self.topImageView.transform = CGAffineTransformMakeTranslation( self.topImageView.frame.size.width, 0);
                                 self.bottomImageView.transform = CGAffineTransformMakeTranslation(0, 0);
                                 
                             }else if(mode == DPCustomSliderSlideModeForward){
                                 self.topImageView.transform = CGAffineTransformMakeTranslation(- self.topImageView.frame.size.width, 0);
                                 self.bottomImageView.transform = CGAffineTransformMakeTranslation(0, 0);
                             }
                         }
                         completion:^(BOOL finished){
                             self.topImageView.image = self.bottomImageView.image;
                             self.topImageView.transform = CGAffineTransformMakeTranslation(0, 0);
                             self.isAnimating = NO;
                             
                             if(! self.doStop){
                                 [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(next) object:nil];
                                 [self performSelector:@selector(next) withObject:nil afterDelay:delay];
                             }
                         }];
    }
    else{
        if(mode == DPCustomSliderSlideModeBackward){
            self.bottomMoviePlayer.view.transform = CGAffineTransformMakeTranslation(- self.bottomMoviePlayer.view.frame.size.width, 0);
            
        }else if(mode == DPCustomSliderSlideModeForward){
            self.bottomMoviePlayer.view.transform = CGAffineTransformMakeTranslation(self.bottomMoviePlayer.view.frame.size.width, 0);
        }
        [UIView animateWithDuration:transitionDuration
                         animations:^{
                             if(mode == DPCustomSliderSlideModeBackward){
                                 self.topMoviePlayer.view.transform = CGAffineTransformMakeTranslation( self.topMoviePlayer.view.frame.size.width, 0);
                                 self.bottomMoviePlayer.view.transform = CGAffineTransformMakeTranslation(0, 0);
                             }else if(mode == DPCustomSliderSlideModeForward){
                                 self.topMoviePlayer.view.transform = CGAffineTransformMakeTranslation(- self.topMoviePlayer.view.frame.size.width, 0);
                                 self.bottomMoviePlayer.view.transform = CGAffineTransformMakeTranslation(0, 0);
                             }
                         }
                         completion:^(BOOL finished){
                             //                             self.topMoviePlayer.contentURL = self.bottomMoviePlayer.URL;
                             //                             [self.topMoviePlayer play];
                             self.topMoviePlayer.view.transform = CGAffineTransformMakeTranslation(0, 0);
                             self.isAnimating = NO;
                             if(! self.doStop){
                                 [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(next) object:nil];
                                 [self performSelector:@selector(next) withObject:nil afterDelay:delay];
                             }
                         }];
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: stop
//@Abstract		: The method is used to stop slide transition
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) stop
{
    self.doStop = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(next) object:nil];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: state
//@Abstract		: The method is used to get the current state of Slider i.e. stopped or started
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (DPCustomSliderState)state
{
    return !self.doStop;
}

#pragma mark - Gesture Recognizers initializers

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: addGestureTap
//@Abstract		: The method is used internally to add tap gesture on Slider
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) addGestureTap
{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTapGestureRecognizer];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: addGestureSwipe
//@Abstract		: The method is used internally to add swipe gesture on Slider
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) addGestureSwipe
{
    UISwipeGestureRecognizer* swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer* swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    [self addGestureRecognizer:swipeRightGestureRecognizer];
}

#pragma mark - Gesture Recognizers handling

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: handleSingleTap:
//@Abstract		: The gesture recognizer method. Is is called automatically when a single tap gesture is detected on slider view
//@Param		: sender
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)handleSingleTap:(id)sender
{
    if (self.sliderType == DPCustomSliderTypeImage) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
        CGPoint pointTouched = [gesture locationInView:self.topImageView];
        
        if (pointTouched.x <= self.topImageView.center.x){
            [self previous];
        }else {
            [self next];
        }
    }
    else{
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
        CGPoint pointTouched = [gesture locationInView:self.topMoviePlayer.view];
        if (pointTouched.x <= self.topMoviePlayer.view.center.x){
            [self previous];
        }else {
            [self next];
        }
    }
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: handleSwipe:
//@Abstract		: The gesture recognizer method. Is is called automatically when a swipe gesture is detected on slider view
//@Param		: sender
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) handleSwipe:(id)sender
{
    UISwipeGestureRecognizer *gesture = (UISwipeGestureRecognizer *)sender;
    
    float oldTransitionDuration = self.transitionDuration;
    
    self.transitionDuration = kSwipeTransitionDuration;
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self next];
    }
    else if (gesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self previous];
    }
    
    self.transitionDuration = oldTransitionDuration;
}

@end
