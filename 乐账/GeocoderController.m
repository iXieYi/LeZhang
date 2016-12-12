//
//  GeocoderController.m
//  乐账
//
//  Created by 谢毅 on 16/11/16.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import "GeocoderController.h"

@interface GeocoderController ()

@property(nonatomic, strong) UILabel *address;
@property(nonatomic, strong) UILabel *latitude;
@property(nonatomic, strong) UILabel *longtitude;
@property(nonatomic, strong) UITextField *addressTextField;
@property(nonatomic, strong) UITextField *latitudeTextField;
@property(nonatomic, strong) UITextField *longtitudeTextField;
@property(nonatomic, strong) UIButton *coder;
@property(nonatomic, strong) UIButton *Dcoder;
@property(nonatomic, strong) UITextView *resultView;
@property(nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation GeocoderController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    //创建地址解析器
    self.geocoder = [[CLGeocoder alloc] init];
}

-(void)setupUI{
    self.view.backgroundColor = [UIColor cyanColor];
    //初始界面搭建
    CGFloat margin = 10;
    CGFloat Width = 52;
    UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin+64, Width, 30)];
    address.text = @"地址：";
    [address setFont:[UIFont systemFontOfSize:17]];
    [self.view addSubview:address];
    self.address = address;
    //地址输入框
    CGFloat addressTextFieldWidth = self.view.bounds.size.width-2*Width - 3*margin;
    UITextField *addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(Width+margin, margin+64, addressTextFieldWidth, 30)];
    addressTextField.placeholder = @"请输入地址";
    addressTextField.backgroundColor = [UIColor whiteColor];
//    addressTextField.borderStyle = UITextBorderStyleRoundedRect;
    addressTextField.layer.cornerRadius = 8;
    [self.view addSubview:addressTextField];
    self.addressTextField = addressTextField;
    //解析按键
    UIButton *coder = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addressTextField.frame)+margin, margin+64, Width, 30)];
    coder.backgroundColor = [UIColor grayColor];
    [coder setTitle:@"解析" forState:UIControlStateNormal];
    [coder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    coder.layer.cornerRadius = 8;
    [coder addTarget:self action:@selector(coderClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:coder];
    self.coder = coder;
    //纬度label
    UILabel *latitude = [[UILabel alloc] initWithFrame:CGRectMake(margin,CGRectGetMaxY(addressTextField.frame)+margin, Width, 30)];
    latitude.text = @"纬度：";
    [latitude setFont:[UIFont systemFontOfSize:17]];
    [self.view addSubview:latitude];
    self.latitude = latitude;
    
    CGFloat textFieldWidth = (self.view.bounds.size.width-3*Width-4*margin)/2;
    //纬度textField
    UITextField *latitudeTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(latitude.frame), CGRectGetMaxY(addressTextField.frame)+margin, textFieldWidth, 30)];
//    latitudeTextField.placeholder = @"输入经度";
    latitudeTextField.backgroundColor = [UIColor whiteColor];
    latitudeTextField.layer.cornerRadius = 8;
    latitudeTextField.font =[UIFont systemFontOfSize:15];
    [self.view addSubview:latitudeTextField];
    self.latitudeTextField = latitudeTextField;
    
    //经度label
    UILabel *longtitude = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(latitudeTextField.frame)+margin,CGRectGetMaxY(addressTextField.frame)+margin, Width, 30)];
    longtitude.text = @"经度：";
    [longtitude setFont:[UIFont systemFontOfSize:17]];
    [self.view addSubview:longtitude];
    self.latitude = longtitude;
    
    //经度textField
    UITextField *longtitudeTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(longtitude.frame), CGRectGetMaxY(addressTextField.frame)+margin, textFieldWidth, 30)];
