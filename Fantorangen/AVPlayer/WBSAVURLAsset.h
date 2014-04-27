//
//  WBSAVURLAsset.h
//  Fantorangen
//
//  Created by Cameron Palmer on 15.04.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

@import AVFoundation;

@protocol WBSAVURLAssetDelegate;



@interface WBSAVURLAsset : AVURLAsset
@property (weak, nonatomic) id <WBSAVURLAssetDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)URL;
- (void)load;

@end



@protocol WBSAVURLAssetDelegate <NSObject>
@optional
- (void)asset:(WBSAVURLAsset *)URLAsset didLoadURL:(NSURL *)URL;
- (void)asset:(WBSAVURLAsset *)URLAsset failedToLoadURL:(NSURL *)URL;

@end
