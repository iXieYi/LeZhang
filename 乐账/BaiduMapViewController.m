//
//  BaiduMapViewController.m
//  乐账
//
//  Created by 谢毅 on 16/11/17.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import "BaiduMapViewController.h"

@interface BaiduMapViewController()<BMKMapViewDelegate>

@property(nonatomic,strong)BMKMapView *mapView;

@end

@implementation BaiduMapViewController
-(BMKMapView *)mapView{
    if (_mapView==nil) {
        _mapView = [[BMKMapView alloc] init];
    }
    return _mapView;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self mapOperation];
    
}
-(void)mapOperation{

    BMKMapView* mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 64, 375, 603)];
    mapView.mapType = BMKMapTypeNone;
    //卫星地图
    //    [mapView setMapType:BMKMapTypeSatellite];
    //切换为普通地图
    [mapView setMapType:BMKMapTypeStandard];
    //打开实时路况
    //    [mapView setTrafficEnabled:YES];
    //关闭实时路况图层
    //    [_mapView setTrafficEnabled:NO];
    
    //打开百度城市热力图图层（百度自有数据）
//    [_mapView setBaiduHeatMapEnabled:YES];
    
    //关闭百度城市热力图图层（百度自有数据）
//    [_mapView setBaiduHeatMapEnabled:NO];
    
    [self.view addSubview:mapView];
    self.mapView = mapView;
    

}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self DrowLine];
    [self addAnnotation];
   
}
-(void)addAnnotation{
    //添加一个锚点
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
    CLLocationCoordinate2D coor;
    coor.latitude = 39.915;
    coor.longitude = 116.404;
    annotation.coordinate  = coor;
    annotation.title =@"百度地图我来了，北京！";
    [self.mapView addAnnotation:annotation];
}
-(void)DrowLine{
    // 添加折线覆盖物
    CLLocationCoordinate2D coors[2] = {0};
    coors[0].latitude = 39.315;
    coors[0].longitude = 116.304;
    coors[1].latitude = 39.515;
    coors[1].longitude = 116.504;
    BMKPolyline* polyline = [BMKPolyline polylineWithCoordinates:coors count:2];
    [_mapView addOverlay:polyline];
}
//添加覆盖图层
-(BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 5.0;
        
        return polylineView;
    }
    return nil;
}
//覆盖图层代理
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
     return nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}
@end
