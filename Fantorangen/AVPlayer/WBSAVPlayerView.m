//
//  WBSAVPlayerView.m
//  Fantorangen
//
//  Created by Cameron Palmer on 02.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//
//  This is Apple sample code.
//

#import "WBSAVPlayerView.h"

@import AVFoundation;

static NSString *const kPlayerItemPresentationSizeKey = @"presentationSize";



@interface WBSAVPlayerView ()
@property (weak, nonatomic) AVPlayerItem *currentPlayerItem;
@property (assign, nonatomic) CGSize presentationSize;

@end



@implementation WBSAVPlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer *)player
{    
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    AVPlayerItem *playerItem = player.currentItem;
    if (self.currentPlayerItem != playerItem) {
        [self.currentPlayerItem removeObserver:self forKeyPath:kPlayerItemPresentationSizeKey];

        [player.currentItem addObserver:self forKeyPath:kPlayerItemPresentationSizeKey options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
        self.currentPlayerItem = playerItem;
    }

    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)[self layer];
    playerLayer.videoGravity = fillMode;
}

- (CGRect)getVideoContentFrame {
    AVPlayerLayer *avLayer = (AVPlayerLayer *)[self layer];
    
    return avLayer.videoRect;
}

- (CGSize)intrinsicContentSize
{
    return self.presentationSize;
}
     
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        AVPlayerItem *playerItem = object;
        self.presentationSize = playerItem.presentationSize;
        
        [self invalidateIntrinsicContentSize];
    }
}

@end
