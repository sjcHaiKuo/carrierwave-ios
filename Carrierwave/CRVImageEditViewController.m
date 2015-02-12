//
//  CRVImageEditViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CRVImageAsset.h"
#import "CRVScalableView.h"
#import "CRVImageEditViewController.h"

const CGFloat kDefaultMinimumZoom = 0.1;
const CGFloat kDefaultMaximalZoom = 2.0;

@interface CRVImageEditViewController() <CRVScalableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *editedImageView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) CRVScalableView *cropView;

@property (strong, nonatomic, readwrite) UISlider *rotationSlider;

@property (strong, nonatomic) UIToolbar *bottomToolbar;
@property (strong, nonatomic, readwrite) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic, readwrite) UIBarButtonItem *ratioBarButtonItem;
@property (strong, nonatomic, readwrite) UIBarButtonItem *doneBarButtonItem;

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

- (void)awakeFromNib {
    self.rotationSlider = [[UISlider alloc] init];
    self.rotationSlider.minimumValue = -90.0f;
    self.rotationSlider.maximumValue = 90.0f;
    self.rotationSlider.value = 0;
    self.rotationSlider.continuous = YES;
    [self.rotationSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.cancelBarButtonItem = [[UIBarButtonItem alloc] init];
    self.cancelBarButtonItem.title = @"Cancel";
    self.cancelBarButtonItem.style = UIBarButtonItemStylePlain;
    self.cancelBarButtonItem.tintColor = [[self class] defaultCancelBarButtonItemTintColor];
    self.cancelBarButtonItem.target = self;
    self.cancelBarButtonItem.action = @selector(cancelButtonTapped:);
    
    self.ratioBarButtonItem = [[UIBarButtonItem alloc] init];
    self.ratioBarButtonItem.title = @"Select crop ratio";
    self.ratioBarButtonItem.style = UIBarButtonItemStylePlain;
    self.ratioBarButtonItem.tintColor = [[self class] defaultRatioBarButtonItemTintColor];
    self.ratioBarButtonItem.target = self;
    self.ratioBarButtonItem.action = @selector(ratioButtonTapped:);
    
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
    
    [self.view addSubview:self.rotationSlider];
    
    self.bottomToolbar = [[UIToolbar alloc] init];
    self.bottomToolbar.translucent = NO;
    self.bottomToolbar.barTintColor = self.view.backgroundColor;
    [self.view addSubview:self.bottomToolbar];
    
    self.minimumZoom = kDefaultMinimumZoom;
    self.maximalZoom = kDefaultMaximalZoom;
    
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
    BOOL doesImageAssetExist = self.imageAsset == nil ? NO : YES;
    
    self.cropView.hidden = !doesImageAssetExist;
    self.ratioBarButtonItem.enabled = doesImageAssetExist;
    self.doneBarButtonItem.enabled = doesImageAssetExist;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonSystemItem spaceType = UIBarButtonSystemItemFlexibleSpace;
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:spaceType target:nil action:nil];
    
    self.bottomToolbar.items = @[self.cancelBarButtonItem,
                                 spaceItem,
                                 self.ratioBarButtonItem,
                                 spaceItem,
                                 self.doneBarButtonItem];
}

- (void)updateViewConstraints {
    
    [self.bottomToolbar mas_updateConstraints:^(MASConstraintMaker *make) {
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
        make.bottom.equalTo(self.bottomToolbar).with.offset(-40);
    }];
    
    [self.editedImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Slider value changes

- (void)sliderValueChanged:(UISlider *)sender {
    CGFloat rads = M_PI * sender.value / 180;
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
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef
                                              scale:sourceImage.scale
                                        orientation:sourceImage.imageOrientation];
    CGImageRelease(imageRef);
    
    return finalImage;
}

- (UIAlertController *)ratioAlertController {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select crop frame ratio:" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"None (free form)"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        self.cropView.ratioEnabled = NO;
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"1:1"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self.cropView animateToSize:CGSizeMake(200, 200) completion:^(BOOL finished) {
            self.cropView.ratioEnabled = YES;
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"1:2"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self.cropView animateToSize:CGSizeMake(120, 240) completion:^(BOOL finished) {
            self.cropView.ratioEnabled = YES;
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"2:1"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self.cropView animateToSize:CGSizeMake(240, 120) completion:^(BOOL finished) {
            self.cropView.ratioEnabled = YES;
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"3:4"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self.cropView animateToSize:CGSizeMake(150, 200) completion:^(BOOL finished) {
            self.cropView.ratioEnabled = YES;
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"4:3"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self.cropView animateToSize:CGSizeMake(200, 150) completion:^(BOOL finished) {
            self.cropView.ratioEnabled = YES;
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"9:16"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self.cropView animateToSize:CGSizeMake(90, 160) completion:^(BOOL finished) {
            self.cropView.ratioEnabled = YES;
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"16:9"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        [self.cropView animateToSize:CGSizeMake(160, 90) completion:^(BOOL finished) {
            self.cropView.ratioEnabled = YES;
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {}]];
    
    return alertController;
}

#pragma mark - Default bar button item colors

+ (UIColor *)defaultCancelBarButtonItemTintColor {
    return [[UIColor redColor] colorWithAlphaComponent:0.8f];
}

+ (UIColor *)defaultRatioBarButtonItemTintColor {
    return [[UIColor blueColor] colorWithAlphaComponent:0.8f];
}

+ (UIColor *)defaultDoneBarButtonItemTintColor {
    return [[UIColor yellowColor] colorWithAlphaComponent:0.8f];
}

@end
