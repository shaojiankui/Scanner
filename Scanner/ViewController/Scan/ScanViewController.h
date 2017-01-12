//
//  ScanViewController.h
//  Scanner
//
//  Created by Jakey on 15/8/17.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BaseViewController.h"
#import "ScanView.h"
typedef void (^FinishingBlock)(NSString *string);

@interface ScanViewController : BaseViewController<AVCaptureMetadataOutputObjectsDelegate>
{
    FinishingBlock _finishingBlock;
    UIView *_scanLayer;
}
@property(nonatomic) BOOL lighting;
@property(strong,nonatomic) AVCaptureSession *session;
@property(strong,nonatomic)  AVCaptureVideoPreviewLayer *previewLayer;
@property (weak, nonatomic) IBOutlet ScanView *scanRectView;

- (void)turnLight:(BOOL)open;
- (void)finishingBlock:(FinishingBlock)finishingBlock;
@end
