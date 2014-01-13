//
//  WBSScrubberView.m
//  Fantorangen
//
//  Created by Cameron Palmer on 13.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSScrubberView.h"



@interface WBSScrubberView ()
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UIProgressView *progressView;

@end



@implementation WBSScrubberView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initialize];
    }
    
    return self;
}

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
    UISlider *slider = [[UISlider alloc] init];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1.0f, 1.0f), NO, 0.0f);
    UIImage *clearImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [slider setMinimumTrackImage:clearImage forState:UIControlStateNormal];
    [slider setMaximumTrackImage:clearImage forState:UIControlStateNormal];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.progress = 1.0f;
    [progressView addSubview:slider];
    
    [progressView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[slider(44.0)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(slider)]];
    [progressView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[slider]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(slider)]];
    
    [self addSubview:progressView];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[progressView(44.0)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(progressView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[progressView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(progressView)]];
    

    
    _slider = slider;
    _progressView = progressView;
}

@end
