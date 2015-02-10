//
//  CRVRootViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVRootViewController.h"
#import "CRVNetworkManager.h"
#import <MBProgressHUD.h>

static NSString * const CRVDemoSegueEdit = @"showEdit";

@interface CRVRootViewController () <CRVImageEditViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic, readwrite) CRVImageAsset *imageAsset;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIView *imageChooserView;

@end

@implementation CRVRootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.imageAsset.image;
    self.editButton.enabled = self.imageAsset != nil;
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
    hud.labelText = @"Uploading";
    CRVNetworkManager *networkManager = [CRVNetworkManager sharedManager];
    networkManager.serverURL = [NSURL URLWithString:@"https://carrierwave-ios-backend.herokuapp.com/"];
    [networkManager uploadAsset:self.imageAsset progress:^(double progress) {
        hud.progress = (float)progress;
    } completion:^(CRVUploadInfo *info, NSError *error) {
        [hud hide:YES];
        if (error) {
            [self showAlertWithError:error];
        } else {
            [self showAlertWithInfo:info];
        }
    }];
}

#pragma mark - Alerts

- (void)showAlertWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

- (void)showAlertWithInfo:(CRVUploadInfo *)info {
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", nil) message:info.description delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
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

- (void)showMenu {
    self.imageView.hidden = NO;
    self.menuView.hidden = NO;
    self.imageChooserView.hidden = YES;
}

- (void)hideMenu {
    self.imageView.hidden = YES;
    self.menuView.hidden = YES;
    self.imageChooserView.hidden = NO;
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
