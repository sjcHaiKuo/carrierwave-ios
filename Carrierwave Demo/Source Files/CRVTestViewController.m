//
//  CRVTestViewController.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 22.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVTestViewController.h"
@import Carrierwave;

@interface CRVTestViewController ()

@property (strong, nonatomic) CRVScalableView *scalableView;
@property (strong, nonatomic) UIButton *button;

@end

@implementation CRVTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scalableView = [[CRVScalableView alloc] init];
    _scalableView.maxSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    [self.view addSubview:_scalableView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.backgroundColor = [UIColor darkGrayColor];
    [_button setTitle:@"animate!" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scalableView.frame = CGRectMake(50, 50, 100, 200);
    self.button.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - 44.f, CGRectGetWidth(self.view.bounds), 44.f);
    
}

- (void)tap:(id)sender {
    [self.scalableView animateToSize:CGSizeMake(300, 300) completion:nil];
}

@end
