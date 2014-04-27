//
//  WBSAVURLAsset.m
//  Fantorangen
//
//  Created by Cameron Palmer on 15.04.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSAVURLAsset.h"

/* AVURLAsset keys */
NSString *const kAVURLAssetTracksKey = @"tracks";
NSString *const kAVURLAssetPlayableKey = @"playable";



@implementation WBSAVURLAsset

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super initWithURL:URL options:nil];
    if (self != nil) {
    }
    
    return self;
}

- (void)load
{
    NSArray *requestedKeys = @[kAVURLAssetTracksKey, kAVURLAssetPlayableKey];
    [self loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus status = [self statusOfValueForKey:kAVURLAssetPlayableKey error:&error];
        if (error != nil) {
            DDLogError(@"%@", error);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case AVKeyValueStatusUnknown:
                    DDLogVerbose(@"AVKeyValueStatusUnknown");
                    break;
                case AVKeyValueStatusLoading:
                    DDLogVerbose(@"AVKeyValueStatusLoading");
                    break;
                case AVKeyValueStatusLoaded:
                    [self assetLoaded];
                    break;
                case AVKeyValueStatusCancelled:
                    DDLogVerbose(@"AVKeyValueStatusCancelled");
                    break;
                case AVKeyValueStatusFailed:
                    [self assetFailedToLoad];
                    break;
            }
        });
    }];
}

- (void)assetLoaded
{
    DDLogVerbose(@"AVKeyValueStatusLoaded - %@", self);

    if ([self.delegate respondsToSelector:@selector(asset:didLoadURL:)]) {
        [self.delegate asset:self didLoadURL:self.URL];
    }
}

- (void)assetFailedToLoad
{
    DDLogError(@"AVKeyValueStatusFailed - %@", self);

    if ([self.delegate respondsToSelector:@selector(asset:failedToLoadURL:)]) {
        [self.delegate asset:self failedToLoadURL:self.URL];
    }
}

@end
