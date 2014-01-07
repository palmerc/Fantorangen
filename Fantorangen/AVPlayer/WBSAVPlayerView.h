//
//  WBSAVPlayerView.h
//  Fantorangen
//
//  Created by Cameron Palmer on 02.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;



@interface WBSAVPlayerView : UIView

@property (nonatomic, retain) AVPlayer *player;

- (void)setPlayer:(AVPlayer *)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
