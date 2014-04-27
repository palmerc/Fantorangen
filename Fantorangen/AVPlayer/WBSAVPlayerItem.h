//
//  WBSAVPlayerItem.h
//  Fantorangen
//
//  Created by Cameron Palmer on 27.03.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

@import AVFoundation;

@protocol WBSAVPlayerItemDelegate;



@interface WBSAVPlayerItem : AVPlayerItem
@property (weak, nonatomic) id <WBSAVPlayerItemDelegate> delegate;

+ (instancetype)playerItemWithAsset:(AVAsset *)URLAsset;

@end



@protocol WBSAVPlayerItemDelegate <NSObject>
@optional
- (void)playerItem:(WBSAVPlayerItem *)playerItem statusDidChange:(AVPlayerItemStatus)status;
- (void)playerItem:(WBSAVPlayerItem *)playerItem loadedTimeRanges:(NSArray *)loadedTimeRanges;

@end