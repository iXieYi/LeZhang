//
//  NetworkTools.h
//  XY_Networking
//
//  Created by 谢毅 on 16/10/25.
//  Copyright © 2016年 xieyi. All rights reserved.
//

#import <Foundation/Foundation.h>
//定义两个回调的block,一个用于成功回调，一个用于失败回调
typedef void (^SuccessBlock)(NSData *data,NSURLResponse *response);
typedef void (^FailBlock)(NSError *error);
typedef void (^SuccessJson)(id responseObject,NSURLResponse *response);

@interface NetworkTools : NSObject
/*********************************
 上传单文件
 urlString :文件上传需要的接口(服务器端)
 filePath  :需要上传的文件路径
 fileKey   :服务器接受文件的Key值
 fileName  :文件在服务器保存的名称
*********************************/
- (void)POSTFileWithUrlString:(NSString *)urlString FilePath:(NSString *)filepath FileKey:(NSString *)fileKey FileName:(NSString *)fileName SuccessBlock:(SuccessBlock)success Fail:(FailBlock)fail;

/**********************************
 直接封装(多文件+文本信息)上传
 urlString  接口
 fileDict   文件字典
 fileKey    服务器接受文件的key值
 paramaters 普通文本信息字典
 success    成功之后的回调
 fail       失败之后的回调
 本方法默认处理服务器返回的JSON数据(自动解析JSON数据)
 ***********************************/
- (void)POSTFileAndMsgWithUrlString:(NSString *)urlString FileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramater:(NSDictionary *)paramaters Success:(SuccessJson)success fail:(FailBlock)fail;

/*********************************
 发送普通的 POST 请求
 urlString :post 请求的接口
 上传给服务器的参数,用字典包装
 paramater : 参数字典
 SuccessBlock : 成功之后的回调
 failBlock : 失败之后的回调
 *********************************/
- (void)POSTUrlString:(NSString *)urlString paramater:(NSDictionary *)paramater Success:(SuccessBlock)SuccessBlock Fail:(FailBlock)failBlock;

/*********************************
 单文件上传的格式封装(封装的时请求体中的内容)
  filePath 需要上传的文件路径
  fileKey  服务器接受文件的key值
  fileName 文件在服务器上保存的名称(如果传nil ,会使用默认名称)
  @return 封装好的请求体内容
 *********************************/
-(NSData *)getHttpBodyWithFilePath:(NSString *)filepath Filekey:(NSString *)filekey Filename:(NSString *)filename;


/*********************************
  多文件上传+普通文本信息 格式封装
  fileDict   文件字典: key(文件在服务器保存的名称)=value(文件路径)
  fileKey    服务器接受文件信息的key值
  paramaters 普通参数字典: key
 (服务器接受普通文本信息的key)=value(对应的文本信息)
  @return 封装好的二进制数据(请求体)
  *********************************/
- (NSData *)getHttpBodyWithFileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramater:(NSDictionary *)paramaters;


/*********************************
 服务器文件下载
 urlString ：服务器文件接口
 saveUrl   ：客户端本地的保存路径
 fileName  ：本地保存名称
 *********************************/
- (void)download:(NSString *)urlString savePath:(NSString *)saveUrl filename:(NSString *)fileName;


/*********************************
 获得单例对象(一次性代码)只有通过这个方法
 获得的才是单例对象!不要把所有的后门都给堵
 死,让别人自己选择实例化对象的方法!
 *********************************/
+(instancetype)sharedNetworkTool;


@end
