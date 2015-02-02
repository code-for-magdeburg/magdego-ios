//
//  DepartureInformationTVC.m
//  MagdeGo
//
//  Created by Rosario Raulin on 31.01.15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

#import "DepartureInformationTVC.h"
#import "DepartureTime.h"
#import "ViewController.h"

@interface DepartureInformationTVC ()

@property (strong, readonly) DepartureInformation* departureInformation;

@end

@implementation DepartureInformationTVC

- (id)initWithDepartureInformation:(DepartureInformation*)departureInformation {
    if (self) {
        _departureInformation = departureInformation;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    _departureInformation = nil;
}

- (void)viewDidLoad {
    self.stationName.text = [self.departureInformation stationName];
    ViewController* parentVC = (ViewController*)self.parentViewController;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:parentVC action:@selector(triggerLocationUpdate) forControlEvents:UIControlEventValueChanged];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.departureInformation.departureTimes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Fnord" forIndexPath:indexPath];
    
    if (indexPath.row < 0 || indexPath.row >= [self.departureInformation.departureTimes count]) {
        return nil;
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Fnord"];
    }
    
    UILabel* timeLabel = (UILabel*)[cell viewWithTag:1];
    UILabel* directionLabel = (UILabel*)[cell viewWithTag:2];
    UILabel* lineLabel = (UILabel*)[cell viewWithTag:3];
    
    DepartureTime* depTime = [self.departureInformation.departureTimes objectAtIndex:indexPath.row];
    
    timeLabel.text = [depTime timeDiffToNowString];
    directionLabel.text = depTime.direction;
    lineLabel.text = depTime.line;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // setup alterning colors
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:240/250.0 green:240/250.0 blue:240/250.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    UILabel* timeLabel = (UILabel*) [cell viewWithTag:1];
    DepartureTime* departureTime = [self.departureInformation.departureTimes objectAtIndex:indexPath.row];
    switch (departureTime.liveStatus) {
        case kLate:
            // set color to red
            timeLabel.textColor = [UIColor colorWithRed:100/255.0 green:50/255.0 blue:50/255.0 alpha:1];
            break;
        case kOnSchedule:
            // set color to green
            timeLabel.textColor = [UIColor colorWithRed:0.14 green:0.7 blue:0.56 alpha:1];
            break;
        case kNoLiveStatus:
            // don't change the color
            break;
    }
}

@end
