//
//  ImagePickerController.m
//  Scanner
//
//  Created by Jakey on 15/2/13.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import "ImagePickerController.h"

@interface ImagePickerController ()

@end

@implementation ImagePickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)cameraSourceType:(UIImagePickerControllerSourceType)source
        onFinishingBlock:(FinishingBlock)finishingBlock
        onCancelingBlock:(CancelingBlock)cancelingBlock;
{
    self.delegate = self;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        source = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    self.sourceType = source;
    _cancelingBlock = [cancelingBlock copy];
    _finishingBlock = [finishingBlock copy];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        if (_finishingBlock) {
            _finishingBlock(picker, info, ((UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage]), ((UIImage *)[info objectForKey:UIImagePickerControllerEditedImage]));
            
        }
    }];

}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (_cancelingBlock) {
            _cancelingBlock();
            
        }
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
