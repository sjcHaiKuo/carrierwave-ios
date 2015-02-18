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

@interface CRVCollectionViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, CRVImageEditViewControllerDelegate, CRVManagerDelegate>

@property (strong, nonatomic) NSMutableArray *contentArray;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) CRVManager *manager;

@end

@implementation CRVCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.collectionView.frame) - 20.f, 200.f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
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

#pragma mark - CRVImageEditViewControllerDelegate methods

- (void)imageEditViewControllerDidCancelEditing:(CRVImageEditViewController *)ctrl {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageEditViewController:(CRVImageEditViewController *)ctrl didFinishEditingWithImageAsset:(CRVImageAsset *)asset {
    
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

- (IBAction)addBarButtonDidClick:(UIBarButtonItem *)sender {
    
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

    CRVImageEditViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CRVImageEditViewControllerIdentifier"];
    controller.delegate = self;
    controller.imageAsset = model.asset;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)createAssetModelForImage:(UIImage *)image {
    
    CRVImageAsset *asset = [[CRVImageAsset alloc] initWithImage:image];
    CRVAssetModel *assetModel = [[CRVAssetModel alloc] initWithImageAsset:asset];
    [self.contentArray addObject:assetModel];
}

@end
