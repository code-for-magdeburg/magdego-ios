//
//  DepartureTime.m
//  MagdeGo
//
//  Created by Rosario Raulin on 30.01.15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

#import "DepartureTime.h"

@implementation DepartureTime

- (id)initWithLine:(NSString*)line direction:(NSString*)direction time:(NSDate*)time {
    if (self) {
        _line = line;
        _direction = direction;
        _time = time;
        _liveStatus = kNoLiveStatus;
    }
    
    return self;
}

- initWithOffsetString:(NSString*)offSet line:(NSString*)line direction:(NSString*)direction time:(NSDate*)time {
    if (self) {
        _line = line;
        _direction = direction;
        _time = time;
        
        if ([offSet isEqualToString:@"0"]) {
            _liveStatus = kOnSchedule;
        } else {
            _liveStatus = kLate;
        }
    }
    
    return self;
}

- (NSString*)timeDiffToNowString {
    NSDate* now = [NSDate date];
    NSTimeInterval timeDiff = [self.time timeIntervalSinceDate:now];
    NSUInteger minutesBetweenDates = fabs(timeDiff) / 60;
    
    NSString* timeString = nil;
    if (minutesBetweenDates == 0) {
        timeString = NSLocalizedString(@"Now", @"Now");
    } else if (minutesBetweenDates < 30) {
        timeString = [NSString localizedStringWithFormat:NSLocalizedString(@"in %lu min", @"remaining time in minutes format string"), (unsigned long)minutesBetweenDates];
    } else {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        timeString = [formatter stringFromDate:self.time];
    }
    
    return timeString;
}

+ (DepartureTime*)newFromDictionary:(NSDictionary*)dict {
    NSString* line = [dict objectForKey:@"line"];
    NSString* direction = [dict objectForKey:@"direction"];
    NSString* timeRaw = [dict objectForKey:@"departure"];
    
    DepartureTime* departureTime = nil;
    if (timeRaw) {
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:posix];
        NSDate* time = [dateFormatter dateFromString:timeRaw];
        if (line && direction && time) {
            NSDictionary* delayInformation = [dict objectForKey:@"delay"];
            if (delayInformation) {
                NSString* offSetInMinutes = [delayInformation objectForKey:@"minutes"];
                departureTime = [[DepartureTime alloc] initWithOffsetString:offSetInMinutes line:line direction:direction time:time];
            } else {
                departureTime = [[DepartureTime alloc] initWithLine:line direction:direction time:time];
            }
        }
    }
    
    return departureTime;
}

+ (NSArray*)newFromArray:(NSArray*)array {
    NSMutableArray* depTimes = [NSMutableArray new];
    
    for (NSDictionary* dict in array) {
        DepartureTime* time = [DepartureTime newFromDictionary:dict];
        if (time == nil) {
            return depTimes;
        } else {
            [depTimes addObject:time];
        }
    }
    
    return depTimes;
}

@end
