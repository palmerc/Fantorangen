//
//  NSArray+RandomOrder.m
//  Fantorangen
//
//  Created by Cameron Palmer on 07.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "NSArray+RandomOrder.h"



@implementation NSArray (RandomOrder)

- (NSArray *)randomOrder
{
    NSMutableArray *mutableRandom = [self mutableCopy];
    for (int i = 0; i < [self count]; i++) {
        int n = arc4random() % ([self count] - 1);
        [mutableRandom exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return [mutableRandom copy];
}

@end
