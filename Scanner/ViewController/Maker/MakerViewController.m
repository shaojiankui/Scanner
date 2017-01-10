//
//  MakerViewController.m
//  Scanner
//
//  Created by Jakey on 15/8/21.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import "MakerViewController.h"
#import "JKAlert.h"
@interface MakerViewController ()

@end

@implementation MakerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.qrcode.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
}

+(UIImage*)maker:(NSString*)string size:(CGFloat)width{
    CIImage *cimage = [self createQRForString:string];
    if(cimage){
        return [self createNonInterpolatedUIImageFormCIImage:cimage withSize:width];
    }else{
        return nil;
    }
    
}

+ (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [[qrString description] dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *QRFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [QRFilter setValue:stringData forKey:@"inputMessage"];
    [QRFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // 返回CIImage
    return QRFilter.outputImage;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(cs);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    UIImage *reusult = [UIImage imageWithCGImage:scaledImage];
    CGContextRelease(bitmapRef);
    CGImageRelease(scaledImage);
    CGImageRelease(bitmapImage);
    return reusult;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
- (IBAction)makerTouched:(id)sender {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
   [self.qrcodeButton setBackgroundImage:[[self class] maker:self.text.text size:250] forState:UIControlStateNormal];
}

- (IBAction)qrcodeTouched:(id)sender {
    if (self.qrcodeButton.currentBackgroundImage) {
        JKAlert *alert = [JKAlert alertWithTitle:@"" andMessage:@"保存到相册"];
        [alert addCommonButtonWithTitle:@"算了吧" handler:^(JKAlertItem *item) {
        }];
        [alert addCommonButtonWithTitle:@"保存" handler:^(JKAlertItem *item) {
            UIImageWriteToSavedPhotosAlbum(self.qrcodeButton.currentBackgroundImage, nil, nil, nil);
        }];
        [alert show];
    }
}

@end
