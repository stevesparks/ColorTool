//
//  ColorListInput.m
//  ColorTool
//
//  Created by Steve Sparks on 1/10/15.
//  Copyright (c) 2015 SOG. All rights reserved.
//

#import "ColorListInput.h"
#import <Foundation/Foundation.h>

@implementation ColorListInput

NSString * const ColorListInputFormatJSON = @"json";
NSString * const ColorListInputFormatUnknown = nil;


static NSMutableDictionary *ColorListInputs;

+ (NSMutableDictionary*)inputs {
    if(!ColorListInputs) {
        ColorListInputs = [[NSMutableDictionary alloc] init];
    }
    return ColorListInputs;
}

+ (NSObject<ColorListInput> *)inputForFormat:(ColorListInputFormat)format {
    Class cls = [[self inputs] objectForKey:format];
    return [[cls alloc] init];
}

+ (void)registerClass:(Class)class forFormat:(ColorListInputFormat)format {
    if([class conformsToProtocol:@protocol(ColorListInput)] && format) {
        [[self inputs] setObject:class forKey:format];
        NSLog(@"Input registering %@ => %@", format, NSStringFromClass(class));
    }
}

@end