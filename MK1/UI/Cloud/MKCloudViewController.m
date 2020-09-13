//
//  MKCloudViewController.m
//  MK1
//
//  Created by Skitty on 9/13/20.
//  Copyright © 2020 Skitty. All rights reserved.
//

#import "MKCloudViewController.h"

@interface MKCloudViewController ()

@end

@implementation MKCloudViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Cloud";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    self.comingSoonLabel = [[UILabel alloc] initWithFrame:self.view.frame];
    self.comingSoonLabel.text = @"Coming Soon";
    self.comingSoonLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightSemibold];
    if (@available(iOS 13.0, *)) {
        self.comingSoonLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        self.comingSoonLabel.textColor = [UIColor lightGrayColor];
    }
    self.comingSoonLabel.textAlignment = NSTextAlignmentCenter;
    // [self.comingSoonLabel sizeToFit];
    [self.view addSubview:self.comingSoonLabel];
}

@end
