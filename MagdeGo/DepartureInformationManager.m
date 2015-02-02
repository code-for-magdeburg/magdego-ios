//
//  DepartureInformationManager.m
//  MagdeGo
//
//  Created by Rosario Raulin on 30.01.15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

#import "DepartureInformationManager.h"
#import "DepartureInformation.h"

@implementation DepartureInformationManager

- (void)updateForLocation:(CLLocation*)location {
    NSString* baseUrl = @"http://api.magdego.de/departure-time/location/%f/%f";
    NSString* urlString = [NSString stringWithFormat:baseUrl, location.coordinate.longitude, location.coordinate.latitude];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSLog(@"Querying url %@", urlString);
    
    NSURLSession* urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask* task = [urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Fetching departure info failed: %@!", error.localizedDescription);
        } else {
            NSArray* depInfo = [DepartureInformation newFromData:data];
            if (depInfo) {
                self.departureInformation = depInfo;
            } else {
                NSLog(@"Error parsing departure info!");
            }
        }
    }];
    
    [task resume];
}

@end
