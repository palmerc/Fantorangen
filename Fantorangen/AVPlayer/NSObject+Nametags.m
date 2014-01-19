//
//  NSObject+Nametags.m
//  Fantorangen
//
//  Created by Cameron Palmer on 14.01.14.
//  Copyright (c) 2014 Wolf and Bear Studios. All rights reserved.
//

#import "NSObject+Nametags.h"

#import <objc/runtime.h>



@implementation NSObject (Nametags)

- (id)nametag
{
    return objc_getAssociatedObject(self, @selector(nametag));
}

- (void)setNametag:(NSString *)aNametag
{
    objc_setAssociatedObject(self, @selector(nametag), aNametag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)objectIdentifier
{
    return [NSString stringWithFormat:@"<%@: 0x%0x>", self.nametag, (int)self];
}

@end
