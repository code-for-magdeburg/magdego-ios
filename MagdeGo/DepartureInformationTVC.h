//
//  DepartureInformationTVC.h
//  MagdeGo
//
//  Created by Rosario Raulin on 31.01.15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DepartureInformation.h"

@interface DepartureInformationTVC : UITableViewController

@property (strong, nonatomic) IBOutlet UILabel *stationName;

- (id)initWithDepartureInformation:(DepartureInformation*)departureInformation;

@end
