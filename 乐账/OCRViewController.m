//
//  OCRViewController.m
//  乐账
//
//  Created by 谢毅 on 16/11/9.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import "OCRViewController.h"
@interface OCRViewController ()

@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UILabel *label;

@end
@implementation OCRViewController{
    
    

}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self callOCRSpace];
}
//界面搭建
-(void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 303)];
    imageView.image = [UIImage imageNamed:@"image"];
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame),[UIScreen mainScreen].bounds.size.width , 300)];
    [self.view addSubview:label];
    self.label  = label;
}
//1、当成功接收服务器响应的时回调
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSLog(@"成功接收服务器响应!");


}
//2、当成功接收服务器返回数据时回调
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
   NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@",dict);

}

//3.当请求完成(成功|失败)的时候会调用该方法，如果请求失败，则error有值
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"请求完成；%@",error);
}

//简化的代码
- (void)dataTask2 {
    NSURL *url = [NSURL URLWithString:@"http://api.newocr.com/v1/key/status?key=6fa9e810a0aa3755fb2cfcc3a5735113"];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSLog(@"%@",json);
    }] resume];
}
//发送post请求
- (void)dataTask3 {
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/php/login.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"post";
    NSString *body = @"username=123&password=123";
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        NSLog(@"%@",json);
    }] resume];
}

//获取API网络请求
- (void)callOCRSpace {
    // Create URL request
    NSURL *url = [NSURL URLWithString:@"https://api.ocr.space/parse/Image"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"randomString";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Image file and parameters
//    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"2.jpg"], 0.6);
    NSData *imageD = UIImagePNGRepresentation([UIImage imageNamed:@"OCRimage"]);
    NSDictionary *parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"6fa9e810a0aa3755fb2cfcc3a5735113", @"apikey",
                                          @"Ture", @"isOverlayRequired",
                                          @"eng", @"language", nil];
    
    // Create multipart form body
    NSData *data = [self createBodyWithBoundary:boundary
                                     parameters:parametersDictionary
                                      imageData:imageD
                                       filename:@"OCRimage.png"];
    
    [request setHTTPBody:data];
    
    // Start data session
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError* myError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&myError];
        // Handle result
        NSLog(@"----%@------",result);

    }];
    [task resume];
}

//设置请求体函数
- (NSData *) createBodyWithBoundary:(NSString *)boundary parameters:(NSDictionary *)parameters imageData:(NSData*)data filename:(NSString *)filename
{
    NSMutableData *body = [NSMutableData data];
    
    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    for (id key in parameters.allKeys) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameters[key]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}








@end
