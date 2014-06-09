//
//  WBSFantorangenEpisodeTableViewCell+WBSEpisode.m
//  Fantorangen
//
//  Created by Cameron Palmer on 01.05.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenEpisodeTableViewCell+WBSEpisode.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "WBSEpisode.h"



@implementation WBSFantorangenEpisodeTableViewCell (WBSEpisode)

- (void)setEpisode:(WBSEpisode *)episode visibility:(BOOL)isVisible
{
    NSString *episodeSummary = [NSString stringWithFormat:@"%@: %@", episode.episodeNumber, episode.summary];
    self.episodeSummaryLabel.text = episodeSummary;
    self.episodeTransmissionInformationLabel.text = episode.transmissionInformation;

    NSURL *posterURL = episode.posterURL;
    if (posterURL != nil && isVisible) {
        [self.episodePosterImageView setImageWithURL:posterURL];
    }
}

@end
