//
//  ColorListInput.h
//  ColorTool
//
//  Created by Steve Sparks on 1/9/15.
//  Copyright (c) 2015 SOG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * ColorListInputFormat;

extern NSString * const ColorListInputFormatJSON;
extern NSString * const ColorListInputFormatUnknown;

@class ColorList;

@protocol ColorListInput <NSObject>

// If you've already got an object...
- (ColorList *)populateColorList:(ColorList *)list fromFile:(NSString *)path;

- (ColorList *)readFromFile:(NSString *)path;

@end

@interface ColorListInput : NSObject

+ (NSObject<ColorListInput> *)inputForFormat:(ColorListInputFormat)format;

+ (void)registerClass:(Class)class forFormat:(ColorListInputFormat)format;

@end

