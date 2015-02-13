//
//  CRVImageEditViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CRVImageEditViewController.h"
#import "CRVImageAsset.h"
#import "CRVImageEditToolbarView.h"
#import "CRVScalableView.h"

static const CGFloat kDefaultMinimumZoom = 0.1f;
static const CGFloat kDefaultMaximalZoom = 2.0f;

@interface CRVImageEditViewController() <CRVScalableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *editedImageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic, readwrite) CRVScalableView *cropView;

@property (strong, nonatomic) UISlider *rotationSlider;
@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *ratioBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *doneBarButtonItem;

@property (strong , nonatomic) UIImage *finalImage;

@end

@implementation CRVImageEditViewController

#pragma mark - Object lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) {
        return nil;
    }
    
    self.imageAsset = asset;
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithImageAsset:nil];
}

- (instancetype)init {
    return [self initWithImageAsset:nil];
}

#pragma mark - View lifecycle

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.cropView.frame = CGRectMake(self.view.frame.size.width / 2 - self.cropView.frame.size.width / 2,
                                     self.view.frame.size.height / 2 - self.cropView.frame.size.height / 2,
                                     200,
                                     200);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
    
    [self loadViews];
    [self updateViewsBasedOnImageAsset];
    [self updateViewConstraints];
}

- (void)loadViews {
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
    
    if (self.settingsToolbar == nil) {
        self.settingsToolbar = [[CRVImageEditToolbarView alloc] init];
    }
    
    self.settingsToolbar.translucent = NO;
    self.settingsToolbar.barTintColor = [self.settingsToolbar toolbarBackgroundColor];
    
    [self.view addSubview:self.settingsToolbar];
    
    self.rotationSlider = [self.settingsToolbar rotationSlider];
    self.cancelBarButtonItem = [self.settingsToolbar cancelBarButtonItem];
    self.ratioBarButtonItem = [self.settingsToolbar ratioBarButtonItem];
    self.doneBarButtonItem = [self.settingsToolbar doneBarButtonItem];
    
    UIBarButtonSystemItem spaceType = UIBarButtonSystemItemFlexibleSpace;
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:spaceType target:nil action:nil];
    
    self.settingsToolbar.items = @[self.cancelBarButtonItem,
                                   spaceItem,
                                   self.ratioBarButtonItem,
                                   spaceItem,
                                   self.doneBarButtonItem];
    
    [self.rotationSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.rotationSlider];
    
    self.cancelBarButtonItem.target = self;
    self.cancelBarButtonItem.action = @selector(cancelButtonTapped:);
    
    self.ratioBarButtonItem.target = self;
    self.ratioBarButtonItem.action = @selector(ratioButtonTapped:);
    
    self.doneBarButtonItem.target = self;
    self.doneBarButtonItem.action = @selector(doneButtonTapped:);
}

- (void)updateViewsBasedOnImageAsset {
    BOOL doesImageAssetExist = self.imageAsset == nil ? NO : YES;
    
    self.cropView.hidden = !doesImageAssetExist;
    self.ratioBarButtonItem.enabled = doesImageAssetExist;
    self.doneBarButtonItem.enabled = doesImageAssetExist;
}

- (void)updateViewConstraints {
    
    [self.settingsToolbar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.equalTo(self.view);
    }];
    
    [self.rotationSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 20, 55, 20);
        
        make.left.equalTo(self.view).with.offset(padding.left);
        make.right.equalTo(self.view).with.offset(-padding.right);
        make.bottom.equalTo(self.view).with.offset(-padding.bottom);
    }];
    
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.right.equalTo(self.view);
        make.bottom.equalTo(self.settingsToolbar);
    }];
    
    [self.editedImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Slider value changes

- (void)sliderValueChanged:(UISlider *)sender {
    CGFloat rads = (CGFloat)M_PI * sender.value / 180.f;
    self.scrollView.transform = CGAffineTransformMakeRotation(rads);
}

#pragma mark - Button actions

- (void)cancelButtonTapped:(UIBarButtonItem *)sender {
    if ([self.delegate respondsToSelector:@selector(imageEditViewControllerDidCancelEditing:)]) {
        [self.delegate imageEditViewControllerDidCancelEditing:self];
    }
}

- (void)ratioButtonTapped:(UIBarButtonItem *)sender {
    UIAlertController *ratioAlertController = [self ratioAlertController];
    [self presentViewController:ratioAlertController animated:YES completion:^{}];
}

- (void)doneButtonTapped:(UIBarButtonItem *)sender {
    if ([self.delegate respondsToSelector:@selector(imageEditViewController:didFinishEditingWithImageAsset:)]) {
        UIImage *finalImage = self.finalImage;
        CRVImageAsset *asset = [[CRVImageAsset alloc] initWithImage:finalImage];
        [self.delegate imageEditViewController:self didFinishEditingWithImageAsset:asset];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.editedImageView;
}

#pragma mark - Public property accessors

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

#pragma mark - Private property accessors

- (UIImage *)finalImage {
    
    self.cropView.hidden = YES;
    self.rotationSlider.hidden = YES;
    self.settingsToolbar.hidden = YES;
    
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
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef scale:sourceImage.scale orientation:sourceImage.imageOrientation];
    CGImageRelease(imageRef);
    
    return finalImage;
}

- (UIAlertController *)ratioAlertController {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select crop frame ratio:" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[self actionWithTitle:@"None (free form)" animateSize:CGSizeMake(200.f, 200.f) ratioEnabled:NO]];
    [alertController addAction:[self actionWithTitle:@"1:1" animateSize:CGSizeMake(200.f, 200.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:@"1:2" animateSize:CGSizeMake(120.f, 240.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:@"2:1" animateSize:CGSizeMake(240.f, 120.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:@"3:4" animateSize:CGSizeMake(150.f, 200.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:@"4:3" animateSize:CGSizeMake(200.f, 150.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:@"9:16" animateSize:CGSizeMake(90.f, 160.f) ratioEnabled:YES]];
    [alertController addAction:[self actionWithTitle:@"16:9" animateSize:CGSizeMake(160.f, 90.f) ratioEnabled:YES]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
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
