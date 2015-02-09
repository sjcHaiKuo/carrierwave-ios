//
//  CRVImageEditViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CRVImageAsset.h"
#import "CRVScalableView.h"
#import "CRVImageEditViewController.h"

@interface CRVImageEditViewController() <CRVScalableViewDelegate>

@property (strong, nonatomic) UIImageView *editedImageView;

@property (assign, nonatomic, readonly) CGFloat imageRatio;

@property (strong, nonatomic) CRVScalableView *cropView;

@property (strong, nonatomic) UIToolbar *bottomToolbar;
@property (strong, nonatomic, readwrite) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic, readwrite) UIBarButtonItem *doneBarButtonItem;

@end

#pragma mark -

@implementation CRVImageEditViewController

#pragma mark - Object lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) {
        return nil;
    }
    
    self.imageAsset = asset;
    self.maximalZoom = 3.0;
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithImageAsset:nil];
}

- (instancetype)init {
    return [self initWithImageAsset:nil];
}

#pragma mark - View lifecycle

- (void)awakeFromNib {
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] init];
    self.cancelBarButtonItem.title = @"Cancel";
    self.cancelBarButtonItem.style = UIBarButtonItemStylePlain;
    self.cancelBarButtonItem.tintColor = [[self class] defaultCancelBarButtonItemTintColor];
    self.cancelBarButtonItem.target = self;
    self.cancelBarButtonItem.action = @selector(cancelButtonTapped:);
    
    self.doneBarButtonItem = [[UIBarButtonItem alloc] init];
    self.doneBarButtonItem.title = @"Done";
    self.doneBarButtonItem.style = UIBarButtonItemStyleDone;
    self.doneBarButtonItem.tintColor = [[self class] defaultDoneBarButtonItemTintColor];
    self.doneBarButtonItem.target = self;
    self.doneBarButtonItem.action = @selector(doneButtonTapped:);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)loadView {
    
    [super loadView];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    self.editedImageView = [[UIImageView alloc] initWithImage:self.imageAsset.image];
    self.editedImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.editedImageView];
    
    self.cropView = [[CRVScalableView alloc] init];
    self.cropView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1f];
    self.cropView.borderView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5f];
    self.cropView.opaque = NO;
    self.cropView.delegate = self;
    [self.view addSubview:self.cropView];
    
    self.bottomToolbar = [[UIToolbar alloc] init];
    self.bottomToolbar.translucent = NO;
    self.bottomToolbar.barTintColor = self.view.backgroundColor;
    [self.view addSubview:self.bottomToolbar];
    
    [self updateViewsBasedOnImageAsset];
    
    [self updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.cropView.frame = CGRectMake(50, 50, 200, 200);
}

- (void)updateViewsBasedOnImageAsset {
    self.cropView.hidden = self.imageAsset == nil;
    self.doneBarButtonItem.enabled = self.imageAsset != nil;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonSystemItem spaceType = UIBarButtonSystemItemFlexibleSpace;
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:spaceType target:nil action:nil];
    
    self.bottomToolbar.items = @[
                                 self.cancelBarButtonItem,
                                 spaceItem,
                                 self.doneBarButtonItem,
                                 ];
}

- (void)updateViewConstraints {
    
    [self.editedImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        
        UIEdgeInsets padding = UIEdgeInsetsMake(20, 20, 20, 20);
        make.edges.equalTo(self.view).with.insets(padding);
    }];
    
    [self.bottomToolbar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.equalTo(self.view);
    }];
    
    [super updateViewConstraints];
    
}

#pragma mark - Button actions

- (void)cancelButtonTapped:(UIBarButtonItem *)sender {
    if ([self.delegate respondsToSelector:@selector(imageEditViewControllerDidCancelEditing:)]) {
        [self.delegate imageEditViewControllerDidCancelEditing:self];
    }
}

- (void)doneButtonTapped:(UIBarButtonItem *)sender {
    if ([self.delegate respondsToSelector:@selector(imageEditViewController:didFinishEditingWithImageAsset:)]) {
        
        UIImage *finalImage = [self imageWithView:self.cropView];
        
        CRVImageAsset *asset = [[CRVImageAsset alloc] initWithImage:finalImage];
        [self.delegate imageEditViewController:self didFinishEditingWithImageAsset:asset];
    }
}

#pragma mark - Public property accessors

- (void)setImageAsset:(CRVImageAsset *)imageAsset {
    if (![self.imageAsset isEqual:imageAsset]) {
        _imageAsset = imageAsset;
        [self updateViewsBasedOnImageAsset];
    }
}

- (CGFloat)maximalZoom {
    // return self.scrollView.maximalScale;
    return 2.0; // not needed anymore?
}

- (void)setMaximalZoom:(CGFloat)maximalZoom {
    // self.scrollView.maximalScale = maximalZoom;
    // like above?
}

#pragma mark - Private property accessors

- (CGFloat)imageRatio {
    return self.imageAsset.image.size.width / self.imageAsset.image.size.height;
}

- (UIImage *)imageWithView:(UIView *)view {
    
    self.cropView.hidden = YES;
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:YES];
    UIImage *sourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([sourceImage CGImage], self.cropView.frame);
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef
                                              scale:sourceImage.scale
                                        orientation:sourceImage.imageOrientation];
    CGImageRelease(imageRef);
    
    return finalImage;
}

#pragma mark - Default bar button item colors

+ (UIColor *)defaultCancelBarButtonItemTintColor {
    return [UIColor colorWithHue:(CGFloat)0.588 saturation:(CGFloat)0.979 brightness:(CGFloat)0.986 alpha:1];
}

+ (UIColor *)defaultDoneBarButtonItemTintColor {
    return [UIColor colorWithHue:(CGFloat)0.124 saturation:(CGFloat)0.710 brightness:(CGFloat)0.963 alpha:1];
}

@end
