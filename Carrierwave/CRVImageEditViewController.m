//
//  CRVImageEditViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CRVImageAsset.h"
#import "CRVImageEditGlassView.h"
#import "CRVImageEditScrollView.h"
#import "CRVImageEditViewController.h"

@interface CRVImageEditViewController ()

@property (strong, nonatomic, readwrite) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic, readwrite) UIBarButtonItem *doneBarButtonItem;

@property (strong, nonatomic) UIToolbar *bottomToolbar;
@property (strong, nonatomic) CRVImageEditScrollView *scrollView;

@property (assign, nonatomic, readonly) CGFloat imageRatio;

@property (strong, nonatomic, readonly) UIImage *editedImage;

@end

#pragma mark -

@implementation CRVImageEditViewController

#pragma mark - Object lifecycle

- (instancetype)initWithImageAsset:(CRVImageAsset *)asset {
    self = [super initWithNibName:nil bundle:nil];
    if (self == nil) return nil;

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

    self.view.backgroundColor = [UIColor colorWithWhite:(CGFloat)0.1 alpha:1];

    self.bottomToolbar = [[UIToolbar alloc] init];
    self.bottomToolbar.translucent = NO;
    self.bottomToolbar.barTintColor = self.view.backgroundColor;
    [self.view addSubview:self.bottomToolbar];

    [self updateViewsBasedOnImageAsset];

    [self.view setNeedsUpdateConstraints];

}

- (void)updateViewsBasedOnImageAsset {

    if (self.imageAsset != nil && self.scrollView == nil) {
        self.scrollView = [[CRVImageEditScrollView alloc] init];
        self.scrollView.image = self.imageAsset.image;
        self.scrollView.glassView.maskColor = [self.view.backgroundColor colorWithAlphaComponent:(CGFloat)0.9];
        self.scrollView.glassView.glassRatio = self.imageRatio;
        self.scrollView.glassView.glassInsets = UIEdgeInsetsMake(10, 10, 54, 10);
        [self.view insertSubview:self.scrollView belowSubview:self.bottomToolbar];
    } else if (self.imageAsset == nil && self.scrollView != nil) {
        [self.scrollView removeFromSuperview];
        self.scrollView = nil;
    }

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

    [self.bottomToolbar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.equalTo(self.view);
    }];

    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
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
        CRVImageAsset *asset = [[CRVImageAsset alloc] initWithImage:self.editedImage];
        [self.delegate imageEditViewController:self didFinishEditingWithImageAsset:asset];
    }
}

#pragma mark - Public property accessors

- (void)setImageAsset:(CRVImageAsset *)imageAsset {
    if (![self.imageAsset isEqual:imageAsset]) {
        _imageAsset = imageAsset;
        [self updateViewsBasedOnImageAsset];
        self.scrollView.image = _imageAsset.image;
        self.scrollView.glassView.glassRatio = self.imageRatio;
        [self.view setNeedsUpdateConstraints];
        [self.view setNeedsLayout];
    }
}

- (CGFloat)maximalZoom {
    return self.scrollView.maximalScale;
}

- (void)setMaximalZoom:(CGFloat)maximalZoom {
    self.scrollView.maximalScale = maximalZoom;
}

#pragma mark - Private property accessors

- (CGFloat)imageRatio {
    return self.imageAsset.image.size.width / self.imageAsset.image.size.height;
}

- (UIImage *)editedImage {
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:self.imageAsset.image.CGImage];
    ciImage = [ciImage imageByCroppingToRect:self.scrollView.imageExtent];
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:ciImage fromRect:ciImage.extent];
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage]; CFRelease(cgImage);
    return uiImage;
}

#pragma mark - Default bar button item colors

+ (UIColor *)defaultCancelBarButtonItemTintColor {
    return [UIColor colorWithHue:(CGFloat)0.588 saturation:(CGFloat)0.979 brightness:(CGFloat)0.986 alpha:1];
}

+ (UIColor *)defaultDoneBarButtonItemTintColor {
    return [UIColor colorWithHue:(CGFloat)0.124 saturation:(CGFloat)0.710 brightness:(CGFloat)0.963 alpha:1];
}

@end
