//
//  ColorListJSONInput.m
//  ColorTool
//
//  Created by Steve Sparks on 1/9/15.
//  Copyright (c) 2015 SOG. All rights reserved.
//

#import "ColorListJSONInput.h"
#import <AppKit/AppKit.h>
#import "ColorList.h"

void SKScanHexColor(NSString * hexString, float * red, float * green, float * blue, float * alpha) {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }

    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];

    if (red) { *red = ((baseValue >> 24) & 0xFF)/255.0f; }
    if (green) { *green = ((baseValue >> 16) & 0xFF)/255.0f; }
    if (blue) { *blue = ((baseValue >> 8) & 0xFF)/255.0f; }
    if (alpha) { *alpha = ((baseValue >> 0) & 0xFF)/255.0f; }
}

NSColor * SKColorFromHexString(NSString * hexString) {
    float red, green, blue, alpha;
    SKScanHexColor(hexString, &red, &green, &blue, &alpha);

    return [NSColor colorWithRed:red green:green blue:blue alpha:alpha];
}


@implementation ColorListJSONInput

+ (void)load {
    [ColorListInput registerClass:[self class] forFormat:ColorListInputFormatJSON];
}

- (NSColor *)colorFromDict:(NSDictionary*)dict {
    // Convert HEX -> NSColor
    NSString *colorHex = dict[@"hex"];
    if(colorHex)
        return SKColorFromHexString(colorHex);

    // Convert RGB -> NSColor
    NSNumber *colorRed = dict[@"red"];
    NSNumber *colorGreen = dict[@"green"];
    NSNumber *colorBlue = dict[@"blue"];
    if(colorRed && colorGreen && colorBlue) {
        return [NSColor colorWithRed:colorRed.doubleValue green:colorGreen.doubleValue blue:colorBlue.doubleValue alpha:1.0];
    }

    return nil;
}

- (ColorList *)readFromFile:(NSString *)path {
    ColorList *newList = [[ColorList alloc] init];
    return [self populateColorList:newList fromFile:path];
}

- (ColorList *)populateColorList:(ColorList *)list fromFile:(NSString *)path {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if(!data) return nil;

    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    NSString *name = dict[@"name"];
    if(!name) {
        NSLog(@"Did not detect a color name.");
        return nil;
    }
    list.name = name;

    NSDictionary *outputs = dict[@"output"];
    list.outputDict = outputs;

    NSArray *colors = dict[@"colors"];
    if(!colors.count) {
        NSLog(@"Warning! List spec '%@' has no colors", name);
    }

    NSMutableDictionary *colorsDict = [[NSMutableDictionary alloc] init];
    for(NSDictionary *colorDict in colors) {
        NSString *colorName = colorDict[@"name"];
        NSColor *color = [self colorFromDict:colorDict];
        if(color) {
            NSLog(@"  %@  ->  %@", colorName, color);
            [colorsDict setObject:color forKey:colorName];
        }
    }
    list.colors = [colorsDict copy];

    return list;
}


@end
