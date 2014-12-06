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

static void *AVPlayerItemObservationContext = &AVPlayerItemObservationContext;
static void *AVPlayerObservationContext = &AVPlayerObservationContext;

NSString *const kAVPlayerItemDidPlayToEndTimeNotification = @"AVPlayerItemDidPlayToEndTimeNotification";

/* AVURLAsset keys */
NSString *const kAVURLAssetTracksKey = @"tracks";
NSString *const kAVURLAssetPlayableKey = @"playable";

/* AVPlayerItem keys */
NSString *const kAVPlayerItemStatusKey = @"status";
NSString *const kAVPlayerItemLoadedTimeRangesKey = @"loadedTimeRanges";

/* AVPlayer keys */
NSString *const kAVPlayerRateKey = @"rate";
NSString *const kAVPlayerCurrentItemKey = @"currentItem";



@interface WBSAVPlayerViewController (Player)
- (void)removePlayerTimeObserver;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void *)context;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
@end



@interface WBSAVPlayerViewController ()
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (strong, nonatomic) UIView *av_playbackViewContainerView;
@property (strong, nonatomic) WBSAVPlayerView *av_playbackView;
@property (strong, nonatomic) UIToolbar *av_toolbar;
@property (strong, nonatomic) UIBarButtonItem *av_playButton;
@property (strong, nonatomic) UIBarButtonItem *av_pauseButton;
@property (strong, nonatomic) UIBarButtonItem *av_backButton;
@property (strong, nonatomic) UIBarButtonItem *av_forwardButton;
@property (strong, nonatomic) WBSScrubberView *av_scrubberView;

@property (assign, nonatomic) BOOL seekToZeroBeforePlay;
@property (strong, nonatomic) id timeObserver;
@property (assign, nonatomic) CGFloat restoreAfterScrubbingRate;

@end



@implementation WBSAVPlayerViewController

- (void)dealloc
{
    [self removePlayerTimeObserver];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.player removeObserver:self forKeyPath:kAVPlayerRateKey];
    [self.player removeObserver:self forKeyPath:kAVPlayerCurrentItemKey];
    [self.player.currentItem removeObserver:self forKeyPath:kAVPlayerItemStatusKey];
    [self.player.currentItem removeObserver:self forKeyPath:kAVPlayerItemLoadedTimeRangesKey];
    
    [self.player pause];
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
    
    [self.player pause];
}



#pragma mark - Asset URL

- (void)setURL:(NSURL *)URL
{
    if (self.URL != URL)
    {
        _URL = [URL copy];
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.URL options:nil];
        NSArray *requestedKeys = @[kAVURLAssetTracksKey, kAVURLAssetPlayableKey];
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self prepareToPlayAsset:asset withKeys:requestedKeys];
            });
        }];
    }
}

-(void)setViewDisplayName
{
    self.title = [self.URL lastPathComponent];
    
    for (AVMetadataItem *item in ([[[self.player currentItem] asset] commonMetadata])) {
        NSString *commonKey = [item commonKey];
        
        if ([commonKey isEqualToString:AVMetadataCommonKeyTitle]) {
            self.title = [item stringValue];
        }
    }
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

/* If the media is playing, show the pause button; otherwise, show the play button. */
- (void)syncPlayPauseButtons
{
    if ([self isPlaying]) {
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
    
    /* If we are at the end of the movie, we must seek to the beginning first
     before starting playback. */
    if (self.seekToZeroBeforePlay == YES) {
        self.seekToZeroBeforePlay = NO;
        [self.player seekToTime:kCMTimeZero];
    }
    
    [self.player play];
    
    [self showPauseButton];
}

- (IBAction)pause:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    [self.player pause];
        
    [self showPlayButton];
}

- (IBAction)backwards:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

}

- (IBAction)forwards:(id)sender
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

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
- (void)initScrubberTimer
{
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    NSUInteger duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        CGFloat width = CGRectGetWidth([self.scrubberView bounds]);
        if (width > 0) {
            [self updateTimeRemaining:duration];
            interval = 0.5f * duration / width;
        }
    }
    
    /* Update the scrubber during normal playback. */
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                  queue:NULL
                                                             usingBlock:^(CMTime time) {
                                                                 [weakSelf syncScrubber];
                                                             }];
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        self.scrubberView.timelineSlider.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        
        float minValue = [self.scrubberView.timelineSlider minimumValue];
        float maxValue = [self.scrubberView.timelineSlider maximumValue];
        double time = CMTimeGetSeconds([self.player currentTime]);
        [self updateTimeElapsed:time];

        [self.scrubberView.timelineSlider setValue:(maxValue - minValue) * time / duration + minValue];
    }
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
        [mutableTimeComponents addObject:[NSString stringWithFormat:@"%i", hours]];
    }
    [mutableTimeComponents addObject:[NSString stringWithFormat:@"%02i", minutes]];
    [mutableTimeComponents addObject:[NSString stringWithFormat:@"%02i", seconds]];
    
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



