//
//  WBSAVPlayerBox.h
//  Fantorangen
//
//  Created by Cameron Palmer on 27.03.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSAVPlayerItem.h"

@import AVFoundation;

@protocol WBSAVPlayerBoxDelegate;
//http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8



@interface WBSAVPlayerBox : NSObject
@property (weak, nonatomic) id <WBSAVPlayerBoxDelegate> delegate;

@property (strong, nonatomic, readonly) AVPlayer *player;

@property (assign, nonatomic, getter = isReadyToPlay, readonly) BOOL readyToPlay;
@property (assign, nonatomic, getter = isPlaying, readonly) BOOL playing;

@property (assign, nonatomic, readonly) NSTimeInterval currentTime;
@property (assign, nonatomic, readonly) NSTimeInterval duration;

/*!
 @method        playerBoxWithURL:
 @abstract		Returns an instance of WBSAVPlayerBox that plays a single audiovisual resource referenced by URL.
 @param			URL
 @result		An instance of WBSAVPlayerBox
 @discussion	Implicitly creates an AVPlayerItem. Clients can obtain the AVPlayerItem as it becomes the player's currentItem.
 */
+ (instancetype)playerBoxWithURL:(NSURL *)URL;

/*!
 @method        playerBoxWithAsset:
 @abstract		Returns an instance of WBSAVPlayerBox that plays a single audiovisual resource referenced by an asset.
 @param			asset
 @result		An instance of WBSAVPlayerBox
 @discussion	Implicitly creates an AVPlayerItem. Clients can obtain the AVPlayerItem as it becomes the player's currentItem.
 */
+ (instancetype)playerBoxWithAsset:(AVAsset *)asset;

/*!
 @method        initWithURL:
 @abstract		Returns an instance of WBSAVPlayerBox that plays a single audiovisual resource referenced by URL.
 @param			URL
 @result		An instance of WBSAVPlayerBox
 @discussion	Implicitly creates an AVPlayerItem. Clients can obtain the AVPlayerItem as it becomes the player's currentItem.
 */
- (instancetype)initWithURL:(NSURL *)URL;

/*!
 @method        initWithAsset:
 @abstract		Returns an instance of WBSAVPlayerBox that plays a single audiovisual resource referenced by an asset.
 @param			asset
 @result		An instance of WBSAVPlayerBox
 @discussion	Implicitly creates an AVPlayerItem. Clients can obtain the AVPlayerItem as it becomes the player's currentItem.
 */
- (instancetype)initWithAsset:(AVAsset *)asset;

- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)newSeekTime;

@end



@protocol WBSAVPlayerBoxDelegate <NSObject>
@optional
- (void)playerBox:(WBSAVPlayerBox *)playerBox readyToPlay:(BOOL)ready;
- (void)playerBox:(WBSAVPlayerBox *)playerBox playing:(BOOL)playing;
- (void)playerBox:(WBSAVPlayerBox *)playerBox didChangeCurrentItem:(AVPlayerItem *)playerItem;

@end
