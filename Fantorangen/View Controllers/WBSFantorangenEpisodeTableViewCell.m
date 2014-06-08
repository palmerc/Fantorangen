//
//  WBSFantorangenEpisodeTableViewCell.m
//  Fantorangen
//
//  Created by Cameron Palmer on 04.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenEpisodeTableViewCell.h"

#import "WBSEpisode.h"

NSString *const kFantorangenEpisodesTableViewCellReuseIdentifier = @"FantorangenEpisodesTableViewCellReuseIdentifier";



@interface WBSFantorangenEpisodeTableViewCell ()
@end



@implementation WBSFantorangenEpisodeTableViewCell

+ (UIFont *)episodeSummaryLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
}

+ (UIFont *)episodeTransmissionInformationLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f];
}

@end
