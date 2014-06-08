//
//  WBSEpisodeStorageManager.h
//  Fantorangen
//
//  Created by Cameron Palmer on 08.06.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBSSeason;
@class WBSEpisode;



@interface WBSProgramStorage : NSObject

@property (strong, nonatomic, readonly) NSArray *seasons;
@property (strong, nonatomic, readonly) NSArray *episodes;

- (NSArray *)episodesForSeason:(WBSSeason *)season;

- (void)addEpisode:(WBSEpisode *)episode;
- (void)addEpisodes:(NSArray *)episodes;

@end
