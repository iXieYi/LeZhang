//
//  AppDelegate.h
//  乐账
//
//  Created by 谢毅 on 16/11/7.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

   BMKMapManager* _mapManager;

}

@property (strong, nonatomic) UIWindow *window;


@end

