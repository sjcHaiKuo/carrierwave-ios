//
//  CRVRootViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVRootViewController.h"
#import "CRVNetworkManager.h"
#import <MBProgressHUD.h>
#import "UIAlertView+Carrierwave.h"

static NSString * const CRVDemoSegueEdit = @"showEdit";

@interface CRVRootViewController () <CRVImageEditViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic, readwrite) CRVImageAsset *imageAsset;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *pickButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickButtonCenterConstraint;
@property (strong, nonatomic) NSMutableArray * uploadedAssetsArray;

@end

@implementation CRVRootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.uploadedAssetsArray = [NSMutableArray array];
    self.imageView.image = self.imageAsset.image;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:CRVDemoSegueEdit]) {
        CRVImageEditViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.imageAsset = self.imageAsset;
    }
}

#pragma mark - Button actions

- (IBAction)chooseButtonTapped:(UIButton *)sender {
    [self presentChooseViewControllerWithCompletion:nil];
}

- (IBAction)downloadButtonTapped:(UIButton *)sender {
    [self downloadRecentUpload];
}

- (IBAction)closeButtonTapped:(id)sender {
    [self hideMenu];
}

- (IBAction)editButtonTapped:(id)sender {
    [self performSegueWithIdentifier:CRVDemoSegueEdit sender:self];
}

- (IBAction)uploadButtonTapped:(id)sender {
    if (!self.imageAsset) {
        NSLog(@"No image selected");
        [self presentChooseViewControllerWithCompletion:nil];
        return;
    }
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = NSLocalizedString(@"Uploading", nil);
    CRVNetworkManager *networkManager = [CRVNetworkManager sharedManager];
    [networkManager uploadAsset:self.imageAsset progress:^(double progress) {
        hud.progress = (float)progress;
    } completion:^(CRVUploadInfo *info, NSError *error) {
        if (error) {
            [[UIAlertView crv_showAlertWithError:error] show];
            [hud hide:YES];
        } else {
            [self.uploadedAssetsArray addObject:info];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"Completed", nil);
            [hud hide:YES afterDelay:1.5];
        }
    }];
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
    if (!self.imageAsset) {
        [self hideMenu];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    if (chosenImage) {
        self.imageAsset = [[CRVImageAsset alloc] initWithImage:chosenImage];
        [self showMenu];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

- (void)downloadRecentUpload {
    if (!self.uploadedAssetsArray || !self.uploadedAssetsArray.count) {
        NSLog(@"No recent uploads");
        [self presentChooseViewControllerWithCompletion:nil];
        return;
    }
    
    CRVUploadInfo *assetUploadInfo = [self.uploadedAssetsArray firstObject];
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Downloading";
    CRVNetworkManager *networkManager = [CRVNetworkManager sharedManager];
    [networkManager downloadAssetWithIdentifier:assetUploadInfo.assetIdentifier progress:^(double progress) {
        hud.progress = (float)progress;
    } completion:^(CRVImageAsset *asset, NSError *error) {
        [hud hide:YES];
        if (error) {
            [[UIAlertView crv_showAlertWithError:error] show];
        } else {
            self.imageAsset = asset;
            [self showMenu];
        }
    }];
}

- (void)showMenu {
    self.imageView.hidden = NO;
    self.menuView.hidden = NO;
    self.pickButton.hidden = YES;
    self.downloadButton.hidden = YES;
}

- (void)hideMenu {
    self.imageView.hidden = YES;
    self.menuView.hidden = YES;
    if (self.uploadedAssetsArray.count) {
        self.pickButtonCenterConstraint.constant = self.downloadButton.bounds.size.width/2.0;
        self.downloadButton.hidden = NO;
    } else {
        self.pickButtonCenterConstraint.constant = 0.0;
    }
    self.pickButton.hidden = NO;
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
    }
}

@end
