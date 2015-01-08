//
//  CRVRootViewController.m
//  
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVRootViewController.h"

@interface CRVRootViewController () <CRVImageEditViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (strong, nonatomic, readwrite) CRVImageAsset *imageAsset;

@end

#pragma mark -

@implementation CRVRootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.imageAsset.image;
    self.editButton.enabled = self.imageAsset != nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showEdit"]) {
        CRVImageEditViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.imageAsset = self.imageAsset;
    }
}

#pragma mark - Button actions

- (IBAction)chooseButtonTapped:(UIButton *)sender {
    [self presentChooseViewControllerWithCompletion:nil];
}

#pragma mark - Choose view controller management

- (void)presentChooseViewControllerWithCompletion:(void (^)())completion {
    UIImagePickerControllerSourceType requestedType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if ([UIImagePickerController isSourceTypeAvailable:requestedType]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = requestedType;
        controller.mediaTypes = [[NSArray alloc] initWithObjects:(__bridge_transfer NSString *)kUTTypeImage, nil];
        controller.allowsEditing = NO;
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:completion];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    if (chosenImage != nil) {
        self.imageAsset = [[CRVImageAsset alloc] initWithImage:chosenImage];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Edit view controller management

- (void)imageEditViewControllerDidCancelEditing:(CRVImageEditViewController *)ctrl {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageEditViewController:(CRVImageEditViewController *)ctrl didFinishEditingWithImageAsset:(CRVImageAsset *)asset {
    self.imageAsset = asset;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private property accessors

- (void)setImageAsset:(CRVImageAsset *)imageAsset {
    if (![_imageAsset isEqual:imageAsset]) {
        _imageAsset = imageAsset;
        self.imageView.image = _imageAsset.image;
        self.editButton.enabled = _imageAsset != nil;
    }
}

@end
