//
//  WBSAVPlayerBox.m
//  Fantorangen
//
//  Created by Cameron Palmer on 27.03.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSAVPlayerBox.h"

static void *AVPlayerObservationContext = &AVPlayerObservationContext;



@interface WBSAVPlayerBox ()
@property (strong, nonatomic, readwrite) AVPlayer *player;
@property (assign, nonatomic, readwrite) NSTimeInterval currentTime;

@property (strong, nonatomic) id timeObserver;

@end



@implementation WBSAVPlayerBox

+ (instancetype)playerBoxWithURL:(NSURL *)URL
{
    return [[[self class] alloc] initWithURL:URL];
}

- (void)dealloc
{
    self.player = nil;
}

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self != nil) {
        [self initializeWithURL:URL];
    }

    return self;
}

- (void)initializeWithURL:(NSURL *)URL
{
    DDLogVerbose(@"%s - %@", __PRETTY_FUNCTION__, URL);

    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:URL];

    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    player.allowsExternalPlayback = YES;
    self.player = player;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == AVPlayerObservationContext) {
        AVPlayer *player = object;
        NSString *currentItemKeyPath = NSStringFromSelector(@selector(currentItem));
        NSString *rateKeyPath = NSStringFromSelector(@selector(rate));
        if ([keyPath isEqualToString:rateKeyPath]) {
            DDLogVerbose(@"%@ - %f", rateKeyPath, player.rate);
            if ([self.delegate respondsToSelector:@selector(player:didChangeRate:)]) {
                [self.delegate player:player didChangeRate:player.rate];
            }
        } else if ([keyPath isEqualToString:currentItemKeyPath]) {
            DDLogVerbose(@"%@ - %@", currentItemKeyPath, player.currentItem);
            if ([self.delegate respondsToSelector:@selector(player:didChangeCurrentItem:)]) {
                [self.delegate player:player didChangeCurrentItem:player.currentItem];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



#pragma mark - Setters

- (void)setPlayer:(AVPlayer *)player
{
    if (self.player != player) {
        DDLogVerbose(@"%s - %@", __PRETTY_FUNCTION__, self.player);

        [self.player removeTimeObserver:self.timeObserver];
        [self.player removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentItem)) context:AVPlayerObservationContext];
        [self.player removeObserver:self forKeyPath:NSStringFromSelector(@selector(rate)) context:AVPlayerObservationContext];
    }

    _player = player;

    if (self.player != nil) {
        DDLogVerbose(@"AVPlayer Setup - %@", self.player);

        [self.player addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(currentItem))
                         options:NSKeyValueObservingOptionNew
                         context:AVPlayerObservationContext];

        [self.player addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(rate))
                         options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                         context:AVPlayerObservationContext];

        __weak typeof(self) weakSelf = self;
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC)
                                                                      queue:NULL
                                                                 usingBlock:^(CMTime time) {
                                                                     weakSelf.currentTime = CMTimeGetSeconds(time);
                                                                 }];
    }
}

@end
