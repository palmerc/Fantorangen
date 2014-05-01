//
//  WBSFantorangenEpisodeManager.m
//  Fantorangen
//
//  Created by Cameron Palmer on 01.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSFantorangenEpisodeManager.h"

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <hpple/TFHpple.h>

#import "WBSEpisode.h"
#import "WBSFantorangenWebViewOperation.h"

static NSString *const kNRKBaseURLString = @"http://tv.nrk.no";
static NSString *const kFantorangenSeries = @"/serie/fantorangen";
static NSString *const kClientUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/11B554a";



@interface WBSFantorangenEpisodeManager () <WBSWebViewOperationDelegate>
@property (strong, nonatomic, readonly) NSURL *NRKTVURL;

@property (strong, nonatomic) NSSet *uniqueEpisodes;

@property (strong, nonatomic) AFHTTPRequestOperationManager *requestOperationManager;

@end



@implementation WBSFantorangenEpisodeManager

- (id)init
{
    self = [super init];
    if (self != nil) {
        _NRKTVURL = [NSURL URLWithString:kNRKBaseURLString];
        
        AFHTTPRequestOperationManager *requestOperationManager = [AFHTTPRequestOperationManager manager];
        
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:kClientUserAgent forHTTPHeaderField:@"User-Agent"];
        requestOperationManager.requestSerializer = requestSerializer;
        
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        requestOperationManager.responseSerializer = responseSerializer;
        self.requestOperationManager = requestOperationManager;
    }
    
    return self;
}

- (void)setDelegate:(id<WBSFantorangenEpisodeManagerDelegate>)delegate
{
    _delegate = delegate;

    [self unarchiveEpisodeData];
    [self beginEpisodeUpdates];
}

