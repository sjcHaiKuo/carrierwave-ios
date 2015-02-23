//
//  CRVImageEditViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageEditViewController.h"
#import "CRVTransformViewController.h"

#import "CRVImageAsset.h"
#import "CRVImageEditSettingsView.h"
#import "CRVScalableView.h"

static const CGFloat CRVDefaultMinimumZoom = 1.0f;
static const CGFloat CRVDefaultMaximalZoom = 2.0f;

@interface CRVImageEditViewController ()

@property (weak, nonatomic, readwrite) CRVScalableView *cropView;
@property (weak, nonatomic) CRVTransformViewController *transformViewController;

@end

@implementation CRVImageEditViewController

#pragma mark - Object lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.imageAsset = asset;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithImageAsset:nil];
}

- (instancetype)init {
    return [self initWithImageAsset:nil];
}

- (void)dealloc {
    UIViewController *controller = [self.childViewControllers lastObject];
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CRVTransformViewController *controller = [[CRVTransformViewController alloc] init];
    [self addChildViewController:controller];
    
    CRVTemporary("temporary hardcoded");
    CGRect rect = self.view.bounds;
    rect.size.height -= 100;
    
    controller.view.frame = rect;
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    [controller setImage:[self.imageAsset image]];
    self.transformViewController = controller;
    self.cropView = [controller cropView];
    
    CRVTemporary("Temporary here:");
    if (self.settingsView == nil) {
        self.settingsView = [[CRVImageEditSettingsView alloc] init];
    }
    [self.view addSubview:self.settingsView];
}

CRVTemporary("Temporary layout here (and also hardcoded):");
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect rect = self.view.bounds;
    self.settingsView.frame = CGRectMake(0.f, CGRectGetHeight(rect) - 100.f,
                                         CGRectGetWidth(rect), 100.f);
}

#pragma mark - Accessors

- (void)setSettingsView:(UIView<CRVImageEditSettingsActions> *)settingsView {
    _settingsView = settingsView;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCancelAction) name:NSStringFromSelector(self.settingsView.cancelAction) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDoneAction) name:NSStringFromSelector(self.settingsView.doneAction) object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRatioAction) name:NSStringFromSelector(self.settingsView.ratioAction) object:nil];
}

#pragma mark - UIControl actions

- (void)onCancelAction {
    if ([self.delegate respondsToSelector:@selector(imageEditViewControllerDidCancelEditing:)]) {
        [self.delegate imageEditViewControllerDidCancelEditing:self];
    }
}

- (void)onRatioAction {
    UIAlertController *ratioAlertController = [self ratioAlertController];
    [self presentViewController:ratioAlertController animated:YES completion:nil];
}

- (void)onDoneAction {
    if ([self.delegate respondsToSelector:@selector(imageEditViewController:didFinishEditingWithImageAsset:)]) {
        UIImage *croppedImage = [self.transformViewController cropImage];
        CRVImageAsset *asset = [[CRVImageAsset alloc] initWithImage:croppedImage];
        [self.delegate imageEditViewController:self didFinishEditingWithImageAsset:asset];
    }
}

- (void)setImageAsset:(CRVImageAsset *)imageAsset {
    if (![self.imageAsset isEqual:imageAsset]) {
        _imageAsset = imageAsset;
    }
}

#pragma mark - ratio UIAlertController

- (UIAlertController *)ratioAlertController {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select crop frame ratio:", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"None (free form)", nil) animateSize:CGSizeMake(200.f, 200.f) ratioEnabled:NO]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"1:1", nil) animateSize:CGSizeMake(200.f, 200.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"1:2", nil) animateSize:CGSizeMake(120.f, 240.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"2:1", nil) animateSize:CGSizeMake(240.f, 120.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"3:4", nil) animateSize:CGSizeMake(150.f, 200.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"4:3", nil) animateSize:CGSizeMake(200.f, 150.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"9:16", nil) animateSize:CGSizeMake(90.f, 160.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"16:9", nil) animateSize:CGSizeMake(160.f, 90.f) ratioEnabled:YES]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    return alertController;
}

- (UIAlertAction *)actionWithTitle:(NSString *)title animateSize:(CGSize)size ratioEnabled:(BOOL)enabled {
    
    return [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (enabled) {
            [self.cropView animateToSize:size completion:^(BOOL finished) {
                self.cropView.ratioEnabled = YES;
            }];
        } else {
            self.cropView.ratioEnabled = NO;
        }
    }];
}

@end
