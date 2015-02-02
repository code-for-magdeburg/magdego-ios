//
//  DepartureInformationManager.h
//  MagdeGo
//
//  Created by Rosario Raulin on 30.01.15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DepartureInformationManager : NSObject

@property (strong) NSArray* departureInformation;

- (void)updateForLocation:(CLLocation*)location;

@end
