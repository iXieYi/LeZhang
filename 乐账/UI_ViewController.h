//
//  UI_ViewController.h
//  乐账
//
//  Created by 谢毅 on 16/11/7.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/IFlyMSC.h"
@class PopupView;
@interface UI_ViewController : UIViewController<IFlyRecognizerViewDelegate>
{
    IFlyRecognizerView  *_iflyRecognizerView;
}
//定义见面两个控件
@property (nonatomic, strong)PopupView *popView;
@property (nonatomic, weak) UITextView *textView;

@end
