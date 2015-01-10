//
//  main.m
//  ColorTool
//
//  Created by Steve Sparks on 1/9/15.
//  Copyright (c) 2015 SOG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "ColorList.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *fileName = @"samplecolors.json";
        if(argc>1) {
            fileName = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        }
        NSLog(@"Opening %@...", fileName);

        ColorList *list = [[ColorList alloc] initWithContentsOfFile:fileName format:ColorListInputFormatJSON];
        [list write];
    }
    return 0;
}

