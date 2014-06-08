//
//  WBSEpisode.h
//  Fantorangen
//
//  Created by Cameron Palmer on 31.12.13.
//  Copyright (c) 2013 Wolf and Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBSSeason;

typedef NS_ENUM(NSInteger, WBSEpisodeAvailability) {
    kWBSEpisodeAvailabilityAvailable,
    kWBSEpisodeAvailabilityUnavailable
};



@interface WBSEpisode : NSObject <NSCoding>

@property (copy, nonatomic) NSString *identifier;
@property (strong, nonatomic) WBSSeason *season;
@property (copy, nonatomic) NSString *episodeNumber;
@property (copy, nonatomic) NSString *seriesTitle;
@property (copy, nonatomic) NSString *episodeTitle;
@property (copy, nonatomic) NSString *summary;
@property (copy, nonatomic) NSURL *episodeURL;
@property (copy, nonatomic) NSURL *videoURL;
@property (copy, nonatomic) NSURL *posterURL;
@property (copy, nonatomic) NSString *transmissionInformation;
@property (assign, nonatomic) WBSEpisodeAvailability availability;

- (void)updateWithEpisode:(WBSEpisode *)episode;

@end
