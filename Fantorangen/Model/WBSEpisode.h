//
//  WBSEpisode.h
//  Fantorangen
//
//  Created by Cameron Palmer on 31.12.13.
//  Copyright (c) 2013 Wolf and Bear Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kWBSEpisodeAvailabilityAvailable,
    kWBSEpisodeAvailabilityUnavailable
} WBSEpisodeAvailability;



@interface WBSEpisode : NSObject

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) NSURL *episodeURL;
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) NSString *transmissionInformation;
@property (assign, nonatomic) WBSEpisodeAvailability availability;

@end
