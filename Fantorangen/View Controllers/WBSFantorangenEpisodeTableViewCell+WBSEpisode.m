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

static CGFloat kCellPadding = 8.0f;
static CGFloat kEpisodeSummaryLabelWidth = 267.0f;
static CGFloat kEpisodeTransmissionInformationLabelWidth = 304.0f;



@implementation WBSFantorangenEpisodeTableViewCell (WBSEpisode)

+ (CGFloat)heightForCellWithEpisode:(WBSEpisode *)episode
{
    CGFloat summaryLabelHeight = [[self class] heightForSummaryWithString:episode.summary];
    CGFloat transmissionInformationLabelHeight = [[self class] heightForTransmissionInformationWithString:episode.transmissionInformation];

    return summaryLabelHeight + transmissionInformationLabelHeight + 3.0f * kCellPadding;
}

+ (CGFloat)heightForSummaryWithString:(NSString *)summary
{
    NSDictionary *summaryAttributes = @{NSFontAttributeName: [[self class] episodeSummaryLabelFont]};
    CGRect summaryRect = [summary boundingRectWithSize:CGSizeMake(kEpisodeSummaryLabelWidth, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:summaryAttributes
                                               context:nil];

    return ceilf(summaryRect.size.height);
}

+ (CGFloat)heightForTransmissionInformationWithString:(NSString *)transmissionInformation
{
    NSDictionary *transmissionInformationAttributes = @{NSFontAttributeName: [[self class] episodeTransmissionInformationLabelFont]};
    CGRect transmissionInformationRect = [transmissionInformation boundingRectWithSize:CGSizeMake(kEpisodeTransmissionInformationLabelWidth, MAXFLOAT)
                                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                                            attributes:transmissionInformationAttributes
                                                                               context:nil];
    return ceilf(transmissionInformationRect.size.height);
}

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
