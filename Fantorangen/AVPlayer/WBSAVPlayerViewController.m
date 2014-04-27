//
//  WBSAVPlayerViewController.m
//  Fantorangen
//
//  Created by Cameron Palmer on 02.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//
//  This is Apple sample code.
//

#import "WBSAVPlayerViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "WBSAVPlayerView.h"
#import "WBSScrubberView.h"
#import "WBSAVPlayerBox.h"



@interface WBSAVPlayerViewController () <WBSAVPlayerBoxDelegate>
@property (strong, nonatomic) WBSAVPlayerBox *playerBox;

@property (strong, nonatomic) UIView *av_playbackViewContainerView;
@property (strong, nonatomic) WBSAVPlayerView *av_playbackView;
@property (strong, nonatomic) UIToolbar *av_toolbar;
@property (strong, nonatomic) UIBarButtonItem *av_playButton;
@property (strong, nonatomic) UIBarButtonItem *av_pauseButton;
@property (strong, nonatomic) UIBarButtonItem *av_backButton;
@property (strong, nonatomic) UIBarButtonItem *av_forwardButton;
@property (strong, nonatomic) WBSScrubberView *av_scrubberView;

@end



@implementation WBSAVPlayerViewController

- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initializePlayerView];
    [self initializeToolbarItems];
    [self initializeScrubber];
    [self layoutInterface];
    
    [self initScrubberTimer];
    [self syncPlayPauseButtons];
    [self syncBackwardsAndForwardsButtons];
    [self syncScrubber];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}



#pragma mark - Asset URL

- (void)setURL:(NSURL *)URL
{
    if (self.URL != URL) {
        WBSAVPlayerBox *playerBox = [WBSAVPlayerBox playerBoxWithURL:URL];
        playerBox.delegate = self;
        self.playerBox = playerBox;
    }
}

-(void)setViewDisplayName
{
    self.title = [self.URL lastPathComponent];
}

- (void)layoutInterface
{
    UIView *playbackViewContainerView = self.playbackViewContainerView;
    WBSScrubberView *scrubberView = self.scrubberView;
    UIToolbar *toolbar = self.toolbar;
    
    NSArray *horizontalPlaybackViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[playbackViewContainerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(playbackViewContainerView)];
    [self.view addConstraints:horizontalPlaybackViewConstraints];
    
    [self.playbackViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.playbackView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.playbackViewContainerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self.playbackViewContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.playbackView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.playbackViewContainerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrubberView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(scrubberView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(toolbar)]];
    NSDictionary *views = NSDictionaryOfVariableBindings(playbackViewContainerView, scrubberView, toolbar);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrubberView(44.0)][playbackViewContainerView][toolbar(44.0)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views];
    [self.view addConstraints:verticalConstraints];
}



#pragma mark - Player View methods

- (void)initializePlayerView
{
    if (self.playbackView == nil) {
        UIView *playbackViewContainerView = [[UIView alloc] init];
        playbackViewContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:playbackViewContainerView];
        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapVideoGesture:)];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [playbackViewContainerView addGestureRecognizer:doubleTapGestureRecognizer];
        
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapVideoGesture:)];
        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        [playbackViewContainerView addGestureRecognizer:singleTapGestureRecognizer];
        
        self.av_playbackViewContainerView = playbackViewContainerView;
        self.playbackViewContainerView = playbackViewContainerView;
        
        WBSAVPlayerView *playbackView = [[WBSAVPlayerView alloc] init];
        playbackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.av_playbackViewContainerView addSubview:playbackView];
        
        self.av_playbackView = playbackView;
        self.playbackView = playbackView;
    }
}



#pragma mark - Toolbar button methods

- (void)initializeToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toolbar];
    
    self.av_toolbar = toolbar;
    self.toolbar = toolbar;
}

- (void)initializeToolbarItems
{
    if (self.toolbar == nil) {
        [self initializeToolbar];
    }
    
    if (self.backButton == nil) {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(backwards:)];
        self.av_backButton = backButton;
        self.backButton = backButton;
    }
    
    UIBarButtonItem *LHSFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    if (self.playButton == nil) {
        UIBarButtonItem *playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(play:)];
        self.av_playButton = playButton;
        self.playButton = playButton;
    }
    
    if (self.pauseButton == nil) {
        UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pause:)];
        self.av_pauseButton = pauseButton;
        self.pauseButton = pauseButton;
    }
    
    UIBarButtonItem *RHSFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (self.forwardButton == nil) {
        UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forwards:)];
        self.av_forwardButton = forwardButton;
        self.forwardButton = forwardButton;
    }
    
    self.toolbar.items = @[self.backButton, LHSFlexibleSpace, self.playButton, RHSFlexibleSpace, self.forwardButton];
}

- (void)showPauseButton
{
    [self replaceBarButtonItem:self.playButton with:self.pauseButton];
}

- (void)showPlayButton
{
    [self replaceBarButtonItem:self.pauseButton with:self.playButton];
}

- (void)replaceBarButtonItem:(UIBarButtonItem *)oldBarButtonItem with:(UIBarButtonItem *)newBarButtonItem
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:[self.toolbar items]];
    NSInteger index = [toolbarItems indexOfObject:oldBarButtonItem];
    if (index != NSNotFound) {
        [toolbarItems replaceObjectAtIndex:index withObject:newBarButtonItem];
    }
    
    self.toolbar.items = toolbarItems;
}

