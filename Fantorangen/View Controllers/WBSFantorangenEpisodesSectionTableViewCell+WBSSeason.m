//
//  WBSFantorangenEpisodesSectionTableViewCell+WBSSeason.m
//  Fantorangen
//
//  Created by Cameron Palmer on 09.06.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenEpisodesSectionTableViewCell+WBSSeason.h"

#import "WBSSeason.h"



@implementation WBSFantorangenEpisodesSectionTableViewCell (WBSSeason)

- (void)setSeason:(WBSSeason *)season
{
    self.titleLabel.text = season.seriesTitle;
    self.seasonLabel.text = season.seasonDescription;
}

@end
