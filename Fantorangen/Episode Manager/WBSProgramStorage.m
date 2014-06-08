//
//  WBSEpisodeStorageManager.m
//  Fantorangen
//
//  Created by Cameron Palmer on 08.06.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSProgramStorage.h"

#import "WBSEpisode.h"
#import "WBSSeason.h"



@interface WBSProgramStorage ()
@property (strong, nonatomic) NSMapTable *seasonsToEpisodes;

@end



@implementation WBSProgramStorage

- (NSArray *)seasons
{
    @synchronized(self.seasonsToEpisodes) {
        NSMutableArray *mutableSeasons = [[NSMutableArray alloc] initWithCapacity:[self.seasonsToEpisodes count]];
        for (WBSSeason *season in [self.seasonsToEpisodes keyEnumerator]) {
            [mutableSeasons addObject:season];
        }

        NSArray *seasons = [mutableSeasons sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            WBSSeason *season1 = obj1;
            WBSSeason *season2 = obj2;

            return [season1.identifier compare:season2.identifier options:NSCaseInsensitiveSearch|NSNumericSearch];
        }];

        return seasons;
    }
}

- (NSArray *)episodesForSeason:(WBSSeason *)season
{
    @synchronized(self.seasonsToEpisodes) {
        NSSet *episodeSet = [self.seasonsToEpisodes objectForKey:season];
        NSArray *episodes = [[episodeSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            WBSEpisode *episode1 = obj1;
            WBSEpisode *episode2 = obj2;

            return [episode1.identifier compare:episode2.identifier options:NSCaseInsensitiveSearch|NSNumericSearch];
        }];
        
        return episodes;
    }
}

- (void)addEpisode:(WBSEpisode *)episode
{
    WBSSeason *season = episode.season;

    @synchronized(self.seasonsToEpisodes) {
        NSSet *episodes = [self.seasonsToEpisodes objectForKey:season];
        if (episodes == nil) {
            episodes = [NSSet setWithObject:episode];
        } else {
            episodes = [episodes setByAddingObject:episode];
        }

        [self.seasonsToEpisodes setObject:episodes forKey:season];
    }
}

- (void)addEpisodes:(NSArray *)episodes
{
    for (WBSEpisode *episode in episodes) {
        [self addEpisode:episode];
    }
}

- (NSMapTable *)seasonsToEpisodes
{
    if (_seasonsToEpisodes == nil) {
        self.seasonsToEpisodes = [NSMapTable strongToStrongObjectsMapTable];
    }

    return _seasonsToEpisodes;
}

@end
