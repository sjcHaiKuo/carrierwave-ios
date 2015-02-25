//
//  CRVImageEditViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageEditViewController.h"
#import "CRVTransformViewController.h"

#import "CRVImageEditView.h"
#import "CRVInfoView.h"
#import "CRVImageAsset.h"

#import "CRVNotificationIdentifiers.h"

@interface CRVImageEditViewController ()

@property (weak, nonatomic) CRVImageEditView *aView;
@property (weak, nonatomic) CRVTransformViewController *transformViewController;

@end

@implementation CRVImageEditViewController

#pragma mark - Object Lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    if (self = [super init]) {
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
    [self removeContainerTransformViewController];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Lifecycle

- (void)loadView {
    CRVImageEditView *view = [[CRVImageEditView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    _aView = view;
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNotifications];
    
    if ([self.dataSource respondsToSelector:@selector(heightForSettingsViewInImageEditViewController:)]) {
        self.aView.heightForSettingsView = [self.dataSource heightForSettingsViewInImageEditViewController:self];
    }
    
    if ([self.dataSource respondsToSelector:@selector(heightForInfoViewInImageEditViewController:)]) {
        self.aView.heightForInfoView = [self.dataSource heightForInfoViewInImageEditViewController:self];
    }
    
    if ([self.dataSource respondsToSelector:@selector(settingsViewForImageEditViewController:)]) {
        self.aView.settingsView = [self.dataSource settingsViewForImageEditViewController:self];
    } else {
        self.aView.settingsView = [[CRVImageEditSettingsView alloc] init];
    }
    
    if ([self.dataSource respondsToSelector:@selector(infoViewForImageEditViewController:)]) {
        self.aView.infoView = [self.dataSource infoViewForImageEditViewController:self];
    } else {
        self.aView.infoView = [[CRVInfoView alloc] init];
    }
    
    CRVTransformViewController *containerTransformViewController = [self addContainerTransformViewController];
    [containerTransformViewController setImage:[self.imageAsset image]];
}

#pragma mark - Public Methods

- (CRVSettingsView *)settingsView {
    return self.aView.settingsView;
}

- (UIView *)infoView {
    return self.aView.infoView;
}

#pragma mark - NSNotifications Listeners

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

- (void)onResetAction {
    [self.transformViewController resetTransform];
}

#pragma mark - Accessors

- (CRVScalableView *)cropView {
    return [self.transformViewController cropView];
}

- (void)setImageAsset:(CRVImageAsset *)imageAsset {
    if (![self.imageAsset isEqual:imageAsset]) {
        _imageAsset = imageAsset;
    }
}

#pragma mark - Private Methods

- (CRVTransformViewController *)addContainerTransformViewController {
    
    CRVTransformViewController *controller = [[CRVTransformViewController alloc] init];
    controller.view.frame = [self.aView rectForContainerView];
    [self addChildViewController:controller];
    [self.aView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    self.transformViewController = controller;
    return controller;
}

- (void)removeContainerTransformViewController {
    
    UIViewController *controller = [self.childViewControllers lastObject];
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

- (UIAlertController *)ratioAlertController {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select crop frame ratio:", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"None (free form)", nil) ratio:0.f]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"1:1", nil) ratio:1.f]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"1:2", nil) ratio:.5f]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"2:1", nil) ratio:2.f]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"3:4", nil) ratio:.75f]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"4:3", nil) ratio:1.3333f]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"9:16", nil) ratio:.5625f]];
    [alertController addAction:[self actionWithTitle:NSLocalizedString(@"16:9", nil) ratio:1.7778f]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    return alertController;
}

- (UIAlertAction *)actionWithTitle:(NSString *)title ratio:(CGFloat)ratio {
    
    return [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (ratio != 0.f) {
            [self.cropView animateToRatio:ratio completion:^(BOOL finished) {
                self.cropView.ratioEnabled = YES;
            }];
        } else {
            self.cropView.ratioEnabled = NO;
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)registerNotifications {
    
    void (^registerNotification)(SEL, NSString *) = ^(SEL selector, NSString *name) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:name object:nil];
    };
    
    registerNotification(@selector(onRatioAction), CRVEditViewControllerWillShowRatioAlertController);
    registerNotification(@selector(onCancelAction), CRVEditViewControllerWillCancelEditingNotification);
    registerNotification(@selector(onDoneAction), CRVEditViewControllerWillFinishEditingWithImageAssetNotification);
    registerNotification(@selector(onResetAction), CRVEditViewControllerWillResetImageAssetTransformationNotification);
}

@end
