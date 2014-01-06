//
//  WBSFantorangenEpisodeTableViewCell.h
//  Fantorangen
//
//  Created by Cameron Palmer on 04.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WBSEpisode;

extern NSString *const kFantorangenEpisodesTableViewCellReuseIdentifier;



@interface WBSFantorangenEpisodeTableViewCell : UITableViewCell

@property (weak, nonatomic) WBSEpisode *episode;

@property (weak, nonatomic) IBOutlet UIView *episodeTitleDescriptionContainerView;
@property (weak, nonatomic) IBOutlet UILabel *episodeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeSummaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeTransmissionInformationLabel;

+ (CGFloat)heightForCellWithEpisode:(WBSEpisode *)episode;

@end
