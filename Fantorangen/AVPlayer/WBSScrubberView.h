//
//  WBSScrubberView.h
//  Fantorangen
//
//  Created by Cameron Palmer on 13.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WBScrubberViewDelegate;



@interface WBSScrubberView : UIView

@property (weak, nonatomic) id <WBScrubberViewDelegate> delegate;

@property (strong, nonatomic, readonly) UILabel *timeElapsedLabel;
@property (strong, nonatomic, readonly) UILabel *timeRemainingLabel;
@property (strong, nonatomic, readonly) UISlider *timelineSlider;
@property (strong, nonatomic, readonly) UIProgressView *bufferProgressView;

- (IBAction)didTouchTimelineSlider:(id)sender;
- (IBAction)didSlideTimelineSlider:(id)sender;

@end



@protocol WBScrubberViewDelegate <NSObject>

- (void)didBeginTimecodeChange:(UISlider *)slider;
- (void)didChangeTimecodePercentage:(UISlider *)slider;
- (void)didEndTimecodeChange:(UISlider *)slider;

@end