- (void)syncPlayPauseButtons
{
    if ([self.playerBox isReadyToPlay]) {
        [self enablePlayerButtons];
    } else {
        [self disablePlayerButtons];
    }

    if ([self.playerBox isPlaying]) {
        [self showPauseButton];
    } else {
        [self showPlayButton];
    }
}

- (void)syncBackwardsAndForwardsButtons
{
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
}

- (void)enablePlayerButtons
{
    self.playButton.enabled = YES;
    self.pauseButton.enabled = YES;
}

- (void)disablePlayerButtons
{
    self.playButton.enabled = NO;
    self.pauseButton.enabled = NO;
}



#pragma mark IBActions

- (IBAction)play:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [self.playerBox play];
}

- (IBAction)pause:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    [self.playerBox pause];
}

- (IBAction)backwards:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

}

- (IBAction)forwards:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
}



#pragma mark - UIGestureRecognizerDelegate

- (void)singleTapVideoGesture:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

}

- (void)doubleTapVideoGesture:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

}



#pragma mark - Movie scrubber control

- (void)initializeScrubber
{
    WBSScrubberView *scrubberView = [[WBSScrubberView alloc] init];
    scrubberView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrubberView];
    
    self.av_scrubberView = scrubberView;
    self.scrubberView = scrubberView;
}

- (void)initScrubberTimer
{
}

- (void)syncScrubber
{
}

- (void)updateTimeElapsed:(NSUInteger)elapsed
{
    self.scrubberView.timeElapsedLabel.text = [self formatTime:elapsed];
}

- (void)updateTimeRemaining:(NSUInteger)remaining
{
    self.scrubberView.timeRemainingLabel.text = [self formatTime:remaining];
}

- (NSString *)formatTime:(NSUInteger)time
{
    NSUInteger hours = floor(time / 3600);
    NSUInteger minutes = floor(time % 3600 / 60);
    NSUInteger seconds = floor(time % 3600 % 60);
    
    NSMutableArray *mutableTimeComponents = [[NSMutableArray alloc] init];
    if (hours > 0) {
        [mutableTimeComponents addObject:[NSString stringWithFormat:@"%i", (int) hours]];
    }
    [mutableTimeComponents addObject:[NSString stringWithFormat:@"%02i", (int) minutes]];
    [mutableTimeComponents addObject:[NSString stringWithFormat:@"%02i", (int) seconds]];
    
    NSString *videoDurationText = [mutableTimeComponents componentsJoinedByString:@":"];
    return videoDurationText;
}

- (void)updateAvailableVideo:(AVPlayerItem *)playerItem
{
    NSArray *times = playerItem.loadedTimeRanges;
    NSValue *value = [times firstObject];
    
    CMTimeRange range;
    [value getValue:&range];
    float start = CMTimeGetSeconds(range.start);
    float duration = CMTimeGetSeconds(range.duration);
    
    float videoAvailable = start + duration;
    self.scrubberView.bufferProgressView.progress = videoAvailable;
}



#pragma mark Getters

- (BOOL)isScrubbing
{
    return NO;
}

- (void)enableScrubber
{
    self.scrubberView.timelineSlider.enabled = YES;
}

- (void)disableScrubber
{
    self.scrubberView.timelineSlider.enabled = NO;
}



- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    UIView *view = [self view];
    UISwipeGestureRecognizerDirection direction = [gestureRecognizer direction];
    CGPoint location = [gestureRecognizer locationInView:view];
    
    if (location.y < CGRectGetMidY([view bounds])) {
        if (direction == UISwipeGestureRecognizerDirectionUp)
        {
            [UIView animateWithDuration:0.2f animations:^{
                [[self navigationController] setNavigationBarHidden:YES animated:YES];
            } completion:^(BOOL finished) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }];
        }
        if (direction == UISwipeGestureRecognizerDirectionDown)
        {
            [UIView animateWithDuration:0.2f animations:^{
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            } completion:^(BOOL finished) {
                [[self navigationController] setNavigationBarHidden:NO animated:YES];
            }];
        }
    } else {
        if (direction == UISwipeGestureRecognizerDirectionDown) {
            if (![self.toolbar isHidden]) {
                [UIView animateWithDuration:0.2f animations:^{
                    [self.toolbar setTransform:CGAffineTransformMakeTranslation(0.f, CGRectGetHeight([self.toolbar bounds]))];
                } completion:^(BOOL finished) {
                    [self.toolbar setHidden:YES];
                }];
            }
        } else if (direction == UISwipeGestureRecognizerDirectionUp) {
            if ([self.toolbar isHidden]) {
                [self.toolbar setHidden:NO];
                
                [UIView animateWithDuration:0.2f animations:^{
                    [self.toolbar setTransform:CGAffineTransformIdentity];
                } completion:^(BOOL finished){}];
            }
        }
    }
}

- (void)playerBox:(WBSAVPlayerBox *)playerBox readyToPlay:(BOOL)ready
{
    [self syncPlayPauseButtons];
}

- (void)playerBox:(WBSAVPlayerBox *)playerBox playing:(BOOL)playing
{
    [self syncPlayPauseButtons];
}


@end