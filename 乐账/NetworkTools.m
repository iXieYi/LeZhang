//
//  NetworkTools.m
//  XY_Networking
//
//  Created by 谢毅 on 16/10/25.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import "NetworkTools.h"
#define kBounary @"bounary"
#define kBOUNDARY @"abc"
@implementation NetworkTools

#pragma mark - 单文件上传
- (void)POSTFileWithUrlString:(NSString *)urlString FilePath:(NSString *)filepath FileKey:(NSString *)fileKey FileName:(NSString *)fileName SuccessBlock:(SuccessBlock)success Fail:(FailBlock)fail{

    //1.1创建请求       //往自己的服务器网址发送请求
    NSURL *url  = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:url];
    //1.2设置请求方法
    request.HTTPMethod  = @"POST";
    //1.3设置请求头，告诉服务器本次长传的信息
    NSString *contentType  = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBounary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    //1.4设置请求体
    // 设置请求体（封装的方法调用）
    request.HTTPBody = [self getHttpBodyWithFilePath:filepath Filekey:fileKey Filename:fileName];
//    request.HTTPBody = [self makeBody:fileKey filePath:filepath];
    //2.1发送请求
    //NSURLSession实现
    /*
     [[[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:nil completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
     NSLog(@"发送了请求");
     }] resume];
     */
    //NSURLConnection实现
    // [NSOperationQueue mainQueue] :一定要注意线程!(Block 回调的线程!)
    // 这里面的 Block 是系统的 Block : 是网络请求完成之后的 Block 回调(系统自动调用)
    // 在系统内的Block 中调用自己的 成功或者失败回调!
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        //
        NSLog(@"response:%@",response);
        NSLog(@"data:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        //回调成功、失败判断（依据每个公司定制）
        if (data && !connectionError) {//回调成功
            if (success) {
                success(data,response);
            }
        }else{
            if (fail) {//失败回调
                fail(connectionError);
            }
        }
    }];
}

#pragma mark -多文件+普通文件下载
- (void)POSTFileAndMsgWithUrlString:(NSString *)urlString FileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramater:(NSDictionary *)paramaters Success:(SuccessJson)success fail:(FailBlock)fail{
    //1.创建请求
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置请求方法
    request.HTTPMethod =@"POST";
    // 设置请求头,告诉服务器本次长传的时文件信息
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBounary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    request.HTTPBody = nil;
    //2.发送请求
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) { // 如果请求成功,调用成功的回调!
            if (success) {
                // JSON --> OC  解析JSON 数据
                id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                success(obj,response);
            }else{
                if (fail) {
                    fail(error);
                }
            }
        }
    }] resume];
}

#pragma mark - 留给NSurlSession替代上面connection!

#pragma mark -发送普通的POST请求(NSurlSession)
- (void)POSTUrlString:(NSString *)urlString paramater:(NSDictionary *)paramater Success:(SuccessBlock)SuccessBlock Fail:(FailBlock)failBlock{
    //1.1创建请求       //往自己的服务器网址发送请求
    NSURL *url  = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:url];
    //1.2设置请求方法
    request.HTTPMethod  = @"POST";
    NSMutableString *str = [NSMutableString stringWithFormat:@""];
    //1.3取出字典参数，拼接成字符串，参数间用&做间隔
    [paramater enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //nameKey:服务器接受的Key值，nameValue:上传给服务器参数内容
        NSString *nameKey  = key;
        NSString *nameValue = obj;
        [str appendString:[NSString stringWithFormat:@"%@=%@&",nameKey,nameValue]];
    }];
    //处理字符串，去掉最后一个字符串
     NSString *str1 = [str substringFromIndex:(str.length - 1)];
    NSLog(@"发送的字符串是：%@",str1);
    //设置请体
    request.HTTPBody = [str1 dataUsingEncoding: NSUTF8StringEncoding];
    //2.发送请求
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) { //没有错误,并且有数据返回!
            // 成功执行,执行成功的Block 回调!
            if (SuccessBlock) {// 执行 Block
                SuccessBlock(data,response);
            }
        }else {// 网路请求失败
            if (failBlock) {
                failBlock(error);// 失败之后的回调!
            }
        }
    }] resume];

}

