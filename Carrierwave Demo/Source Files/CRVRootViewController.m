//
//  CRVRootViewController.m
//
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVRootViewController.h"
#import "CRVNetworkManager.h"
#import <SVProgressHUD.h>
#import "UIAlertView+Carrierwave.h"
#import <WYPopoverController.h>

static NSString * const CRVDemoSegueEdit = @"showEdit";
static NSString * const CRVDemoDefaultTableCell = @"defaultCell";
static CGFloat const CRVDemoDefaultTableCellHeight = 40.0;
static CGFloat const CRVDemoDefaultPopoverWidth = 200.0;
static NSInteger const CRVDemoAssetDeleteButtonOffset = 1000;

@interface CRVRootViewController () <CRVImageEditViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic, readwrite) CRVImageAsset *imageAsset;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *pickButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickButtonCenterConstraint;
@property (strong, nonatomic) NSMutableArray * uploadedAssetsArray;
@property (strong, nonatomic) WYPopoverController *assetsPopoverController;

@end

@implementation CRVRootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.uploadedAssetsArray = [[NSMutableArray alloc] init];
    self.imageView.image = self.imageAsset.image;
}

#pragma mark - Custom property accessors

- (void)setImageAsset:(CRVImageAsset *)imageAsset {
    if (![_imageAsset isEqual:imageAsset]) {
        _imageAsset = imageAsset;
        self.imageView.image = _imageAsset.image;
    }
}

#pragma mark - Segues preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:CRVDemoSegueEdit]) {
        CRVImageEditViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.imageAsset = self.imageAsset;
    }
}

#pragma mark - Action handlers

- (IBAction)chooseButtonTapped:(UIButton *)sender {
    [self presentImageChooserController];
}

- (IBAction)downloadButtonTapped:(UIButton *)sender {
    self.assetsPopoverController.popoverContentSize = [self sizeForAssetUploadPopover];
    [self.assetsPopoverController presentPopoverFromRect:sender.frame inView:self.view
                                permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
}

- (IBAction)closeButtonTapped:(id)sender {
    [self hideMenu];
}

- (IBAction)editButtonTapped:(id)sender {
    [self performSegueWithIdentifier:CRVDemoSegueEdit sender:self];
}

- (IBAction)uploadButtonTapped:(id)sender {
    [self uploadAsset:self.imageAsset];
}

#pragma mark - Choose view controller management

- (void)presentImageChooserController {
    UIImagePickerControllerSourceType requestedType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    if (![UIImagePickerController isSourceTypeAvailable:requestedType]) {
        return;
    }
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = requestedType;
    controller.mediaTypes = @[(__bridge_transfer NSString *)kUTTypeImage];
    controller.allowsEditing = NO;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
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

#pragma mark - Assets actions

- (void)uploadAsset:(CRVImageAsset *)imageAsset {
    if (!imageAsset) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No image asset to upload", nil)];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Uploading", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[CRVNetworkManager sharedManager] uploadAsset:imageAsset progress:^(double progress) {
        [SVProgressHUD showProgress:(float)progress status:NSLocalizedString(@"Uploading", nil)];
    } completion:^(CRVUploadInfo *info, NSError *error) {
        if (error) {
            [[UIAlertView crv_alertWithError:error] show];
            [SVProgressHUD dismiss];
        } else {
            [self.uploadedAssetsArray addObject:info];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Completed", nil)];
        }
    }];
}

- (void)downloadAssetWithUploadInfo:(CRVUploadInfo *)uploadInfo {
    if (!uploadInfo) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No upload info", nil)];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Downloading", nil) maskType:SVProgressHUDMaskTypeBlack];
    [[CRVNetworkManager sharedManager] downloadAssetWithIdentifier:uploadInfo.assetIdentifier progress:^(double progress) {
        [SVProgressHUD showProgress:(float)progress status:NSLocalizedString(@"Downloading", nil)];
    } completion:^(CRVImageAsset *asset, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [[UIAlertView crv_alertWithError:error] show];
        } else {
            self.imageAsset = asset;
            [self showMenu];
        }
    }];
}