- (void)beginEpisodeUpdates
{
    NSURL *fantorangenURL = [NSURL URLWithString:[kNRKBaseURLString stringByAppendingString:kFantorangenSeries]];
    [self.requestOperationManager GET:[fantorangenURL absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSData *HTMLData = responseObject;
            TFHpple *document = [[TFHpple alloc] initWithHTMLData:HTMLData];
            NSArray *elements = [document searchWithXPathQuery:@"//a[contains(@class, 'season-link') and contains(@class, 'buttonbar-link')]"];
            
            [self processSeasonElements:elements];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)processSeasonElements:(NSArray *)elements
{
    for (TFHppleElement *element in elements) {
        NSString *episodesLink = [element objectForKey:@"href"];
        NSURL *FantorangenEpisodesURL = [NSURL URLWithString:[kNRKBaseURLString stringByAppendingString:episodesLink]];
        [self.requestOperationManager GET:[FantorangenEpisodesURL absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSData class]]) {
                NSData *HTMLData = responseObject;
                TFHpple *document = [[TFHpple alloc] initWithHTMLData:HTMLData];
                NSArray *episodeElements = [document searchWithXPathQuery:@"//ul[contains(@class, 'episode-list')]/li[contains(@class, 'episode-item')]"];
                for (TFHppleElement *episodeElement in episodeElements) {
                    NSDictionary *attributes = [episodeElement attributes];
                    NSString *episodeIdentifier = [attributes objectForKey:@"data-episode"];
                    TFHppleElement *episodeLinkTag = [episodeElement firstChildWithTagName:@"a"];
                    TFHppleElement *airElement = [episodeLinkTag firstChildWithClassName:@"air"];

                    TFHppleElement *headingElement = [airElement firstChildWithClassName:@"episode-list-title"];
                    NSString *title = [headingElement text];

                    TFHppleElement *seasonTag = [[headingElement childrenWithClassName:@"season-name"] firstObject];
                    NSString *episodeRelativeURLString = [episodeLinkTag objectForKey:@"href"];
                    
                    NSRange episodeNumberStartRange = [title rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet] options:0];
                    NSRange episodeNumberEndRange = [title rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"] options:0];
                    NSInteger length = episodeNumberEndRange.location - episodeNumberStartRange.location;
                    NSRange episodeNumberRange = NSMakeRange(episodeNumberStartRange.location, length);
                    
                    NSString *episodeNumber = [title substringWithRange:episodeNumberRange];
                    
                    NSRange seriesTitleRange = NSMakeRange(0, episodeNumberStartRange.location);
                    NSString *seriesTitle = [[title substringWithRange:seriesTitleRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    NSString *season = [[seasonTag text] stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
                    
                    NSArray *descriptionElements = [[airElement firstChildWithClassName:@"description"] children];
                    NSMutableArray *descriptionComponents = [[NSMutableArray alloc] initWithCapacity:[descriptionElements count]];
                    
                    for (TFHppleElement *descriptionElement in descriptionElements) {
                        [descriptionComponents addObject:[descriptionElement text]];
                    }
                    NSString *description = [descriptionComponents componentsJoinedByString:@" "];
                    
                    NSArray *divs = [airElement childrenWithTagName:@"div"];
                    NSString *transmissionInformation = nil;
                    WBSEpisodeAvailability availability = kWBSEpisodeAvailabilityUnavailable;
                    for (TFHppleElement *div in divs) {
                        NSString *class = [[div attributes] objectForKey:@"class"];
                        
                        if ([class rangeOfString:@"transmission-info"].location != NSNotFound) {
                            transmissionInformation = [div text];
                        } else if ([class rangeOfString:@"availability"].location != NSNotFound) {
                            if ([[div text] isEqualToString:@"Alltid på nett"]) {
                                availability = kWBSEpisodeAvailabilityAvailable;
                            }
                        }
                    }
                    
                    WBSEpisode *episode = [[WBSEpisode alloc] init];
                    episode.identifier = episodeIdentifier;
                    episode.episodeURL = [NSURL URLWithString:episodeRelativeURLString relativeToURL:self.NRKTVURL];
                    episode.season = season;
                    episode.episodeNumber = episodeNumber;
                    episode.seriesTitle = seriesTitle;
                    episode.episodeTitle = title;
                    episode.summary = description;
                    episode.transmissionInformation = transmissionInformation;
                    episode.availability = availability;
                    
                    [self addEpisode:episode];
                }
                
                [self fetchVideoURLs];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

- (void)fetchVideoURLs
{
    NSOperationQueue *operationQueue = [NSOperationQueue mainQueue];
    for (WBSEpisode *episode in self.episodes) {
        WBSFantorangenWebViewOperation *webViewOperation = [[WBSFantorangenWebViewOperation alloc] initWithURL:episode.episodeURL];
        webViewOperation.delegate = self;
        [operationQueue addOperation:webViewOperation];
    }

    [self archiveEpisodeData];
}



#pragma mark - WBSWebViewOperationDelegate methods 

- (void)webViewOperationDidFinish:(WBSFantorangenWebViewOperation *)webViewOperation
{
    WBSEpisode *episode = [self episodeForURL:webViewOperation.episodeURL];
    episode.videoURL = webViewOperation.videoURL;
    episode.posterURL = webViewOperation.posterURL;

    if ([self.delegate respondsToSelector:@selector(episodeRefresh:)]) {
        [self.delegate episodeRefresh:episode];
    }
}


#pragma mark - 

- (void)archiveEpisodeData
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSData *serializedEpisodeData = [NSKeyedArchiver archivedDataWithRootObject:self.episodes];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *episodesArchiveURL = [self episodesArchiveURL];

        NSError *error = nil;
        [serializedEpisodeData writeToFile:[episodesArchiveURL path] options:NSDataWritingFileProtectionNone error:&error];
        if (error != nil) {
            DDLogError(@"%@", error);
        }
    });
}

- (void)unarchiveEpisodeData
{
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *episodeData = [NSData dataWithContentsOfURL:[self episodesArchiveURL]];
        if (episodeData != nil) {
            NSArray *episodes = [NSKeyedUnarchiver unarchiveObjectWithData:episodeData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addEpisodes:episodes];
            });
        }
    });
}



#pragma mark - Getters

- (void)addEpisode:(WBSEpisode *)episode
{
    if (episode.episodeURL != nil) {
        self.uniqueEpisodes = [self.uniqueEpisodes setByAddingObject:episode];

        if ([self.delegate respondsToSelector:@selector(episodeRefresh:)]) {
            [self.delegate episodeRefresh:episode];
        }
    }
}

- (void)addEpisodes:(NSArray *)episodes
{
    for (WBSEpisode *episode in episodes) {
        [self addEpisode:episode];
    }
}

- (NSSet *)uniqueEpisodes
{
    if (_uniqueEpisodes == nil) {
        _uniqueEpisodes = [NSSet set];
    }

    return _uniqueEpisodes;
}

- (NSArray *)episodes
{
    return [self.uniqueEpisodes allObjects];
}

- (WBSEpisode *)episodeForURL:(NSURL *)episodeURL
{
    WBSEpisode *matchingEpisode = nil;
    for (WBSEpisode *episode in self.episodes) {
        if ([episode.episodeURL isEqual:episodeURL]) {
            matchingEpisode = episode;
        }
    }

    return matchingEpisode;
}

- (NSURL *)episodesArchiveURL
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [directories firstObject];
    NSURL *libraryURL = [NSURL fileURLWithPath:libraryPath];
    NSURL *episodesFolderURL = [libraryURL URLByAppendingPathComponent:@"episodes" isDirectory:YES];

    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:episodesFolderURL withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        DDLogError(@"%@", error);
    }

    NSURL *episodesArchiveURL =[episodesFolderURL URLByAppendingPathComponent:@"episodes.archive" isDirectory:NO];

    return episodesArchiveURL;
}

@end
