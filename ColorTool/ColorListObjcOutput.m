//
//  ColorListObjcOutput.m
//  ColorTool
//
//  Created by Steve Sparks on 1/9/15.
//  Copyright (c) 2015 SOG. All rights reserved.
//

#import "ColorListObjcOutput.h"
#import "ColorList.h"

@interface ColorListObjcOutput()
@property (nonatomic) NSDictionary *options;
@property (nonatomic) NSString *className;

@property (nonatomic) NSString *directory;

@property (readonly, nonatomic) NSString *mHeader;
@property (readonly, nonatomic) NSString *mFooter;
@property (readonly, nonatomic) NSString *mFileName;

@property (readonly, nonatomic) NSString *hHeader;
@property (readonly, nonatomic) NSString *hFooter;
@property (readonly, nonatomic) NSString *hFileName;

@property (nonatomic) BOOL forIOS;

@end

@implementation ColorListObjcOutput

+ (void)load {
    [ColorListOutput registerClass:[self class] forFormat:ColorListOutputFormatObjC];
}


- (instancetype)initWithOptions:(NSDictionary*)options directory:(NSString *)directory {
    self = [super init];
    if(self) {
        self.options = options;
        self.className = options[@"class"];
        self.directory = directory;
        if([@"ios" isEqualToString:options[@"platform"]]) {
            self.forIOS = YES;
        }
    }
    return self;
}

+ (NSString *)modifiedNameForString:(NSString *)string {
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""] ;
}

- (NSString *)colorNameForString:(NSString *)string {
    return [ColorListObjcOutput modifiedNameForString:string.capitalizedString];
}

- (NSString *)className {
    NSString *name = _className;
    // We assume if they ended in "Color" that it's all right
    if(![name hasSuffix:@"Color"]) {
        // turn "big project" => "Big Project Color"
        if(![self hasMixedCaseAfterInitialCaps:name]) {
            name = name.capitalizedString;
        }
        name = [name stringByAppendingString:@"Color"];
    }
    // turn "Big Project Color" -> "BigProjectColor"
    return [ColorListObjcOutput modifiedNameForString:name];
}

- (BOOL)hasMixedCaseAfterInitialCaps:(NSString *)str {
    const char *arr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    char *ptr = (char *)arr;

    BOOL foundUpper = NO;
    // Starts with caps?
    while(*ptr && isupper(*ptr)) {
        foundUpper = YES;
        ptr++;
    }
    if(!foundUpper)
        return NO;

    // Then has some lower?
    while(*ptr && islower(*ptr)) {
        foundUpper = NO;
        ptr++;
    }
    if(foundUpper)
        return NO;

    // Then at least one upper?
    if(*ptr && isupper(*ptr)) {
        return YES;
    }
    return NO;
}

- (NSString *)framework {
    if(self.forIOS)
        return @"<UIKit/UIKit.h>";
    return @"<AppKit/AppKit.h>";
}

- (NSString *)superclassName {
    if(self.forIOS)
        return @"UIColor";
    return @"NSColor";
}

- (NSString *)mFileName {
    return [self.directory stringByAppendingPathComponent:[self.className stringByAppendingString:@".m"]];
}

- (NSString *)mHeader {
    return [NSString stringWithFormat:@"\
//\n\
// %@.m\n\
// Generated on %@\n\
//\n\n\
#import \"%@\"\n\n\
@implementation %@\n\n", self.className, [NSDate date], self.hFileName, self.className];
}

- (NSString *)mFooter {
    return @"\n@end\n\n";
}

- (NSString *)hFileName {
    return [self.className stringByAppendingString:@".h"];
}

- (NSString *)hHeader {
    return [NSString stringWithFormat:@"\
//\n\
// %@.h\n\
// Generated on %@\n\
//\n\n\
#import %@\n\n\
@interface %@ : %@\n\n", self.className, [NSDate date], self.framework, self.className, self.superclassName];
}

- (NSString *)hFooter {
    return @"\n@end\n\n";
}

- (NSString *)hLineForColorWithName:(NSString *)name {
    return [NSString stringWithFormat:@"+ (%@ *)colorFor%@;\n", self.superclassName, name];
}

- (NSString *)mLinesForColor:(NSColor *)color withName:(NSString *)name {
    return [NSString stringWithFormat:@"+ (%@ *)colorFor%@ {\n    return [%@ colorWithRed:%.3f green:%.3f blue:%.3f alpha:1.0];\n}\n\n", self.superclassName, name, self.superclassName, color.redComponent, color.greenComponent, color.blueComponent];
}

- (void)write:(ColorList *)colorList {

    NSMutableString *interface = [[NSMutableString alloc] initWithString:self.hHeader];
    NSMutableString *implementation = [[NSMutableString alloc] initWithString:self.mHeader];
    NSDictionary *colors = colorList.colors;

    NSArray *sortedColorKeys = [colors.allKeys sortedArrayUsingComparator:^(NSString *s1, NSString *s2){
        return [s2 compare:s1];
    }];
    for(NSString *colorName in sortedColorKeys) {
        NSColor *color = colors[colorName];
        NSString *safeName = [self colorNameForString:colorName];
        [interface appendString:[self hLineForColorWithName:safeName]];
        [implementation appendString:[self mLinesForColor:color withName:safeName]];
    }
    [interface appendString:self.hFooter];
    [implementation appendString:self.mFooter];

    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL isDir;
    if([mgr fileExistsAtPath:self.hFileName isDirectory:&isDir]) {
        [mgr removeItemAtPath:self.hFileName error:nil];
    }
    if([mgr fileExistsAtPath:self.mFileName isDirectory:&isDir]) {
        [mgr removeItemAtPath:self.mFileName error:nil];
    }

    NSError *error;
    [interface writeToFile:self.hFileName
                atomically:NO
                  encoding:NSStringEncodingConversionAllowLossy
                     error:&error];
    if(error) {
        NSLog(@"Error writing ObjC header to %@ : %@", self.hFileName, error);
    }

    [implementation writeToFile:self.mFileName
                     atomically:NO
                       encoding:NSStringEncodingConversionAllowLossy
                          error:&error];
    if(error) {
        NSLog(@"Error writing ObjC class to %@ : %@", self.mFileName, error);
    }

}

@end