- (void)deleteAssetWithUploadInfo:(CRVUploadInfo *)uploadInfo {
    if (!uploadInfo) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"No upload info", nil)];
        return;
    }
    
    NSInteger assetIndex = [self.uploadedAssetsArray indexOfObject:uploadInfo];
    CRVNetworkManager *networkManager = [CRVNetworkManager sharedManager];
    [networkManager deleteAssetWithIdentifier:uploadInfo.assetIdentifier completion:^(BOOL success, NSError *error) {
        [self.uploadedAssetsArray removeObject:uploadInfo];
        CGSize popoverSize = [self sizeForAssetUploadPopover];
        if (popoverSize.height == 0) {
            self.assetsPopoverController.popoverContentSize = CGSizeZero;
            [self.assetsPopoverController dismissPopoverAnimated:YES];
            [self hideMenu];
        } else {
            self.assetsPopoverController.popoverContentSize = [self sizeForAssetUploadPopover];
            UITableViewController *tableViewController = (UITableViewController *)self.assetsPopoverController.contentViewController;
            [tableViewController.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:assetIndex inSection:0]]
                                                 withRowAnimation:UITableViewRowAnimationFade];
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
    self.pickButton.hidden = NO;
    
    if (self.uploadedAssetsArray.count) {
        self.pickButtonCenterConstraint.constant = self.downloadButton.bounds.size.width / (CGFloat) 2.0;
        self.downloadButton.hidden = NO;
    } else {
        self.pickButtonCenterConstraint.constant = 0.0;
        self.downloadButton.hidden = YES;
    }
}

#pragma mark - Image Edit View Delegate

- (void)imageEditViewControllerDidCancelEditing:(CRVImageEditViewController *)ctrl {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageEditViewController:(CRVImageEditViewController *)ctrl didFinishEditingWithImageAsset:(CRVImageAsset *)asset {
    self.imageAsset = asset;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Assets Popover

- (WYPopoverController *)assetsPopoverController {
    if (!_assetsPopoverController) {
        UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        tableViewController.tableView.dataSource = self;
        tableViewController.tableView.delegate = self;
        [tableViewController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CRVDemoDefaultTableCell];
        _assetsPopoverController = [[WYPopoverController alloc] initWithContentViewController:tableViewController];
        _assetsPopoverController.popoverContentSize = CGSizeMake(100, 100);
    }
    return _assetsPopoverController;
}

- (CGSize)sizeForAssetUploadPopover {
    if (self.uploadedAssetsArray) {
        return CGSizeMake(CRVDemoDefaultPopoverWidth, self.uploadedAssetsArray.count*CRVDemoDefaultTableCellHeight);
    }
    return CGSizeZero;
}

#pragma mark - UITableView Helper

- (UIButton *)buttonForDeletionOfAssetAtIndex:(NSInteger)assetIndex {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 25, 25);
    button.tag = CRVDemoAssetDeleteButtonOffset + assetIndex;
    [button addTarget:self action:@selector(assetDeleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (IBAction)assetDeleteButtonTapped:(UIButton *)sender {
    NSInteger assetIndex = sender.tag - CRVDemoAssetDeleteButtonOffset;
    [self animateDeletionForAssetAtIndex:assetIndex];
    CRVUploadInfo *uploadInfo = self.uploadedAssetsArray[assetIndex];
    [self deleteAssetWithUploadInfo:uploadInfo];
}

- (void)animateDeletionForAssetAtIndex:(NSInteger)assetIndex {
    UITableViewController *tableViewController = (UITableViewController *)self.assetsPopoverController.contentViewController;
    UITableViewCell *cell = [tableViewController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:assetIndex inSection:0]];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                                  UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    activityIndicator.hidesWhenStopped = YES;
    cell.accessoryView = activityIndicator;
}


#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.uploadedAssetsArray ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.uploadedAssetsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CRVDemoDefaultTableCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CRVDemoDefaultTableCell];
    CRVUploadInfo *assetUploadInfo = self.uploadedAssetsArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Asset: %@", assetUploadInfo.assetIdentifier];
    cell.accessoryView = [self buttonForDeletionOfAssetAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self downloadAssetWithUploadInfo:self.uploadedAssetsArray[indexPath.row]];
    [self.assetsPopoverController dismissPopoverAnimated:YES];
}

@end
