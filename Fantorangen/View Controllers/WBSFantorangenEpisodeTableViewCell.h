//
//  WBSFantorangenEpisodeTableViewCell.h
//  Fantorangen
//
//  Created by Cameron Palmer on 04.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

@import UIKit;

@class WBSEpisode;

extern NSString *const kFantorangenEpisodesTableViewCellReuseIdentifier;



@interface WBSFantorangenEpisodeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *episodePosterImageView;
@property (weak, nonatomic) IBOutlet UILabel *episodeSummaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeTransmissionInformationLabel;

+ (UIFont *)episodeSummaryLabelFont;
+ (UIFont *)episodeTransmissionInformationLabelFont;

@end
