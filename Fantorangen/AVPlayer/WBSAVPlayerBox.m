//
//  WBSAVPlayerBox.m
//  Fantorangen
//
//  Created by Cameron Palmer on 27.03.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSAVPlayerBox.h"

@import MediaPlayer;

#import "WBSAVURLAsset.h"
#import "WBSAVPlayerItem.h"

static void *AVPlayerObservationCurrentItemContext = &AVPlayerObservationCurrentItemContext;
static void *AVPlayerObservationRateContext = &AVPlayerObservationRateContext;



@interface WBSAVPlayerBox () <WBSAVURLAssetDelegate, WBSAVPlayerItemDelegate>

@property (strong, nonatomic, readwrite) AVPlayer *player;
@property (assign, nonatomic, readwrite) NSTimeInterval currentTime;

@property (strong, nonatomic) WBSAVPlayerItem *playerItem;
@property (strong, nonatomic) WBSAVURLAsset *URLAsset;

@property (assign, nonatomic, getter = isReadyToPlay, readwrite) BOOL readyToPlay;
@property (assign, nonatomic, getter = isPlaying, readwrite) BOOL playing;

@property (strong, nonatomic) id timeObserver;
@property (assign, nonatomic, getter = isObserving) BOOL observing;

@end



@implementation WBSAVPlayerBox

+ (instancetype)playerBoxWithURL:(NSURL *)URL
{
    return [[[self class] alloc] initWithURL:URL];
}

+ (instancetype)playerBoxWithAsset:(AVAsset *)asset
{
    return [[[self class] alloc] initWithAsset:asset];
}



- (void)dealloc
{
    self.player = nil;
}

- (instancetype)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self != nil) {
        [self initializeWithAsset:asset];
    }

    return self;
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

    WBSAVURLAsset *URLAsset = [[WBSAVURLAsset alloc] initWithURL:URL];
    URLAsset.delegate = self;
    [URLAsset load];
    self.URLAsset = URLAsset;
}

- (void)initializeWithAsset:(AVAsset *)asset
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    WBSAVPlayerItem *playerItem = [WBSAVPlayerItem playerItemWithAsset:asset];
    playerItem.delegate = self;
    self.playerItem = playerItem;

    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    player.allowsExternalPlayback = YES;
    self.player = player;

    self.readyToPlay = YES;
}



#pragma mark - Media playback controls

- (void)play
{
    if (self.readyToPlay) {
        [self.player play];
    }
}

- (void)pause
{
    [self.player pause];
}

- (void)stop
{
    [self pause];
    self.player = nil;
}

- (void)seekToTime:(NSTimeInterval)newSeekTime
{
    AVPlayerItem *playerItem = [self.player currentItem];

    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.player seekToTime:CMTimeMakeWithSeconds(newSeekTime, NSEC_PER_SEC)
              completionHandler:^(BOOL finished) {
                  if (finished) {
                      [self updateNowPlayingInfo];
                  }
              }
         ];
    }
}



#pragma mark - NowPlayingInfo

- (void)updateNowPlayingInfo
{
    NSMutableDictionary *mutableNowPlayingInfo = [[NSMutableDictionary alloc] init];

    AVPlayerItem *item = self.player.currentItem;
    if (item != nil) {
        NSDictionary *metadataCommonKeysMapping = @{
                                                    AVMetadataCommonKeyTitle: MPMediaItemPropertyTitle,
                                                    AVMetadataCommonKeyAlbumName: MPMediaItemPropertyAlbumTitle,
                                                    AVMetadataCommonKeyArtist: MPMediaItemPropertyArtist,
                                                    AVMetadataCommonKeyArtwork: MPMediaItemPropertyArtwork
                                                    };

        for (NSString *metadataCommonKey in metadataCommonKeysMapping.keyEnumerator) {
            NSArray *metadataItems = [AVMetadataItem metadataItemsFromArray:item.asset.commonMetadata withKey:metadataCommonKey keySpace:AVMetadataKeySpaceCommon];

            if ([metadataItems count] > 0) {
                AVMetadataItem *metadataItem = [metadataItems firstObject];
                NSString *metadataItemKey = metadataItem.stringValue;

                id mediaItemProperty = [metadataCommonKeysMapping objectForKey:metadataItemKey];
                if ([metadataItemKey isEqualToString:AVMetadataCommonKeyArtwork]) {
                    UIImage *image = [UIImage imageWithData:metadataItem.value[@"data"]];
                    mediaItemProperty = [[MPMediaItemArtwork alloc] initWithImage:image];
                }

                [mutableNowPlayingInfo setObject:mediaItemProperty forKey:metadataItemKey];
            }
        }

        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:[mutableNowPlayingInfo copy]];
    }
}



