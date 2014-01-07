//
//  WBSAVPlayerViewController.h
//  Fantorangen
//
//  Created by Cameron Palmer on 02.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@class AVPlayerItem;
@class WBSAVPlayerView;

@protocol WBSAVPlayerViewControllerDelegate;



@interface WBSAVPlayerViewController : UIViewController

@property (weak, nonatomic) id <WBSAVPlayerViewControllerDelegate> delegate;

@property (copy, nonatomic) NSURL *URL;
@property (weak, nonatomic) IBOutlet WBSAVPlayerView *playbackView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UISlider *scrubber;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)backwards:(id)sender;
- (IBAction)forwards:(id)sender;

@end


@protocol WBSAVPlayerViewControllerDelegate <NSObject>
@optional
- (void)playerItemReadyToPlay:(id)sender;
- (void)playerItemDidReachEnd:(id)sender;

@end