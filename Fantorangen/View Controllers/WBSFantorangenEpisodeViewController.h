//
//  WBSViewController.h
//  Fantorangen
//
//  Created by Cameron Palmer on 31.12.13.
//  Copyright (c) 2013 Wolf and Bear Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WBSAVPlayerViewController.h"



@interface WBSFantorangenEpisodeViewController : UIViewController <WBSAVPlayerViewControllerDelegate>

@property (weak, nonatomic) NSArray *episodeQueue;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end
