//
//  WBSAVPlayerItem.m
//  Fantorangen
//
//  Created by Cameron Palmer on 27.03.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSAVPlayerItem.h"

static void *AVPlayerItemStatusContext = &AVPlayerItemStatusContext;
static void *AVPlayerItemLoadedTimeRangesContext = &AVPlayerItemLoadedTimeRangesContext;



@interface WBSAVPlayerItem ()
@end



@implementation WBSAVPlayerItem

+ (instancetype)playerItemWithAsset:(AVAsset *)asset
{
    return [[[self class] alloc] initWithAsset:asset];
}



- (void)dealloc
{
    [self removeKVO];
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        [self initializeWithAsset:nil];
    }

    return self;
}

- (instancetype)initWithAsset:(AVAsset *)asset
{
    self = [super initWithAsset:asset];
    if (self != nil) {
        [self initializeWithAsset:asset];
    }

    return self;
}

- (void)initializeWithAsset:(AVAsset *)asset
{
    DDLogVerbose(@"%s - %@", __PRETTY_FUNCTION__, asset);

    [self addKVO];
}

- (void)playerItemDidReachEnd:(id)sender
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
}

- (void)addKVO
{
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(status))
              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
              context:AVPlayerItemStatusContext];

    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(loadedTimeRanges))
              options:NSKeyValueObservingOptionNew
              context:AVPlayerItemLoadedTimeRangesContext];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
}

- (void)removeKVO
{
    [self removeObserver:self
              forKeyPath:NSStringFromSelector(@selector(status))
                 context:AVPlayerItemStatusContext];

    [self removeObserver:self
              forKeyPath:NSStringFromSelector(@selector(loadedTimeRanges))
                 context:AVPlayerItemLoadedTimeRangesContext];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
}



#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == AVPlayerItemLoadedTimeRangesContext) {
        if ([self.delegate respondsToSelector:@selector(playerItem:loadedTimeRanges:)]) {
            [self.delegate playerItem:self loadedTimeRanges:self.loadedTimeRanges];
        }
    } else if (context == AVPlayerItemStatusContext) {
        switch (self.status) {
            case AVPlayerItemStatusUnknown:
                DDLogVerbose(@"%@", @"AVPlayerItemStatusUnknown");
                break;
            case AVPlayerItemStatusReadyToPlay:
                DDLogVerbose(@"%@", @"AVPlayerItemStatusReadyToPlay");
                break;
            case AVPlayerItemStatusFailed:
                DDLogError(@"%@, %@", @"AVPlayerItemStatusFailed", [self.error localizedFailureReason]);
                break;
        }

        if ([self.delegate respondsToSelector:@selector(playerItem:statusDidChange:)]) {
            [self.delegate playerItem:self statusDidChange:self.status];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