#pragma mark - 设置单文件请求体参数封装
-(NSData *)getHttpBodyWithFilePath:(NSString *)filepath Filekey:(NSString *)filekey Filename:(NSString *)filename{
    NSMutableData *data  = [NSMutableData data];
    
    //1.上传文件的上边界
    NSMutableString *headerStr  = [NSMutableString string];
    [headerStr appendFormat:@"--%@\r\n",kBounary];
    [headerStr appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",filekey,filename];
    //需要两个换行
    [headerStr appendString:@"Content-Type: application/octet-stream\r\n\r\n"];
    [data appendData:[headerStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    //2.上传文件内容
    NSData *fileData  = [NSData dataWithContentsOfFile:filepath];
    [data appendData:fileData];
    
    //3.上传文件的下边界
    NSString *footerStr = [NSString stringWithFormat:@"\r\n--%@--",kBounary];
    //将上边界放入二进制文件中(以NSUTF8StringEncoding编码方式)
    [data appendData:[footerStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    return data;
    
}

#pragma mark - 设置多文件+普通文本 请求体参数封装
- (NSData *)getHttpBodyWithFileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramater:(NSDictionary *)paramaters{
   
    NSMutableData *data = [NSMutableData data];
    //遍历文件参数字典，设置文件格式，将所上传的的文件封装起来
    [fileDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *filename  = key;
        NSString *filepath  = obj;
        //1.第一个上边界
        NSMutableString *headerStr = [NSMutableString stringWithFormat:@"--%@\r\n",kBounary];
      [headerStr appendFormat:@"Content-Dispostion: form-data; name=%@; filename=%@\r\n",fileKey,filename];
        //根据文件路径，发送同步请求，获得文件信息
       NSURLResponse *respone  = [self getFileTypeWithFilepath:filepath];
      //文件类型
        NSString *contentType = respone.MIMEType;
        // 注意: 这一行后面是两个换行!
        [headerStr appendFormat:@"Content-Type: %@\r\n\r\n",contentType];
        //将上边界放入二进制文件中(以NSUTF8StringEncoding编码方式)
        [data appendData:[headerStr dataUsingEncoding:NSUTF8StringEncoding]];
        //2.上传文件内容
        NSData *fileData  = [NSData dataWithContentsOfFile:filepath];
        [data appendData:fileData];
    }];
    //遍历普通参数数组
    [paramaters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        //msgkey: 服务器接受的参数key值，msgValue上传的文本参数
        NSString *msgKey  = key;
        NSString *msgValue = obj;
        //普通文本信息上边界
        NSMutableString *headerStr = [NSMutableString stringWithFormat:@"--%@\r\n",kBounary];
        // "username": 服务器接受普通文本参数的key值.后端人员告诉我们的!
        [headerStr appendFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n",msgKey];
         [data appendData:[headerStr dataUsingEncoding:NSUTF8StringEncoding]];
        // 普通文本信息;
        [data appendData:[msgValue dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    //3.下边界，只添加一次
    NSMutableString *footerStr = [NSMutableString stringWithFormat:@"\r\n--%@--\r\n",kBounary];
    [data appendData:[footerStr dataUsingEncoding:NSUTF8StringEncoding]];
    return data;
}

#pragma mark - 动态获取文件类型
-(NSURLResponse *)getFileTypeWithFilepath:(NSString *)filepath{
    //通过发送一个同步请求，来获取文件类型
    //根据本地路径设置一个本地的URL
    NSString *urlString = [NSString stringWithFormat:@"file://%@",filepath];
    NSURL *url = [NSURL URLWithString:urlString];
    //1.创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // 发送一个同步请求,来获得文件类型
    // 同步方法:
    // 参数1: 请求,和之前的一样!
    // 参数2: (NSURLResponse *__autoreleasing *)  NSURLResponse:服务器响应! 两个 ** 先指定一块地址.内容为空!
    // 等方法执行完毕之后,会将返回的内容存储到这块地址中!
    NSURLResponse *respone  = nil ;
    NSLog(@"respone %@",respone);
    //同步请求，阻塞当前线程!
    [NSURLConnection sendSynchronousRequest:request returningResponse:&respone error:NULL];
    // MIMEType : 就是需要的文件类型!
    // expectedContentLength: 文件的长度/大小!一般在文件下载的时候使用! 类型是 lld (long long)
    // suggestedFilename:  建议的文件名称!
    
    NSLog(@"response: %@ %lld %@",respone.MIMEType,respone.expectedContentLength,respone.suggestedFilename);
    return respone;
    
}

#pragma mark - 服务器文件下载

- (void)download:(NSString *)urlString savePath:(NSString *)saveUrl filename:(NSString *)fileName{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSString *filepath = [saveUrl stringByAppendingPathComponent:fileName];
        NSLog(@"%@",filepath);
        //保存文件
        [data writeToFile:filepath atomically:YES];
        NSLog(@"下载完成");
    }];
}


#pragma mark - 获取单例对象
+(instancetype)sharedNetworkTool
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}


@end
