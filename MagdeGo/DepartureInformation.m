//
//  DepartureInformation.m
//  MagdeGo
//
//  Created by Rosario Raulin on 30.01.15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

#import "DepartureInformation.h"
#import "DepartureTime.h"

@implementation DepartureInformation

- (id)initWithStationName:(NSString*)stationName useDepartureTimes:(NSArray*)departureTimes {
    if (self) {
        _stationName = stationName;
        _departureTimes = departureTimes;
    }
    
    return self;
}

+ (DepartureInformation*)newFromDictionary:(NSDictionary*)dict {
    NSString* stationName = [dict objectForKey:@"station_info"];
    NSArray* departureTimes = [DepartureTime newFromArray:[dict objectForKey:@"departure_times"]];
    
    DepartureInformation* depInfo = nil;
    if (stationName && departureTimes) {
        depInfo = [[DepartureInformation alloc] initWithStationName:stationName useDepartureTimes:departureTimes];
    }
    
    return depInfo;
}

+ (NSArray*)newFromData:(NSData*)data {
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        // not a valid json object, fail immediately
        NSLog(@"error, got non-json data: %@", error.localizedDescription);
        return nil;
    }
    
    NSMutableArray* depInfoObjects = [NSMutableArray new];
    
    if (![obj isKindOfClass:[NSArray class]]) {
        NSLog(@"malformed json output");
        return nil;
    }
    
    NSArray *dicts = obj;
    for (NSUInteger i = 0; i < [dicts count]; ++i) {
        id maybeDict = [dicts objectAtIndex:i];
        if (![maybeDict isKindOfClass:[NSDictionary class]]) {
            return depInfoObjects;
        }
        
        NSDictionary* dict = maybeDict;
        DepartureInformation* depInfo = [DepartureInformation newFromDictionary:dict];
        if (depInfo) {
            [depInfoObjects addObject:depInfo];
        } else {
            // stop after parsing error, return objects parsed so far
            return depInfoObjects;
        }
    }
    
    return depInfoObjects;
}

@end
