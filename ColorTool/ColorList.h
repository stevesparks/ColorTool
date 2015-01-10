//
//  ColorList.h
//  ColorTool
//
//  Created by Steve Sparks on 1/9/15.
//  Copyright (c) 2015 SOG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ColorListInput.h"
#import "ColorListOutput.h"

@interface ColorList : NSObject

- (instancetype)initWithContentsOfFile:(NSString*)fileName format:(ColorListInputFormat)inputFormat;

- (void)write;

@property (nonatomic) NSString *name;
@property (nonatomic) NSDictionary *colors;
@property (nonatomic) NSDictionary *outputDict;

@end
