//
//  webViewController.h
//  乐账
//
//  Created by 谢毅 on 16/11/8.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import "iflyMSC/IFlyMSC.h"

@class PopupView;
@protocol JSObjcDelegate <JSExport>

- (void)callCamera;
- (void)callVideo;
- (void)getImage:(id)parameter;

@end

@interface webViewController : UIViewController<IFlyRecognizerViewDelegate>
{
 
    IFlyRecognizerView  *_iflyRecognizerView;
}


@end
