//
//  ColorListOutput.m
//  ColorTool
//
//  Created by Steve Sparks on 1/9/15.
//  Copyright (c) 2015 SOG. All rights reserved.
//

#import "ColorListOutput.h"
#import "ColorListCLROutput.h"
#import "ColorListObjcOutput.h"

NSString * const ColorListOutputFormatCLR = @"clr";
NSString * const ColorListOutputFormatObjC = @"objc";

@implementation ColorListOutput

static NSMutableDictionary *ColorListOutputs;

+ (NSMutableDictionary*)outputs {
    if(!ColorListOutputs) {
        ColorListOutputs = [[NSMutableDictionary alloc] init];
    }
    return ColorListOutputs;
}

+ (NSObject<ColorListOutput> *)outputForFormat:(ColorListOutputFormat)format options:(NSDictionary *)options directory:(NSString *)directory {

    Class cls = [[self outputs] objectForKey:format];

    return [[cls alloc] initWithOptions:options directory:directory];
}

+ (void)registerClass:(Class)class forFormat:(ColorListOutputFormat)format {
    if([class conformsToProtocol:@protocol(ColorListOutput)] && format) {
        [[self outputs] setObject:class forKey:format];
        NSLog(@"Output registering %@ => %@", format, NSStringFromClass(class));
    }
}

@end
