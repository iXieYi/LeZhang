//
//  MapViewController.m
//  乐账
//
//  Created by 谢毅 on 16/11/16.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()<MKMapViewDelegate>
@property(nonatomic, strong)MKMapView * MapView;
@property(nonatomic, strong)UITextField *latitude;
@property(nonatomic, strong)UITextField *longtitude;


@end

@implementation MapViewController
-(MKMapView *)MapView{
    if (_MapView==nil) {
        _MapView = [[MKMapView alloc] init];
    }
    return _MapView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
-(void) setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    //初始化地图view
    CGSize ViewSize = self.view.bounds.size;
    CGFloat margin = 10;
    CGFloat btnSize = 30;
    CGFloat textFiledwitdh = (ViewSize.width-4*margin-btnSize)/2;
    MKMapView *MapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64,ViewSize.width , ViewSize.height-64)];
    
    UITextField *latitude = [[UITextField alloc] initWithFrame:CGRectMake(margin, margin, textFiledwitdh, 30)];
    latitude.backgroundColor = [UIColor whiteColor];
    [MapView addSubview:latitude];
    UITextField *longtitude = [[UITextField alloc] initWithFrame:CGRectMake(textFiledwitdh+2*margin, margin, textFiledwitdh, 30)];
    longtitude.backgroundColor = [UIColor whiteColor];
    [MapView addSubview:longtitude];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(2*textFiledwitdh+3*margin, margin, btnSize, btnSize)];
    [btn setTitle:@"GO" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [MapView addSubview:btn];
    
    [self.view addSubview:MapView];
    self.MapView  = MapView;
    
    
    //设置地图参数
    self.MapView.mapType = MKMapTypeStandard;//使用标准地图
    self.MapView.zoomEnabled = YES;          //地图可缩放
    self.MapView.scrollEnabled = YES;        //设置地图可滚动
    self.MapView.rotateEnabled = YES;        //设置地图可旋转
    self.MapView.showsUserLocation = YES;    //设置用户当前位置
    self.MapView.delegate = self;            //设置代理
    
    
}

-(void)btnClick{
//关闭输入键盘
    [self.MapView.subviews[3] resignFirstResponder];
    [self.MapView.subviews[4] resignFirstResponder];
    NSLog(@"%@",self.MapView.subviews);
    UITextField *latitude = self.MapView.subviews[3];
    UITextField *longtitude =self.MapView.subviews[4];
    NSString *latitudeStr = latitude.text;
    NSString *longtitudeStr = longtitude.text;
    //如果用户输入经纬不为空
    if (latitudeStr !=nil &&latitudeStr.length>0 &&longtitudeStr != nil && longtitudeStr.length) {
        //调用地图显示
        [self locateToLatitude:latitudeStr.floatValue longitude:longtitudeStr.floatValue];
    }

}
-(void)locateToLatitude:(CGFloat)latitude longitude:(CGFloat)longitude{

//设置地图中心经纬度
    CLLocationCoordinate2D center ={latitude,longitude};
    //设置地图显示范围
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;//地图范围越小，细节越清楚
    span.longitudeDelta = 0.01;
    //创建地图范围对象，该包含地图显示中心和显示范围
    MKCoordinateRegion region ={center,span};
    [self.MapView setRegion:region animated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
