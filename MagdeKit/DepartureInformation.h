//
//  DepartureInformation.h
//  MagdeGo
//
//  Created by Rosario Raulin on 30.01.15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepartureInformation : NSObject

@property (strong, nonatomic, readonly) NSString *stationName;
@property (strong, nonatomic, readonly) NSArray *departureTimes;

+ (DepartureInformation*)newFromDictionary:(NSDictionary*)dict;
+ (NSArray*)newFromData:(NSData*)data;

- (id)initWithStationName:(NSString*)stationName useDepartureTimes:(NSArray*)departureTimes;

@end