#pragma mark IBActions

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (IBAction)beginScrubbing:(id)sender
{
    self.restoreAfterScrubbingRate = [self.player rate];
    [self.player setRate:0.f];
    
    /* Remove previous timer. */
    [self removePlayerTimeObserver];
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]]) {
        UISlider *slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration)) {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
        }
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender
{
    if (!self.timeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([self.scrubberView bounds]);
            double tolerance = 0.5f * duration / width;
            
            __weak typeof(self) weakSelf = self;
            self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
                [weakSelf syncScrubber];
            }];
        }
    }
    
    if (self.restoreAfterScrubbingRate)
    {
        [self.player setRate:self.restoreAfterScrubbingRate];
        self.restoreAfterScrubbingRate = 0.f;
    }
}



#pragma mark Getters

- (BOOL)isScrubbing
{
    return self.restoreAfterScrubbingRate != 0.f;
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

@end

@implementation WBSAVPlayerViewController (Player)

#pragma mark Player Item

- (BOOL)isPlaying
{
    return self.restoreAfterScrubbingRate != 0.f || [self.player rate] != 0.f;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    self.seekToZeroBeforePlay = YES;
    
    if ([self.delegate respondsToSelector:@selector(playerItemDidReachEnd:)]) {
        [self.delegate playerItemDidReachEnd:self.playerItem];
    }
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
    CMTime duration = kCMTimeInvalid;
    
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        duration = [playerItem duration];
    }
    
    return duration;
}

/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
    }
}



#pragma mark - Loading the Asset Keys Asynchronously

#pragma mark - Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    [self disablePlayerButtons];
    
    /* Display the error. */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}



#pragma mark Prepare to play asset, URL

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys) {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed) {
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable) {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.playerItem) {
        /* Remove existing player item key value observers and notifications. */
        
        [self.playerItem removeObserver:self forKeyPath:kAVPlayerItemStatusKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    // AVPlayerItem
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.playerItem addObserver:self
                      forKeyPath:kAVPlayerItemStatusKey
                         options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                         context:AVPlayerItemObservationContext];
    
    [self.playerItem addObserver:self
                      forKeyPath:kAVPlayerItemLoadedTimeRangesKey
                         options:NSKeyValueObservingOptionNew
                         context:AVPlayerItemObservationContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    self.seekToZeroBeforePlay = NO;
    
    /* Create new player, if we don't already have one. */
    if (!self.player) {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];
        self.player.allowsExternalPlayback = YES;
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        
        [self.player addObserver:self
                      forKeyPath:kAVPlayerCurrentItemKey
                         options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                         context:AVPlayerObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:kAVPlayerRateKey
                         options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                         context:AVPlayerObservationContext];
    }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.playerItem) {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur*/
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        
        [self syncPlayPauseButtons];
    }
    
    [self.scrubberView.timelineSlider setValue:0.0];
}



#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == AVPlayerObservationContext) {
        [self playerObservationForKeyPath:keyPath change:change];
    } else if (context == AVPlayerItemObservationContext) {
        [self playerItemObservationForKeyPath:keyPath change:change playerItem:object];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark AVPlayerObservation

- (void)playerObservationForKeyPath:(NSString *)keyPath change:(NSDictionary *)change
{
    if ([keyPath isEqualToString:kAVPlayerCurrentItemKey]) {
        /* AVPlayer "currentItem" property observer.
         Called when the AVPlayer replaceCurrentItemWithPlayerItem:
         replacement will/did occur. */
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null]) {
            [self disablePlayerButtons];
            [self disableScrubber];
        } else {
            /* Replacement of player currentItem has occurred */
            /* Set the AVPlayer for which the player layer displays visual output. */
            [self initializePlayerView];
            
            [self.playbackView setPlayer:self.player];
            
            [self setViewDisplayName];
            
            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            [self.playbackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            [self syncPlayPauseButtons];
        }
    }
}

#pragma mark AVPlayerItemObservation

- (void)playerItemObservationForKeyPath:(NSString *)keyPath change:(NSDictionary *)change playerItem:(AVPlayerItem *)playerItem
{
    if ([keyPath isEqualToString:kAVPlayerItemLoadedTimeRangesKey]) {
        [self performSelectorOnMainThread:@selector(updateAvailableVideo:) withObject:playerItem waitUntilDone:NO];
    } else if ([keyPath isEqualToString:kAVPlayerItemStatusKey]) {
        [self syncPlayPauseButtons];
        
        AVPlayerStatus playerStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (playerStatus) {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncScrubber];
                
                [self disableScrubber];
                [self disablePlayerButtons];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                [self initScrubberTimer];
                
                [self enableScrubber];
                [self enablePlayerButtons];
                
                if ([self.delegate respondsToSelector:@selector(playerItemReadyToPlay:)]) {
                    [self.delegate playerItemReadyToPlay:playerItem ];
                }
            }
                break;
                
            case AVPlayerStatusFailed:
                [self assetFailedToPrepareForPlayback:playerItem.error];
                break;
        }
    }
}

@end