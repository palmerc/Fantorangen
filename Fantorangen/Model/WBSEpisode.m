//
//  WBSEpisode.m
//  Fantorangen
//
//  Created by Cameron Palmer on 31.12.13.
//  Copyright (c) 2013 Wolf and Bear Studios. All rights reserved.
//

#import "WBSEpisode.h"



@implementation WBSEpisode

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil) {
        _identifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(identifier))];
        _season = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(season))];
        _episodeNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(episodeNumber))];
        _seriesTitle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(seriesTitle))];
        _episodeTitle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(episodeTitle))];
        _summary = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(summary))];
        _episodeURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(episodeURL))];
        _videoURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(videoURL))];
        _posterURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(posterURL))];
        _transmissionInformation = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(transmissionInformation))];
        _availability = (WBSEpisodeAvailability)[aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(availability))];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:self.season forKey:NSStringFromSelector(@selector(season))];
    [aCoder encodeObject:self.episodeNumber forKey:NSStringFromSelector(@selector(episodeNumber))];
    [aCoder encodeObject:self.seriesTitle forKey:NSStringFromSelector(@selector(seriesTitle))];
    [aCoder encodeObject:self.episodeTitle forKey:NSStringFromSelector(@selector(episodeTitle))];
    [aCoder encodeObject:self.summary forKey:NSStringFromSelector(@selector(summary))];
    [aCoder encodeObject:self.episodeURL forKey:NSStringFromSelector(@selector(episodeURL))];
    [aCoder encodeObject:self.videoURL forKey:NSStringFromSelector(@selector(videoURL))];
    [aCoder encodeObject:self.posterURL forKey:NSStringFromSelector(@selector(posterURL))];
    [aCoder encodeObject:self.transmissionInformation forKey:NSStringFromSelector(@selector(transmissionInformation))];
    [aCoder encodeInteger:self.availability forKey:NSStringFromSelector(@selector(availability))];
}

@end
