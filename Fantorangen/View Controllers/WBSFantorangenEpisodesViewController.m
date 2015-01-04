//
//  WBSFantorangenEpisodesViewController.m
//  Fantorangen
//
//  Created by Cameron Palmer on 04.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenEpisodesViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "WBSFantorangenEpisodeManager.h"
#import "WBSEpisode.h"
#import "WBSFantorangenEpisodesSectionTableViewCell.h"
#import "WBSFantorangenEpisodeTableViewCell.h"
#import "WBSFantorangenEpisodeViewController.h"
#import "NSArray+RandomOrder.h"

static NSString *const kFantorangenEpisodeViewControllerSegue = @"FantorangenEpisodeViewControllerSegue";



@interface WBSFantorangenEpisodesViewController () <WBSFantorangenEpisodeManagerDelegate>

@property (strong, nonatomic) WBSFantorangenEpisodeManager *episodeManager;

@property (strong, nonatomic) NSMutableDictionary *mutableEpisodeURLToEpisode;
@property (strong, nonatomic) NSMutableSet *reloadCellSet;

@property (strong, nonatomic, readonly) NSArray *seasons;
@property (strong, nonatomic, readonly) NSArray *episodes;

@end



@implementation WBSFantorangenEpisodesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    self.title = NSLocalizedString(@"Episodes", @"Episodes");
    
    WBSFantorangenEpisodeManager *episodeManager = [[WBSFantorangenEpisodeManager alloc] init];
    episodeManager.delegate = self;
    [episodeManager beginEpisodeUpdates];
    self.episodeManager = episodeManager;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kFantorangenEpisodeViewControllerSegue]) {
        WBSFantorangenEpisodeViewController *fantorangenEpisodeViewController = segue.destinationViewController;

        NSArray *episodeQueue = nil;
        if ([sender isKindOfClass:[WBSEpisode class]]) {
            WBSEpisode *episode = sender;
            episodeQueue = [self episodeQueueFromEpisode:episode randomized:NO];
        } else if ([sender isKindOfClass:[NSArray class]]) {
            episodeQueue = sender;
        }
        
        fantorangenEpisodeViewController.episodeQueue = episodeQueue;
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.episodes count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WBSFantorangenEpisodesSectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWBSFantorangenEpisodesSectionTableViewCellReuseIdentifier];
    
    WBSEpisode *episode = [self.episodes firstObject];
    
    cell.titleLabel.text = episode.seriesTitle;
    cell.seasonLabel.text = episode.season;
    [cell.posterImageView setImageWithURL:episode.posterURL];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFantorangenEpisodesTableViewCellReuseIdentifier];
    [self configureCell:cell withEpisode:[self episodeForIndexPath:indexPath]];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withEpisode:(WBSEpisode *)episode
{
    if ([cell isKindOfClass:[WBSFantorangenEpisodeTableViewCell class]]) {
        WBSFantorangenEpisodeTableViewCell *episodeCell = (WBSFantorangenEpisodeTableViewCell *)cell;
        [episodeCell updateCellWithEpisode:episode];
    }
}

- (WBSEpisode *)episodeForIndexPath:(NSIndexPath *)indexPath
{
    return self.episodes[indexPath.row];
}

- (NSIndexPath *)indexPathForEpisode:(WBSEpisode *)episode
{
    NSUInteger row = [self.episodes indexOfObject:episode];
    return [NSIndexPath indexPathForRow:row inSection:0];
}



#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldHighlightRow = NO;

    WBSEpisode *episode = [self.episodes objectAtIndex:indexPath.row];
    if (episode.availability == kWBSEpisodeAvailabilityAvailable) {
        shouldHighlightRow = YES;
    }
    
    return shouldHighlightRow;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WBSEpisode *episode = [self.episodes objectAtIndex:indexPath.row];
    if (episode.availability == kWBSEpisodeAvailabilityAvailable) {
        [self performSegueWithIdentifier:kFantorangenEpisodeViewControllerSegue sender:episode];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    WBSEpisode *episode = [self.episodes firstObject];
    
    WBSFantorangenEpisodesSectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kWBSFantorangenEpisodesSectionTableViewCellReuseIdentifier];
    cell.titleLabel.text = episode.seriesTitle;
    cell.seasonLabel.text = episode.season;
    [cell.posterImageView setImageWithURL:episode.posterURL];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WBSEpisode *episode = [self.episodes objectAtIndex:indexPath.row];
    
    WBSFantorangenEpisodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFantorangenEpisodesTableViewCellReuseIdentifier];
    [cell updateCellWithEpisode:episode];

    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));

    [cell setNeedsLayout];
    [cell layoutIfNeeded];

    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;    
}



#pragma mark - WBSFantorangenEpisodeManagerDelegate

- (void)episodeRefresh:(NSURL *)episodeURL
{
    WBSEpisode *episode = [self.episodeManager episodeForURL:episodeURL];

    BOOL isNewEpisode = NO;
    if (self.mutableEpisodeURLToEpisode[episodeURL] == nil) {
        isNewEpisode = YES;
    }
    self.mutableEpisodeURLToEpisode[episodeURL] = episode;

    NSIndexPath *indexPath = [self indexPathForEpisode:episode];

    [self.tableView beginUpdates];
    if (isNewEpisode) {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self configureCell:cell withEpisode:episode];
    }
    [self.tableView endUpdates];
//
//    static NSTimer *timer = nil;
//    if ([timer isValid]) {
//        [timer invalidate];
//    }
//
//    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(tableViewReloadData:) userInfo:nil repeats:NO];
}

- (void)tableViewReloadData:(id)sender
{
    [self.tableView reloadData];
}


#pragma mark - IBActions

- (IBAction)didPressShuffleButton:(id)sender
{
    NSArray *randomizedEpisodes = [[self episodes] randomOrder]
    ;
    [self performSegueWithIdentifier:kFantorangenEpisodeViewControllerSegue sender:randomizedEpisodes];
}



#pragma mark - Getters

- (NSMutableDictionary *)mutableEpisodeURLToEpisode
{
    if (_mutableEpisodeURLToEpisode == nil) {
        self.mutableEpisodeURLToEpisode = [[NSMutableDictionary alloc] init];
    }
    
    return _mutableEpisodeURLToEpisode;
}

- (NSArray *)seasons
{
    NSMutableSet *mutableSeasons = [[NSMutableSet alloc] init];
    for (WBSEpisode *episode in self.episodes) {
        [mutableSeasons addObject:episode.season];
    }
    
    NSArray *seasons = [[mutableSeasons allObjects] sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *season1 = obj1;
        NSString *season2 = obj2;
        return [season1 compare:season2 options:NSCaseInsensitiveSearch|NSNumericSearch];
    }];
    
    return seasons;
}

- (NSArray *)episodes
{
    NSArray *episodes = [[self.mutableEpisodeURLToEpisode allValues] sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
        WBSEpisode *episode1 = obj1;
        WBSEpisode *episode2 = obj2;
        return [episode1.episodeTitle compare:episode2.episodeTitle options:NSCaseInsensitiveSearch|NSNumericSearch];
    }];
    
    return episodes;
}

- (NSArray *)episodeQueueFromEpisode:(WBSEpisode *)episode randomized:(BOOL)shuffle
{
    NSArray *episodes = [self episodes];
    NSUInteger index = [episodes indexOfObject:episode];
    NSRange range = NSMakeRange(index, [episodes count] - index);
    return [episodes subarrayWithRange:range];
}

@end
