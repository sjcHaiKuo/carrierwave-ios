//
//  CRVImageEditViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVImageEditViewController.h"
#import "CRVTransformViewController.h"
#import "CRVAlertController.h"

#import "CRVImageEditView.h"
#import "CRVHeaderView.h"
#import "CRVFooterView.h"

#import "CRVImageAsset.h"
#import "CRVNotificationIdentifiers.h"

@interface CRVImageEditViewController ()

@property (weak, nonatomic) CRVImageEditView *aView;
@property (weak, nonatomic) CRVTransformViewController *transformViewController;
@property (strong, nonatomic, readwrite) NSArray *ratioItemList;

@end

@implementation CRVImageEditViewController

#pragma mark - Object Lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.imageAsset = asset;
    }
    return self;
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
    [self createRatioList];
    
    if ([self.delegate respondsToSelector:@selector(heightForHeaderInImageEditViewController:)]) {
        self.aView.headerHeight= [self.delegate heightForHeaderInImageEditViewController:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(heightForFooterInImageEditViewController:)]) {
        self.aView.footerHeight = [self.delegate heightForFooterInImageEditViewController:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(viewForHeaderInImageEditViewController:)]) {
        self.aView.headerView = [self.delegate viewForHeaderInImageEditViewController:self];
    } else {
        self.aView.headerView = [[CRVHeaderView alloc] init];
    }
    
    if ([self.delegate respondsToSelector:@selector(viewForFooterInImageEditViewController:)]) {
        self.aView.footerView = [self.delegate viewForFooterInImageEditViewController:self];
    } else {
        self.aView.footerView = [[CRVFooterView alloc] init];
    }
    
    CRVTransformViewController *containerTransformViewController = [self addContainerTransformViewController];
    [containerTransformViewController setImage:[self.imageAsset image]];
}

#pragma mark - Public Methods

- (UIView *)headerView {
    return self.aView.headerView;
}

- (UIView *)footerView {
    return self.aView.footerView;
}

- (void)addRatioItemToList:(CRVRatioItem *)ratioItem {
    NSMutableArray *array = [self.ratioItemList mutableCopy];
    [array addObject:ratioItem];
    self.ratioItemList = [array copy];
}

#pragma mark - NSNotifications Listeners

- (void)onCancelAction {
    if ([self.delegate respondsToSelector:@selector(imageEditViewControllerDidCancelEditing:)]) {
        [self.delegate imageEditViewControllerDidCancelEditing:self];
    }
}

- (void)onRatioAction {
    CRVAlertController *ratioAlertController = [[CRVAlertController alloc] initWithList:self.ratioItemList actionHandler:^(CGFloat ratio) {
        if (ratio != 0.f) {
            [self.cropView animateToRatio:ratio completion:^(BOOL finished) {
                self.cropView.ratioEnabled = YES;
            }];
        } else {
            self.cropView.ratioEnabled = NO;
        }
    }];
    [self presentViewController:ratioAlertController animated:YES completion:nil];
}

- (void)onDoneAction {
    if ([self.delegate respondsToSelector:@selector(imageEditViewController:didFinishEditingWithImageAsset:)]) {
        UIImage *croppedImage = [self.transformViewController cropImage];
        CRVImageAsset *asset = [[CRVImageAsset alloc] initWithImage:croppedImage];
        [self.delegate imageEditViewController:self didFinishEditingWithImageAsset:asset];
    }
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

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

- (void)registerNotifications {
    
    void (^registerNotification)(SEL, NSString *) = ^(SEL selector, NSString *name) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:selector name:name object:nil];
    };
    
    registerNotification(@selector(onRatioAction), CRVImageEditViewControllerWillShowRatioAlertControllerNotification);
    registerNotification(@selector(onCancelAction), CRVImageEditViewControllerWillCancelEditingNotification);
    registerNotification(@selector(onDoneAction), CRVImageEditViewControllerWillFinishEditingWithImageAssetNotification);
}

- (void)createRatioList {
    
    CRVRatioItem * (^createCropRatio)(NSString *, CGFloat) = ^(NSString *title, CGFloat ratio) {
        return [[CRVRatioItem alloc] initWithTitle:title ratio:ratio];
    };
    
    self.ratioItemList = @[createCropRatio(NSLocalizedString(@"None (free form)", nil), 0.f),
                           createCropRatio(NSLocalizedString(@"1:1", nil), 1.f),
                           createCropRatio(NSLocalizedString(@"1:2", nil), .5f),
                           createCropRatio(NSLocalizedString(@"2:1", nil), 2.f),
                           createCropRatio(NSLocalizedString(@"3:4", nil), 0.75f),
                           createCropRatio(NSLocalizedString(@"4:3", nil), 1.3333f)];
}

@end
