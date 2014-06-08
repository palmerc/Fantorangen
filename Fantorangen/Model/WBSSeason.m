//
//  WBSSeason.m
//  Fantorangen
//
//  Created by Cameron Palmer on 08.06.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "WBSSeason.h"



@implementation WBSSeason

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil) {
        _identifier = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(identifier))];
        _seasonDescription = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(seasonDescription))];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:NSStringFromSelector(@selector(identifier))];
    [aCoder encodeObject:self.seasonDescription forKey:NSStringFromSelector(@selector(seasonDescription))];
}



#pragma mark - Equality

- (NSUInteger)hash
{
    return [self.identifier hash];
}

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = NO;
    if (object && [object isKindOfClass:[WBSSeason class]]) {
        WBSSeason *season = object;
        isEqual = [self isEqualToSeason:season];
    }

    return isEqual;
}

- (BOOL)isEqualToSeason:(WBSSeason *)season
{
    BOOL isEqual = NO;
    if (season) {
        isEqual = [self.identifier isEqualToString:season.identifier];
    }

    return isEqual;
}
@end
