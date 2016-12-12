//
//  DUI_ViewController.h
//  乐账
//
//  Created by 谢毅 on 16/11/7.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"

@class PopupView;
@class IFlyDataUploader;
@class IFlySpeechRecognizer;

@interface DUI_ViewController : UIViewController<IFlySpeechRecognizerDelegate,UIActionSheetDelegate>
//识别对象

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;





@end
