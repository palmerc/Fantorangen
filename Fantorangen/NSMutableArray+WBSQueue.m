//
//  NSMutableArray+WBSQueue.m
//  Fantorangen
//
//  Created by Cameron Palmer on 01.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "NSMutableArray+WBSQueue.h"



@implementation NSMutableArray (WBSFIFOQueue)

- (void)enqueue:(id)object
{
    [self addObject:object];
}

- (id)dequeue
{
    id object = nil;
    if ([self count] > 0) {
        object = [self objectAtIndex:0];
        [self removeObjectAtIndex:0];
    }
    
    return object;
}

@end
