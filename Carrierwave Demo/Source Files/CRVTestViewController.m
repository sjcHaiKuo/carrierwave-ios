//
//  CRVTestViewController.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 22.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVTestViewController.h"
@import Carrierwave;

@interface CRVTestViewController () <CRVScalableViewDelegate>

@property (strong, nonatomic) CRVScalableView *scalableView;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UISwitch *ratioSwitch;

@end

@implementation CRVTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CRVTemporary("Only for test purposes. Will be deleted ASAP:")
    
    _scalableView = [[CRVScalableView alloc] init];
    _scalableView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4f];
    _scalableView.borderView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4f];
    _scalableView.delegate = self;
    [self.view addSubview:_scalableView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.backgroundColor = [UIColor darkGrayColor];
    [_button setTitle:@"animate!" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    _ratioSwitch = [[UISwitch alloc] init];
    _ratioSwitch.on = NO;
    [_ratioSwitch addTarget:self action:@selector(ratioSwitchDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_ratioSwitch];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scalableView.frame = CGRectMake(50, 50, 200, 200);
    self.button.frame = CGRectMake(0.0f, CGRectGetMaxY(self.view.bounds) - 44.f, CGRectGetWidth(self.view.bounds), 44.f);
    self.ratioSwitch.frame = CGRectMake(CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.ratioSwitch.frame) - 5.f,
                                        CGRectGetMidY(self.button.frame) - CGRectGetHeight(self.ratioSwitch.frame) * .5f,
                                        CGRectGetWidth(self.ratioSwitch.frame),
                                        CGRectGetHeight(self.ratioSwitch.frame));
}

- (void)ratioSwitchDidChangeValue:(UISwitch *)sender {
    self.scalableView.ratioEnabled = self.ratioSwitch.isOn;
}

- (void)tap:(id)sender {
    [self.scalableView animateToSize:CGSizeMake(300, 300) completion:nil];
}

@end
