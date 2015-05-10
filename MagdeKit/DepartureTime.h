//
//  DepartureTime.h
//  MagdeGo
//
//  Created by Rosario Raulin on 30.01.15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kNoLiveStatus,
    kOnSchedule,
    kLate
} LiveStatus;

@interface DepartureTime : NSObject

@property (strong, nonatomic, readonly) NSString *line;
@property (strong, nonatomic, readonly) NSString *direction;
@property (strong, nonatomic, readonly) NSDate *time;
@property (assign) LiveStatus liveStatus;

+ (DepartureTime*)newFromDictionary:(NSDictionary*)dict;
+ (NSArray*)newFromArray:(NSArray*)array;

- (id)initWithLine:(NSString*)line direction:(NSString*)direction time:(NSDate*)time;
- (NSString*)timeDiffToNowString;

@end
