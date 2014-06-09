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
@property (strong, nonatomic, readonly) NSURL *archiveURL;
@property (strong, nonatomic) NSMapTable *seasonsToEpisodes;

@end



@implementation WBSProgramStorage

- (void)dealloc
{
    [NSKeyedArchiver archiveRootObject:self.seasonsToEpisodes toFile:[self.archiveURL path]];
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _seasonsToEpisodes = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.archiveURL path]];
    }

    return self;
}

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

- (NSArray *)episodes
{
    @synchronized(self.seasonsToEpisodes) {
        NSMutableArray *mutableEpisodes = [[NSMutableArray alloc] init];
        for (NSSet *episodes in [self.seasonsToEpisodes objectEnumerator]) {
            [mutableEpisodes addObjectsFromArray:[episodes allObjects]];
        }

        NSArray *episodes = [mutableEpisodes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            WBSEpisode *episode1 = obj1;
            WBSEpisode *episode2 = obj2;

            NSComparisonResult episodeComparison = [episode1.season.identifier compare:episode2.season.identifier options:NSCaseInsensitiveSearch|NSNumericSearch];
            if (episodeComparison == NSOrderedSame) {
                episodeComparison = [episode1.identifier compare:episode2.identifier options:NSCaseInsensitiveSearch|NSNumericSearch];
            }

            return episodeComparison;
        }];

        return episodes;
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
            if ([episodes containsObject:episode]) {
                WBSEpisode *existingEpisode = [episodes member:episode];
                [existingEpisode updateWithEpisode:episode];
            } else {
                episodes = [episodes setByAddingObject:episode];
            }
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

- (NSURL *)archiveURL
{
    NSError *error = nil;
    NSURL *cachesURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (error != nil) {
        DDLogError(@"%@", error);
    }

    NSURL *fileURL = [cachesURL URLByAppendingPathComponent:@"ProgramStorage.cache"];

    return fileURL;
}

@end
