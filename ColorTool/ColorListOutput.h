//
//  ColorListOutput.h
//  ColorTool
//
//  Created by Steve Sparks on 1/9/15.
//  Copyright (c) 2015 SOG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString * ColorListOutputFormat;

extern NSString * const ColorListOutputFormatCLR;
extern NSString * const ColorListOutputFormatObjC;

@class ColorList;

@protocol ColorListOutput<NSObject>

- (instancetype)initWithOptions:(NSDictionary*)options directory:(NSString *)directory;
- (void)write:(ColorList *)colorList;

// For things like the ObjC writer, we need to change "some name" into "SomeName".
// That way your "BigCorp List"
+ (NSString *)modifiedNameForString:(NSString *)string;

@end

@interface ColorListOutput : NSObject

+ (NSObject<ColorListOutput> *)outputForFormat:(ColorListOutputFormat)format options:(NSDictionary*)options directory:(NSString *)directory;

+ (void)registerClass:(Class)class forFormat:(ColorListOutputFormat)format;

@end