#pragma mark - Getters / Setters

- (NSTimeInterval)duration
{
    NSTimeInterval duration = 0.0f;
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        duration = CMTimeGetSeconds([playerItem duration]);
    }

    return duration;
}

- (void)setPlayer:(AVPlayer *)player
{
    if (self.player != player) {
        DDLogVerbose(@"%s - %@", __PRETTY_FUNCTION__, self.player);

        [self removeKVO];
    }

    _player = player;

    if (self.player != nil) {
        DDLogVerbose(@"AVPlayer Setup - %@", self.player);

        [self addKVO];
    }
}

- (void)setReadyToPlay:(BOOL)readyToPlay
{
    if (self.readyToPlay != readyToPlay) {
        _readyToPlay = readyToPlay;

        if ([self.delegate respondsToSelector:@selector(playerBox:readyToPlay:)]) {
            [self.delegate playerBox:self readyToPlay:self.readyToPlay];
        }
    }
}

- (void)updatePlaying
{
    self.playing = (0 != isgreater(self.player.rate, 0.0f));

    if ([self.delegate respondsToSelector:@selector(playerBox:playing:)]) {
        [self.delegate playerBox:self playing:self.isPlaying];
    }
}



#pragma mark - WBSAVURLAssetDelegate methods

- (void)asset:(WBSAVURLAsset *)URLAsset didLoadURL:(NSURL *)URL
{
    [self initializeWithAsset:URLAsset];
}

- (void)asset:(WBSAVURLAsset *)URLAsset failedToLoadURL:(NSURL *)URL
{
    self.readyToPlay = NO;
}



#pragma mark - WBSAVPlayerItemDelegate

- (void)playerItem:(WBSAVPlayerItem *)playerItem loadedTimeRanges:(NSArray *)loadedTimeRanges
{
    NSArray *times = playerItem.loadedTimeRanges;
    NSValue *value = [times firstObject];

    CMTimeRange range;
    [value getValue:&range];
    float start = CMTimeGetSeconds(range.start);
    float duration = CMTimeGetSeconds(range.duration);

    float videoAvailable = start + duration;
//    self.scrubberView.bufferProgressView.progress = videoAvailable;
}



#pragma mark - KVO

- (void)addKVO
{
    if (!self.isObserving) {
        self.observing = YES;
        [self.player addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(currentItem))
                         options:NSKeyValueObservingOptionNew
                         context:AVPlayerObservationCurrentItemContext];

        [self.player addObserver:self
                      forKeyPath:NSStringFromSelector(@selector(rate))
                         options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                         context:AVPlayerObservationRateContext];

        __weak typeof(self) weakSelf = self;
        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC)
                                                                      queue:NULL
                                                                 usingBlock:^(CMTime time) {
                                                                     weakSelf.currentTime = CMTimeGetSeconds(time);
                                                                 }];
    }
}

- (void)removeKVO
{
    if (self.isObserving) {
        [self.player removeTimeObserver:self.timeObserver];

        [self.player removeObserver:self forKeyPath:NSStringFromSelector(@selector(currentItem)) context:AVPlayerObservationCurrentItemContext];
        [self.player removeObserver:self forKeyPath:NSStringFromSelector(@selector(rate)) context:AVPlayerObservationRateContext];
        self.observing = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == AVPlayerObservationRateContext) {
        [self updatePlaying];
    } else if (context == AVPlayerObservationCurrentItemContext) {
        AVPlayer *player = object;
        if ([self.delegate respondsToSelector:@selector(playerBox:didChangeCurrentItem:)]) {
            [self.delegate playerBox:self didChangeCurrentItem:player.currentItem];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
