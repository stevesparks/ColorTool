//
//  ColorListCLROutput.m
//  ColorTool
//
//  Created by Steve Sparks on 1/9/15.
//  Copyright (c) 2015 SOG. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "ColorList.h"
#import "ColorListCLROutput.h"

@interface ColorListCLROutput()
@property (nonatomic) NSDictionary *options;
@property (nonatomic) NSString *fileName;
@property (nonatomic) NSString *directory;


@end

@implementation ColorListCLROutput

+ (void)load {
    [ColorListOutput registerClass:[self class] forFormat:ColorListOutputFormatCLR];
}

- (instancetype)initWithOptions:(NSDictionary *)options directory:(NSString *)directory {
    self = [super init];
    if(self) {
        self.options = options;
        self.fileName = options[@"file"];
        self.directory = directory;
    }
    return self;
}

- (void)write:(ColorList *)colorList {
    NSString *path = self.directory;

    if(self.fileName)
        path = [path stringByAppendingPathComponent:self.fileName];

    NSColorList *outputList = [[NSColorList alloc] initWithName:colorList.name];
    for(NSString *colorName in colorList.colors.allKeys) {
        [outputList setColor:colorList.colors[colorName] forKey:colorName];
    }

    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL isDir;
    if([mgr fileExistsAtPath:path isDirectory:&isDir]) {
        [mgr removeItemAtPath:path error:nil];
    }
    [outputList writeToFile:path];
}

@end
