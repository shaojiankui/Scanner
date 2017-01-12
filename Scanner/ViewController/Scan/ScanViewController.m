
//
//  ScanViewController.m
//  Scanner
//
//  Created by Jakey on 15/8/17.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import "ScanViewController.h"
#import "JKAlert.h"
#define SCANRECTWIDTH 200
@interface ScanViewController ()

@end

@implementation ScanViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(applicationWillEnterForeground:)   name:UIApplicationWillEnterForegroundNotification  object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self    selector:@selector(applicationDidEnterBackground:)  name:UIApplicationDidEnterBackgroundNotification  object:nil];
    
    
    CGRect rect = CGRectMake(([UIScreen mainScreen].bounds.size.width-SCANRECTWIDTH)/2, ([UIScreen mainScreen].bounds.size.height-SCANRECTWIDTH)/2, SCANRECTWIDTH, SCANRECTWIDTH);
    self.scanRectView.scanRect = rect;
    
    //扫描线
    _scanLayer = [[UIView alloc] init];
    _scanLayer.backgroundColor = [UIColor greenColor];
    [self.scanRectView addSubview:_scanLayer];
    [self moveScanLayer];
    [self start];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)start
{
    // 1. 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 2. 设置输入
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        [JKAlert showMessage:@"开启摄像头失败"];
        return;
    }

    // 3. 设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 3.1 设置输出的代理
    // 说明：使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //    [output setMetadataObjectsDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    // 4. 拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 添加session的输入和输出
    [session addInput:input];
    [session addOutput:output];
    //使用1080p的图像输出
    session.sessionPreset = AVCaptureSessionPreset1920x1080;
    // 4.1 设置输出的格式
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    [output setMetadataObjectTypes:[output availableMetadataObjectTypes]];
    
    // 5. 设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    // 5.1 设置preview图层的属性
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 5.2 设置preview图层的大小
    preview.frame = [UIScreen mainScreen].bounds;
 
    self.previewLayer = preview;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
  
    self.session = session;
    
  
    //rectOfInterest 不可以直接在设置 metadataOutput 时接着设置，而需要在这个 AVCaptureInputPortFormatDescriptionDidChangeNotification 通知里设置，否则 metadataOutputRectOfInterestForRect: 转换方法会返回 (0, 0, 0, 0)
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock: ^(NSNotification *_Nonnull note) {
                                                      AVCaptureMetadataOutput *output = self.session.outputs.firstObject;
                                                      output.rectOfInterest = [self.previewLayer metadataOutputRectOfInterestForRect:self.scanRectView.scanRect];

                                                  }];
}

- (void)moveScanLayer
{
    _scanLayer.frame =  CGRectMake(self.scanRectView.scanRect.origin.x,self.scanRectView.scanRect.origin.y,SCANRECTWIDTH, 1);
    _scanLayer.hidden = NO;
    [UIView animateWithDuration:2 animations:^{
        _scanLayer.frame =  CGRectMake(self.scanRectView.scanRect.origin.x,self.scanRectView.scanRect.origin.y+200,SCANRECTWIDTH, 1);
//        _scanLayer.transform = CGAffineTransformMakeTranslation(0, self.scanRectView.scanRect.size.height+1);
    } completion:^(BOOL finished) {
        _scanLayer.frame =  CGRectMake(self.scanRectView.scanRect.origin.x,self.scanRectView.scanRect.origin.y,SCANRECTWIDTH, 1);
        _scanLayer.hidden = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moveScanLayer) object:nil];
        [self performSelector:@selector(moveScanLayer) withObject:nil afterDelay:0.1];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.session startRunning];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection

{
   
    NSLog(@"%@", metadataObjects);
    if (metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        if(_finishingBlock &&[obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]){
            [self.session stopRunning];
            dispatch_async(dispatch_get_main_queue(), ^{
                _finishingBlock(obj.stringValue);
            });
        }
        
    }
}

- (void)turnLight:(BOOL)open
{
    _lighting = open;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (open) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}
- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self.session  startRunning];
}
- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self.session stopRunning];
}

- (void)finishingBlock:(FinishingBlock)finishingBlock{
    _finishingBlock = [finishingBlock copy];
}

@end
