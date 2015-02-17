//
//  CRVImageEditViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CRVImageEditViewController.h"
#import "CRVImageAsset.h"
#import "CRVImageEditSettingsView.h"
#import "CRVScalableView.h"

static const CGFloat kDefaultMinimumZoom = 0.1f;
static const CGFloat kDefaultMaximalZoom = 2.0f;

@interface CRVImageEditViewController() <CRVScalableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *editedImageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic, readwrite) CRVScalableView *cropView;

@end

@implementation CRVImageEditViewController

#pragma mark - Object lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;
    
    self.imageAsset = asset;
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithImageAsset:nil];
}

- (instancetype)init {
    return [self initWithImageAsset:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.scrollView.contentSize = CGSizeMake(self.editedImageView.frame.size.width, self.editedImageView.frame.size.height);
    self.scrollView.delegate = self;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.scrollView setZoomScale:0.4f];
    self.minimumZoom = kDefaultMinimumZoom;
    self.maximalZoom = kDefaultMaximalZoom;
    [self.view addSubview:self.scrollView];
    
    self.editedImageView = [[UIImageView alloc] initWithImage:self.imageAsset.image];
    self.editedImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:self.editedImageView];
    
    self.cropView = [[CRVScalableView alloc] init];
    self.cropView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1f];
    self.cropView.borderView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
    self.cropView.opaque = NO;
    [self.cropView setMaxSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    self.cropView.delegate = self;
    [self.view addSubview:self.cropView];
    
    if (self.settingsView == nil) {
        self.settingsView = [[CRVImageEditSettingsView alloc] init];
    }
    [self.view addSubview:self.settingsView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateViewsBasedOnImageAsset];
    [self updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.cropView.frame = CGRectMake(self.view.frame.size.width / 2 - self.cropView.frame.size.width / 2,
                                     self.view.frame.size.height / 2 - self.cropView.frame.size.height / 2,
                                     200,
                                     200);
}

- (void)updateViewsBasedOnImageAsset {
    BOOL doesImageAssetExist = (self.imageAsset != nil);
    
    self.cropView.hidden = !doesImageAssetExist;
    self.settingsView.doneTriggerView.hidden = !doesImageAssetExist;
    if ([self.settingsView respondsToSelector:@selector(ratioTriggerView)]) {
        self.settingsView.ratioTriggerView.hidden = !doesImageAssetExist;
    }
}

- (void)updateViewConstraints {
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.right.equalTo(self.view);
        make.bottom.equalTo(self.settingsView.mas_top);
    }];
    
    [self.editedImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Cropping image

- (UIImage *)getCroppedImage {
    self.cropView.hidden = YES;
    self.settingsView.hidden = YES;
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *sourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    
    CGRect finalFrame = CGRectMake(self.cropView.frame.origin.x * screenScale,
                                   self.cropView.frame.origin.y * screenScale,
                                   self.cropView.frame.size.width * screenScale,
                                   self.cropView.frame.size.height * screenScale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([sourceImage CGImage], finalFrame);
    
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:sourceImage.scale orientation:sourceImage.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

#pragma mark - Public property accessors

- (void)setSettingsView:(UIView<CRVImageEditSettingsActions> *)settingsView {
    _settingsView = settingsView;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliderValueChanged:) name:NSStringFromSelector(self.settingsView.sliderValueChangedAction) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCancelAction) name:NSStringFromSelector(self.settingsView.cancelAction) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRatioAction) name:NSStringFromSelector(self.settingsView.ratioAction) object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDoneAction) name:NSStringFromSelector(self.settingsView.doneAction) object:nil];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.editedImageView;
}

#pragma mark - Slider value changes

- (void)sliderValueChanged:(id)sender {
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSNotification *notification = (NSNotification *)sender;
        if ([notification.object isKindOfClass:[NSNumber class]]) {
            NSNumber *radsNumber = (NSNumber *)notification.object;
            CGFloat rads = (CGFloat)M_PI * [radsNumber floatValue] / 180.f;
            self.scrollView.transform = CGAffineTransformMakeRotation(rads);
        }
    }
}

#pragma mark - Button actions

- (void)onCancelAction {
    if ([self.delegate respondsToSelector:@selector(imageEditViewControllerDidCancelEditing:)]) {
        [self.delegate imageEditViewControllerDidCancelEditing:self];
    }
}

- (void)onRatioAction {
    UIAlertController *ratioAlertController = [self ratioAlertController];
    [self presentViewController:ratioAlertController animated:YES completion:^{}];
}

- (void)onDoneAction {
    if ([self.delegate respondsToSelector:@selector(imageEditViewController:didFinishEditingWithImageAsset:)]) {
        UIImage *croppedImage = [self getCroppedImage];
        CRVImageAsset *asset = [[CRVImageAsset alloc] initWithImage:croppedImage];
        [self.delegate imageEditViewController:self didFinishEditingWithImageAsset:asset];
    }
}

- (void)setImageAsset:(CRVImageAsset *)imageAsset {
    if (![self.imageAsset isEqual:imageAsset]) {
        _imageAsset = imageAsset;
        [self updateViewsBasedOnImageAsset];
    }
}

- (CGFloat)minimumZoom {
    return self.scrollView.minimumZoomScale;
}

- (void)setMinimumZoom:(CGFloat)minimumZoom {
    self.scrollView.minimumZoomScale = minimumZoom;
}

- (CGFloat)maximalZoom {
    return self.scrollView.maximumZoomScale;
}

- (void)setMaximalZoom:(CGFloat)maximalZoom {
    self.scrollView.maximumZoomScale = maximalZoom;
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
