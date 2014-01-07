//
//  WBSFantorangenEpisodeManager.h
//  Fantorangen
//
//  Created by Cameron Palmer on 01.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBSEpisode;

@protocol WBSFantorangenEpisodeManagerDelegate;



@interface WBSFantorangenEpisodeManager : NSObject
@property (weak, nonatomic) id <WBSFantorangenEpisodeManagerDelegate> delegate;
@property (strong, nonatomic, readonly) NSArray *episodes;
@property (strong, nonatomic, readonly) NSDictionary *episodeURLToEpisode;

- (void)beginEpisodeUpdates;
- (WBSEpisode *)episodeForURL:(NSURL *)episodeURL;

@end



@protocol WBSFantorangenEpisodeManagerDelegate <NSObject>
@optional
- (void)episodeRefresh:(NSURL *)episodeURL;

@end

