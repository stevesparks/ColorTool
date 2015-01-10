//
//  ColorList.m
//  ColorTool
//
//  Created by Steve Sparks on 1/9/15.
//  Copyright (c) 2015 SOG. All rights reserved.
//

#import "ColorList.h"



@interface ColorList()
@property (nonatomic) NSString *basePath;
@property (nonatomic) NSDictionary *dict;

@end

@implementation ColorList

- (instancetype)initWithJsonDict:(NSDictionary *)dict {
    self = [super init];
    if(self) {
        self.dict = dict;
    }
    return self;
}

- (instancetype)initWithContentsOfFile:(NSString *)fileName format:(ColorListInputFormat)inputFormat {
    self = [super init];
    if(self) {
        [self readFile:fileName format:inputFormat];
    }
    return self;
}


- (void)readFile:(NSString *)fileName format:(ColorListInputFormat)format {
    NSObject<ColorListInput> *input = [ColorListInput inputForFormat:format];
    [input populateColorList:self fromFile:fileName];

}

- (void)write {

    NSDictionary *dict = self.outputDict;
    if(!dict) {
        NSLog(@"No output section found!");
        return;
    }

    NSString *directory = dict[@"dir"];
    if(!directory) {
        directory = [[NSFileManager defaultManager] currentDirectoryPath];
        NSLog(@"Warning, no 'dir' variable set, path = %@", directory);
    }

    NSDictionary *writers = dict[@"writers"];
    if(!writers.count) {
        NSLog(@"No writers found!");
        return;
    }

    NSMutableDictionary *outputs = [[NSMutableDictionary alloc] initWithCapacity:writers.count];
    for(NSString *type in writers.allKeys) {
        NSDictionary *typeOpts = writers[type];
        NSObject<ColorListOutput> *out = [ColorListOutput outputForFormat:type options:typeOpts directory:directory];
        if(out)
            [outputs setObject:out forKey:type];
    }

    for(NSString *type in outputs.allKeys) {
        NSLog(@"Executing writer for %@ ...", type);
        NSObject<ColorListOutput> *out = [outputs objectForKey:type];
        [out write:self];
    }

    NSLog(@"Completed.");

}

@end
