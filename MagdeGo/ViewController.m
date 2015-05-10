//
//  ViewController.m
//  MagdeGo
//
//  Created by Rosario Raulin on 30.01.15.
//  Copyright (c) 2015 Rosario Raulin. All rights reserved.
//

#import "ViewController.h"
#import "DepartureInformation.h"
#import "DepartureInformationTVC.h"

#import <CoreLocation/CoreLocation.h>

@import MagdeKit;

@interface ViewController ()

@property (assign) NSUInteger currentPage;
@property (strong) NSMutableArray* depInfoTVC;
@property (strong) DepInfoManager* departureInformationManager;

@end

@implementation ViewController

+ (CLLocation*)demoLocation {
    static CLLocation* demoLocation = nil;
    if (!demoLocation) {
        // Hasselbachplatz: 52.120577, 11.627642
        demoLocation = [[CLLocation alloc] initWithLatitude:52.120577 longitude:11.627642];
    }
    return demoLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup wakup call
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerLocationUpdate) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // setup departure information observation

    self.departureInformationManager = [[DepInfoManager alloc] initWithNewInfoCallback:^(NSArray * __nonnull newDepartureInfo) {
        [self updateViewsForNewDepartureInformation:newDepartureInfo];
    } errorCallback:^(enum DepManagerError error) {
        NSString* errorString;
        
        switch (error) {
            case DepManagerErrorNetworkError:
                errorString = @"Network error!";
            case DepManagerErrorNoLocationService:
                errorString = @"No Location service error!";
                [self showNoLocationServiceError];
            case DepManagerErrorParsingError:
                errorString = @"Parsing error!";
        }
        
        NSLog(@"error: %@", errorString);
    }];
    
    [self.departureInformationManager requestDepartureTimesForLocation:nil];
}

- (void)setupTVCForNewDepartureInfo:(NSArray*)newDepartureInfo {
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.depInfoTVC = [[NSMutableArray alloc] initWithCapacity:[newDepartureInfo count]];
    
    for (int i = 0; i < [newDepartureInfo count]; ++i) {
        DepartureInformation* departureInformation = [newDepartureInfo objectAtIndex:i];
        
        DepartureInformationTVC* tvc = [[self storyboard] instantiateViewControllerWithIdentifier:@"DepartureInformationTVC"];
        
        tvc = [tvc initWithDepartureInformation:departureInformation];
        
        [self addChildViewController:tvc];
        [tvc didMoveToParentViewController:self];
        
        UITableView* tv = [tvc tableView];
        [tv setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.scrollView addSubview:tv];
        
        NSLayoutConstraint* widthConstraint = [NSLayoutConstraint constraintWithItem:tv attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        NSLayoutConstraint* heightConstraint = [NSLayoutConstraint constraintWithItem:tv attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
        NSLayoutConstraint* topConstraint = [NSLayoutConstraint constraintWithItem:tv attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint* bottomConstraint = [NSLayoutConstraint constraintWithItem:tv attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        [self.scrollView addConstraints:@[widthConstraint, heightConstraint, topConstraint, bottomConstraint]];
        [self.depInfoTVC addObject:tvc];
    }
    
    // pred constraints
    for (int i = 1; i < [self.depInfoTVC count]; ++i) {
        UITableView* pred = [[self.depInfoTVC objectAtIndex:i-1] tableView];
        UITableView* next = [[self.depInfoTVC objectAtIndex:i] tableView];
        
        NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:pred attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:next attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
        [self.scrollView addConstraint:constraint];
    }
    
    // special cases for first/last table view
    UITableView* first = [[self.depInfoTVC firstObject] tableView];
    UITableView* last = [[self.depInfoTVC lastObject] tableView];
    
    NSLayoutConstraint* firstConstraint = [NSLayoutConstraint constraintWithItem:first attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint* lastContraint = [NSLayoutConstraint constraintWithItem:last attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    
    [self.scrollView addConstraints:@[firstConstraint, lastContraint]];
}

- (void)removeOldTVC {
    for (DepartureInformationTVC* tvc in self.depInfoTVC) {
        [tvc willMoveToParentViewController:nil];
        [tvc.view removeFromSuperview];
        [tvc removeFromParentViewController];
    }
    [self.depInfoTVC removeAllObjects];
}

- (void)triggerLocationUpdate {
    [self.departureInformationManager requestDepartureTimesForLocation:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // TODO
}

- (NSUInteger)updateCurrentPage {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    self.currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    return self.currentPage;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSUInteger currentPage = [self updateCurrentPage];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.scrollView.contentOffset = CGPointMake(currentPage * self.scrollView.bounds.size.width, 0);
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)resetScrollView {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)showNoLocationServiceError {
    [self showErrorAlertWithTitle:NSLocalizedString(@"No location permission", @"No location alert title") message:NSLocalizedString(@"Sorry, we need your location to show stations nearby. Please enable location service in settings. Using demo location for now.", @"Ask user to enable location service for this app.")];
    [self.departureInformationManager requestDepartureTimesForLocation:[ViewController demoLocation]];
}

- (void)showErrorAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateViewsForNewDepartureInformation:(NSArray*)newDepInfo {
    if ([newDepInfo count] == 0) {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Results", @"No Results") message:NSLocalizedString(@"Couldn't get any stations nearby. This app works in Saxony-Anhalt and Leipzig only. Use demo location?", @"") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* useDemo = [UIAlertAction actionWithTitle:NSLocalizedString(@"Use Demo", @"Use Demo") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSLog(@"Using demo location");
            [self.departureInformationManager requestDepartureTimesForLocation:[ViewController demoLocation]];
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertController addAction:useDemo];
        [alertController addAction:cancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeOldTVC];
            [self setupTVCForNewDepartureInfo:newDepInfo];
        });
    }
}

@end
