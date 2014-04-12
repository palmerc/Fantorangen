//
//  WBSAVPlayerBox.h
//  Fantorangen
//
//  Created by Cameron Palmer on 27.03.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@protocol WBSAVPlayerBoxDelegate;



@interface WBSAVPlayerBox : NSObject
@property (weak, nonatomic) id <WBSAVPlayerBoxDelegate> delegate;

@property (strong, nonatomic, readonly) AVPlayer *player;
@property (assign, nonatomic, readonly) NSTimeInterval currentTime;

/*!
 @method        playerBoxWithURL:
 @abstract		Returns an instance of WBSAVPlayerBox that plays a single audiovisual resource referenced by URL.
 @param			URL
 @result		An instance of WBSAVPlayerBox
 @discussion	Implicitly creates an AVPlayerItem. Clients can obtain the AVPlayerItem as it becomes the player's currentItem.
 */
+ (instancetype)playerBoxWithURL:(NSURL *)URL;

/*!
 @method        initWithURL:
 @abstract		Returns an instance of WBSAVPlayerBox that plays a single audiovisual resource referenced by URL.
 @param			URL
 @result		An instance of WBSAVPlayerBox
 @discussion	Implicitly creates an AVPlayerItem. Clients can obtain the AVPlayerItem as it becomes the player's currentItem.
 */
- (instancetype)initWithURL:(NSURL *)URL;

@end



@protocol WBSAVPlayerBoxDelegate <NSObject>
@optional
- (void)player:(AVPlayer *)player didChangeRate:(CGFloat)rate;
- (void)player:(AVPlayer *)player didChangeCurrentItem:(AVPlayerItem *)playerItem;

@end
