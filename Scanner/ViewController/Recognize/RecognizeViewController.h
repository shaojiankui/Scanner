//
//  RecognizeViewController.h
//  Scanner
//
//  Created by Jakey on 15/11/23.
//  Copyright © 2015年 Jakey. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^RecognizeFinishingBlock)(NSString *string);

@interface RecognizeViewController : BaseViewController
{
    RecognizeFinishingBlock _recognizeFinishingBlock;
}
@property (weak, nonatomic) IBOutlet UIImageView *preImageView;
- (IBAction)browseTouched:(id)sender;
- (void)recognizeFinishingBlock:(RecognizeFinishingBlock)recognizeFinishingBlock;

@end
