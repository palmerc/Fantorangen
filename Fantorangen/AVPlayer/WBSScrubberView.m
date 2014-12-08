//
//  WBSScrubberView.m
//  Fantorangen
//
//  Created by Cameron Palmer on 13.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSScrubberView.h"

#import "NSObject+Nametags.h"
#import "UIImage+Resize.h"



@interface WBSScrubberView ()
@property (strong, nonatomic, readwrite) UILabel *timeElapsedLabel;
@property (strong, nonatomic, readwrite) UILabel *timeRemainingLabel;
@property (strong, nonatomic, readwrite) UIView *sliderProgressContainer;
@property (strong, nonatomic, readwrite) UISlider *timelineSlider;
@property (strong, nonatomic, readwrite) UIProgressView *bufferProgressView;

@end



@implementation WBSScrubberView

- (id)init
{
    self = [super init];
    if (self != nil) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor colorWithWhite:0.96f alpha:0.95f];
    
    [self initializeTimeElapsedLabel];
    [self initializeTimeRemainingLabel];
    [self initializeSliderProgressContainer];
}

- (void)initializeTimeElapsedLabel
{
    UILabel *timeElapsedLabel = [[UILabel alloc] init];
    timeElapsedLabel.font = [WBSScrubberView labelFont];
    timeElapsedLabel.textAlignment = NSTextAlignmentCenter;
    timeElapsedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    timeElapsedLabel.text = @"0:00";
    [self addSubview:timeElapsedLabel];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:timeElapsedLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    _timeElapsedLabel = timeElapsedLabel;
}

- (void)initializeTimeRemainingLabel
{
    UILabel *timeRemainingLabel = [[UILabel alloc] init];
    timeRemainingLabel.font = [WBSScrubberView labelFont];
    timeRemainingLabel.textAlignment = NSTextAlignmentCenter;
    timeRemainingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    timeRemainingLabel.text = @"0:00";
    [self addSubview:timeRemainingLabel];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:timeRemainingLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    _timeRemainingLabel = timeRemainingLabel;
}

- (void)initializeSliderProgressContainer
{
    UIView *sliderProgressContainer = [[UIView alloc] init];
    sliderProgressContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:sliderProgressContainer];
    _sliderProgressContainer = sliderProgressContainer;

    // BufferProgressView
    UIProgressView *bufferProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    bufferProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    [sliderProgressContainer addSubview:bufferProgressView];
    bufferProgressView.progress = 0.0f;
    _bufferProgressView = bufferProgressView;
    [self layoutBufferProgressView];
    
    // TimelineSlider
    UISlider *timelineSlider = [[UISlider alloc] init];
    [timelineSlider addTarget:self action:@selector(didTouchDownTimelineSlider:) forControlEvents:UIControlEventTouchDown];
    [timelineSlider addTarget:self action:@selector(didTouchUpTimelineSlider:) forControlEvents:UIControlEventTouchUpInside];
    [timelineSlider addTarget:self action:@selector(didSlideTimelineSlider:) forControlEvents:UIControlEventValueChanged];
    timelineSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [sliderProgressContainer addSubview:timelineSlider];
    [timelineSlider setMinimumTrackImage:[WBSScrubberView clearImage] forState:UIControlStateNormal];
    [timelineSlider setMaximumTrackImage:[WBSScrubberView clearImage] forState:UIControlStateNormal];
    _timelineSlider = timelineSlider;
    [self layoutTimelineSlider];
    
    [self layoutSliderProgressContainer];
}

- (void)layoutBufferProgressView
{
    UIView *bufferProgressView = self.bufferProgressView;
    
    [self.sliderProgressContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bufferProgressView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bufferProgressView)]];
    [self.sliderProgressContainer addConstraint:[NSLayoutConstraint constraintWithItem:bufferProgressView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.sliderProgressContainer attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
}

- (void)layoutTimelineSlider
{
    UIView *timelineSlider = self.timelineSlider;
    
    [self.sliderProgressContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[timelineSlider]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(timelineSlider)]];
    [self.sliderProgressContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[timelineSlider]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(timelineSlider)]];
}

- (void)layoutSliderProgressContainer
{
    UIView *timeElapsedLabel = self.timeElapsedLabel;
    UIView *sliderProgressContainer = self.sliderProgressContainer;
    UIView *timeRemainingLabel = self.timeRemainingLabel;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[timeElapsedLabel(50.0)][sliderProgressContainer][timeRemainingLabel(50.0)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(timeElapsedLabel, sliderProgressContainer, timeRemainingLabel)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sliderProgressContainer]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sliderProgressContainer)]];
}



#pragma mark - IBActions

- (IBAction)didTouchDownTimelineSlider:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    if ([self.delegate respondsToSelector:@selector(didBeginTimecodeChange:)]) {
        [self.delegate didBeginTimecodeChange:sender];
    }
}

- (IBAction)didTouchUpTimelineSlider:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    if ([self.delegate respondsToSelector:@selector(didEndTimecodeChange:)]) {
        [self.delegate didEndTimecodeChange:sender];
    }
}

- (IBAction)didSlideTimelineSlider:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    if ([self.delegate respondsToSelector:@selector(didChangeTimecodePercentage:)]) {
        [self.delegate didChangeTimecodePercentage:sender];
    }
}



#pragma mark - Helpers

+ (UIFont *)labelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
}

+ (UIImage *)clearImage
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0f, 1.0f), NO, 0.0f);
    UIImage *clearImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return clearImage;
}

@end
