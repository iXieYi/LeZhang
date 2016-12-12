//
//  ViewController.m
//  乐账
//
//  Created by 谢毅 on 16/11/7.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import "ViewController.h"
#import "UI_ViewController.h"
#import "DUI_ViewController.h"
#import "webViewController.h"
#import "QRViewController.h"
#import "OCRViewController.h"
#import "PicViewController.h"
#import "MapViewController.h"
#import "GeocoderController.h"
#import "BaiduMapViewController.h"

@interface ViewController ()
@property (nonatomic, weak)UILabel *text;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    
}
-(void)setupUI{
      self.navigationItem.title = @"乐账";
    CGFloat Margin = 5;
   
    //设置UI识别按键
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(Margin*2, 200+2*Margin, self.view.frame.size.width-Margin*4, 50);
    [button setTitle:@"有UI" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    [button addTarget:self action:@selector(UI) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font  = [UIFont systemFontOfSize:20];
    [self.view addSubview:button];
    
    
    
    //设置无UI识别按键
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2.frame = CGRectMake(Margin*2, 300+2*Margin, self.view.frame.size.width-Margin*4, 50);
    [button2 setTitle:@"无UI" forState:UIControlStateNormal];
    [button2 setBackgroundColor:[UIColor lightGrayColor]];
    [button2 addTarget:self action:@selector(webviewLoad) forControlEvents:UIControlEventTouchUpInside];
    button2.titleLabel.font  = [UIFont systemFontOfSize:20];
    [self.view addSubview:button2];

    //设置标签显示
   UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 150,[UIScreen mainScreen].bounds.size.width, 30)];
    NSString *tmp  = [[UIDevice currentDevice] systemVersion];
    text.text = [NSString stringWithFormat:@"系统版本为:%@",tmp];
    text.textAlignment = NSTextAlignmentCenter;
    self.text = text;
    self.text.font = [UIFont systemFontOfSize:18];
    [self.view addSubview: text];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   
}
//按键响应函数
-(void)UI{
    //有UI识别
    UI_ViewController *VC = [[UI_ViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)DUI{
    //无UI识别
    DUI_ViewController *VC = [[DUI_ViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}
-(void)webviewLoad{
    //无UI识别
    webViewController *VC = [[webViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)QR{
    //二维码
    QRViewController *VC = [[QRViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}


-(void)OCR{
    //二维码
    OCRViewController *VC = [[OCRViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)pic{
    //相册
    PicViewController *VC = [[PicViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)Map{
    //地图
    MapViewController *VC = [[MapViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)Geocoder{
    //地图地址解析
    GeocoderController *VC = [[GeocoderController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)BaiduMap{
    //baidu地图
    BaiduMapViewController *VC = [[BaiduMapViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
