//
//  ViewController.h
//  MagdeGo
//
//  Created by Rosario Raulin on 30.01.15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

- (void)triggerLocationUpdate;

@end

