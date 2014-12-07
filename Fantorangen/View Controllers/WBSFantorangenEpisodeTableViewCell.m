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

static CGFloat kCellPadding = 8.0f;
static CGFloat kEpisodeSummaryLabelWidth = 267.0f;
static CGFloat kEpisodeTransmissionInformationLabelWidth = 304.0f;



@interface WBSFantorangenEpisodeTableViewCell ()
+ (UIFont *)episodeSummaryLabelFont;
+ (UIFont *)episodeTransmissionInformationLabelFont;

@end



@implementation WBSFantorangenEpisodeTableViewCell

- (void)setEpisode:(WBSEpisode *)episode
{
    _episode = episode;
    
    self.episodeNumberLabel.text = episode.episodeNumber;
    self.episodeSummaryLabel.text = episode.summary;

    NSURLRequest *preflightRequest = [[NSURLRequest alloc] initWithURL:episode.videoURL];
    if (episode.availability == kWBSEpisodeAvailabilityAvailable &&
        [NSURLConnection canHandleRequest:preflightRequest]) {
        self.episodeTransmissionInformationLabel.text = episode.transmissionInformation;
    } else {
        self.episodeTransmissionInformationLabel.text = NSLocalizedString(@"NOT_AVAILABLE", @"Ikke tilgjengelig akkurat nå");
    }
}



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

+ (UIFont *)episodeSummaryLabelFont
{
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *)episodeTransmissionInformationLabelFont
{
    return [UIFont systemFontOfSize:10.0f];
}

@end
