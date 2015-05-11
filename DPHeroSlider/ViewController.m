//
//  ViewController.m
//  DPHeroSlider
//
//  Created by MAC 52 on 02/04/15.
//  Copyright (c) 2015 Jitendra Mishra. All rights reserved.
//

#import "ViewController.h"

#define SLIDE_SHOW_DELAY 2
#define SLIDE_TRANSITION_DURATION .5

@interface ViewController ()
@property (strong,nonatomic) IBOutlet DPCustomSlider * slideshow;
@property(nonatomic,strong)NSMutableArray *dataArray;
@end

@implementation ViewController

//Working Branch Same Line Commit 123"
/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: viewDidLoad
//@Abstract		: We can initialize and setup the slider component in viewDidLoad
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataArray = [NSMutableArray array];
    [self populateSliderWithType:DPCustomSliderTypeImage];
    [self performSelector:@selector(start) withObject:nil afterDelay:SLIDE_SHOW_DELAY]; //Start the slide transition
    
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: populateSliderWithType:
//@Abstract		: This method is used to customize Slider by setting public properties of Component
//@Param		   : sliderType - DPCustomSliderType value
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////
-(void)populateSliderWithType:(DPCustomSliderType)sliderType{
    
    self.slideshow.delegate = self; //Setting the delegate of the slider component to self
    [self.slideshow setDelay:SLIDE_SHOW_DELAY]; // Delay between transitions
    [self.slideshow setTransitionDuration:SLIDE_TRANSITION_DURATION]; // Transition duration
    [self.slideshow setTransitionType:DPCustomSliderTransitionSlide]; // Choose a transition type (fade or slide)
    self.slideshow.gestureRecognizers = nil; //Set the gesture recognizers to nil if any
    [self.slideshow addGesture:DPCustomSliderGestureSwipe]; //Add swipe gesture to the Slider Component
    [self.slideshow setSliderType:sliderType]; //Set the type of Slider component i.e. Image or Video
    [self.slideshow addGesture:DPCustomSliderGestureTap]; // Gesture to go previous/next directly on tap of the view
    if (sliderType == DPCustomSliderTypeImage) {
        for (NSInteger loopIndex = 0; loopIndex < 5; loopIndex++) {
            NSString *imageName = [NSString stringWithFormat:@"%ld.jpg",(long)loopIndex+1];
            [self.dataArray addObject:imageName];
        }
    }
    else{
        for (NSInteger loopIndex = 0; loopIndex < 5; loopIndex++) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *moviePath;
            if (loopIndex%2) {
                moviePath = [bundle pathForResource:@"video_1" ofType:@"mp4"];
            }
            else{
                moviePath = [bundle pathForResource:@"big_buck_bunny" ofType:@"mp4"];
            }
            NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
            [self.dataArray addObject:movieURL];
        }
    }
    self.slideshow.dataArray = self.dataArray;
    //Initialize the Slider component
    [self.slideshow initializeSlider];
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: start
//@Abstract		: This method is used to start the slider transition
//@Param		: NA
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)start{
    [self.slideshow start];
}

#pragma mark - DPCustomSlider delegate

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: DPCustomSliderWillShowNext:
//@Abstract		: This delegate method is called automatically when the slider is about to display the next slide
//@Param		: slider - The DPCustomSlider object
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)DPCustomSliderWillShowNext:(DPCustomSlider *)slider
{
    NSLog(@"kaSlideShowWillShowNext, index : %@",@(slider.currentIndex));
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: DPCustomSliderWillShowPrevious:
//@Abstract		: This delegate method is called automatically when the slider is about to display the previous slide
//@Param		: slider - The DPCustomSlider object
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void)DPCustomSliderWillShowPrevious:(DPCustomSlider *)slider
{
    NSLog(@"kaSlideShowWillShowPrevious, index : %@",@(slider.currentIndex));
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: DPCustomSliderDidShowNext:
//@Abstract		: This delegate method is called automatically when the slider is moved to the next slide
//@Param		: slider - The DPCustomSlider object
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

- (void) DPCustomSliderDidShowNext:(DPCustomSlider *)slider
{
    NSLog(@"kaSlideShowDidNext, index : %@",@(slider.currentIndex));
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: DPCustomSliderDidShowNext:
//@Abstract		: This delegate method is called automatically when the slider is moved back to the previous slide
//@Param		: slider - The DPCustomSlider object
//@Returntype	: void
//@Author		: Jitendra Mishra
/////////////////////////////////////////////////////////////////////////////////////////////////

-(void)DPCustomSliderDidShowPrevious:(DPCustomSlider *)slider
{
    NSLog(@"kaSlideShowDidPrevious, index : %@",@(slider.currentIndex));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
