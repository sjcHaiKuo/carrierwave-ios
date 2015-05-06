//
//  CRVCollectionViewController.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 17.02.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVCollectionViewController.h"
#import "CRVCollectionViewCell.h"
#import "CRVManager.h"
#import "CRVAssetModel.h"
#import "UIAlertView+Carrierwave.h"

@class CRVCollectionViewFlowLayout;

NSString *const CRVPhotoAlbumTitle = @"Photo Album";
NSString *const CRVCameraTitle = @"Camera";


@interface CRVCollectionViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, NGRImageEditViewControllerDelegate, CRVManagerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSMutableArray *contentArray;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) CRVManager *manager;

@end

@implementation CRVCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.accessibilityLabel = @"Camera Bar Button";
    self.collectionView.accessibilityLabel = @"Collection View";
    
    self.title = NSLocalizedString(@"Gallery", nil);
    self.contentArray = [NSMutableArray array];
    self.manager = [[CRVManager alloc] init];
    self.manager.delegate = self;
    
    [self createAssetModelForImage:[UIImage imageNamed:@"cookiemonster"]];
    [self.collectionView registerClass:[CRVCollectionViewCell class] forCellWithReuseIdentifier:CRVDemoCollectionViewCellIdentifier];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.contentArray.count;
}

- (CRVCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CRVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CRVDemoCollectionViewCellIdentifier forIndexPath:indexPath];
    CRVAssetModel *model = self.contentArray[indexPath.row];
    
    cell.imageView.image = model.asset.image;
    cell.leftButton.indexPath = indexPath;
    cell.righButton.indexPath = indexPath;
    
    [cell.leftButton addTarget:self action:@selector(cellButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.righButton addTarget:self action:@selector(cellButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL isProcessing = model.isDowloading || model.isUploading;
    [cell showProgress:isProcessing];
    [cell setProgress:model.progress];
    
    if (model.isSuspended) {
        cell.interface = CRVCellInterfaceResumeAndCancel;
    } else if (isProcessing) {
        cell.interface = CRVCellInterfacePauseAndCancel;
    } else if (model.isUploaded) {
        cell.interface = CRVCellInterfaceDeleteAndDownload;
    } else {
        cell.interface = CRVCellInterfaceCropAndUpload;
    }
    
    [cell setButtonsEnabled:!model.isDeleting];
    
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(CRVCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame) - 20.f, 200.f);
}

#pragma mark - CRVManagerDelegate methods

- (void)manager:(CRVManager *)manager didUpdateProgress:(double)progress forModel:(CRVAssetModel *)model {
    CRVCollectionViewCell *cell = [self cellForModel:model];
    [cell setProgress:progress];
}

- (void)manager:(CRVManager *)manager didSucceedProcessAssetForModel:(CRVAssetModel *)model {
    [self reloadCellForModel:model];
}

- (void)manager:(CRVManager *)manager didFailProcessAssetForModel:(CRVAssetModel *)model withError:(NSError *)error {
    [self reloadCellForModel:model];
    [[UIAlertView crv_alertWithError:error] show];
}

#pragma mark - NGRImageEditViewControllerDelegate methods

- (void)imageEditViewControllerDidCancelEditing:(NGRImageEditViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageEditViewController:(NGRImageEditViewController *)controller didFinishEditingWithImageAsset:(CRVImageAsset *)asset {
    
    CRVAssetModel *model = self.contentArray[self.selectedIndexPath.row];
    model.asset = asset;
    
    [self.collectionView reloadItemsAtIndexPaths:@[self.selectedIndexPath]];
    [self dismissViewControllerAnimated:YES completion:nil];
    self.selectedIndexPath = nil;
}

#pragma mark - UIControl methods

- (void)cellButtonDidClick:(CRVButton *)button {
    
    CRVAssetModel *model = self.contentArray[button.indexPath.row];
    
    switch (button.function) {
        case CRVButtonFunctionCrop: {
            self.selectedIndexPath = button.indexPath;
            [self presentCropControllerWithAssetModel:model];
            return;
        }
        case CRVButtonFunctionUpload: {
            [self.manager uploadImageFromModel:model];
            break;
        }
        case CRVButtonFunctionDownload: {
            [self.manager downloadImageFromModel:model];
            break;
        }
        case CRVButtonFunctionPause: {
            [self.manager pauseProcessForModel:model];
            break;
        }
        case CRVButtonFunctionDelete: {
            [self.manager deleteImageFromModel:model];
            [self reloadCellForModel:model];
            break;
        }
        case CRVButtonFunctionCancel: {
            [self.manager cancelProcessForModel:model];
            break;
        }
        case CRVButtonFunctionResume: {
            [self.manager resumeProcessForModel:model];
            break;
        }
            
        default:
            break;
    }
    [self reloadCellForModel:model];
}

- (IBAction)cameraBarButtonDidClick:(UIBarButtonItem *)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(CRVPhotoAlbumTitle, nil), nil];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(CRVCameraTitle, nil)];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(CRVCameraTitle, nil)]) {
        [self presentImagePickerViewControllerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(CRVPhotoAlbumTitle, nil)]) {
        [self presentImagePickerViewControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    if (chosenImage) {
        [self createAssetModelForImage:chosenImage];
        [self.collectionView reloadData];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

- (CRVCollectionViewCell *)cellForModel:(CRVAssetModel *)model {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.contentArray indexOfObject:model] inSection:0];
    return (CRVCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
}

- (void)reloadCellForModel:(CRVAssetModel *)model {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.contentArray indexOfObject:model] inSection:0];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)presentCropControllerWithAssetModel:(CRVAssetModel *)model {

    NGRImageEditViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"NGRImageEditViewControllerIdentifier"];
    controller.delegate = self;
    controller.imageAsset = [model.asset image];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)presentImagePickerViewControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        return;
    }
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = sourceType;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)createAssetModelForImage:(UIImage *)image {
    
    CRVImageAsset *asset = [[CRVImageAsset alloc] initWithImage:image];
    CRVAssetModel *assetModel = [[CRVAssetModel alloc] initWithImageAsset:asset];
    [self.contentArray addObject:assetModel];
}

@end
