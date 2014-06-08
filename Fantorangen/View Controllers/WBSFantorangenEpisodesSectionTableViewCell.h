//
//  WBSFantorangenEpisodesSectionTableViewCell.h
//  Fantorangen
//
//  Created by Cameron Palmer on 06.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kWBSFantorangenEpisodesSectionTableViewCellReuseIdentifier;



@interface WBSFantorangenEpisodesSectionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;

@end