//    longtitudeTextField.placeholder = @"输入纬度";
    longtitudeTextField.backgroundColor = [UIColor whiteColor];
    longtitudeTextField.layer.cornerRadius = 8;
    longtitudeTextField.font =[UIFont systemFontOfSize:15];
    [self.view addSubview:longtitudeTextField];
    self.longtitudeTextField = longtitudeTextField;
    //按钮添加
    UIButton *Dcoder = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(longtitudeTextField.frame)+margin, CGRectGetMaxY(addressTextField.frame)+margin, Width, 30)];
    [Dcoder setTitle:@"反解析" forState:UIControlStateNormal];
     [Dcoder setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [Dcoder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    Dcoder.titleLabel.font = [UIFont systemFontOfSize:15];
    Dcoder.backgroundColor = [UIColor grayColor];
    Dcoder.layer.cornerRadius = 8;
    [Dcoder addTarget:self action:@selector(DcoderClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Dcoder];
    self.Dcoder = Dcoder;
    //添加文本视图
    CGSize resultViewSize = self.view.bounds.size;
    UITextView *resultView = [[UITextView alloc] initWithFrame:CGRectMake(margin, CGRectGetMaxY(Dcoder.frame)+margin, resultViewSize.width-2*margin, resultViewSize.height-2*margin-CGRectGetMaxY(Dcoder.frame))];
    resultView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:resultView];
    self.resultView = resultView;
    
}
//地址解析
-(void)coderClick{
    //释放键盘
    [self.addressTextField resignFirstResponder];
    [self.latitudeTextField resignFirstResponder];
    [self.longtitudeTextField resignFirstResponder];
    //获取用户输入的地址字符串
    NSString *addr = self.addressTextField.text;
    if (addr !=nil&&addr.length>0) {
        [self.geocoder geocodeAddressString:addr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            //如果解析结果的集合数据大于1，则表明了得到了经度和纬度信息
            if (placemarks.count>0) {
                //先处理一个
                CLPlacemark *placemark = placemarks[0];
                CLLocation *location = placemark.location;
                self.resultView.text = [NSString stringWithFormat:@"%@的经度为：%g,纬度为：%g",addr,location.coordinate.latitude,location.coordinate.longitude];
            }else{
                [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"您输入的地址无法解析" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            }
            
        }];
    }
}

-(void)DcoderClick{
    //释放键盘
    [self.addressTextField resignFirstResponder];
    [self.latitudeTextField resignFirstResponder];
    [self.longtitudeTextField resignFirstResponder];
    //反地址解析
    //字符串初始化很重要要不无法解析到地址
    NSString *longtitudeStr =[[NSString alloc] initWithFormat:@"%@",self.longtitudeTextField.text];
    NSString *latitudeStr = [[NSString alloc] initWithFormat:@"%@",self.latitudeTextField.text];
    if (longtitudeStr !=nil&&longtitudeStr.length>0&&latitudeStr !=nil && latitudeStr.length>0) {
       NSLog(@"%f",longtitudeStr.floatValue);
        //限定经纬度范围防止用户输入错误
        if (longtitudeStr.floatValue<=180.0&&longtitudeStr.floatValue>=-180.0&&latitudeStr.floatValue<=90.0&&latitudeStr.floatValue>=-90.0) {
            //将用户输入的经纬度封装成CLLocation 对象
            CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitudeStr floatValue] longitude:[longtitudeStr floatValue]];
            NSLog(@"%f",location.coordinate.latitude);
            
            [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                NSLog(@"%@",placemarks);
                //如果解析结果集合元素大于一，则表明正确解析
                if (placemarks.count>0) {
                    //取第一个
                    CLPlacemark *placemark =placemarks[0];
                    //获取详细信息
                    NSArray*addrArray = [placemark.addressDictionary objectForKey:@"FormattedAddressLines"];
                    //将详细地址拼接成字符串
                    NSMutableString *addrStr = [[NSMutableString alloc] init];
                    for (int i=0; i<addrArray.count; i++) {
                        [addrStr appendString:addrArray[i]];
                    }
                    self.resultView.text = [NSString stringWithFormat:@"经度：%g,纬度：%g,的地址是：%@",location.coordinate.longitude,location.coordinate.latitude,addrStr];
                }
                else{
                    
                    [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"您输入的地址无法解析" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                    
                }
            }];
            
            
        }else{
            [[[UIAlertView alloc] initWithTitle:@"警告" message:@"您输入的经纬度有误！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        
        }
    }
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
