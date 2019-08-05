//
//  MLeaksMessenger.m
//  MLeaksFinder
//
//  Created by 佘泽坡 on 7/17/16.
//  Copyright © 2016 zeposhe. All rights reserved.
//

#import "MLeaksMessenger.h"

static __weak UIAlertView *alertView;

@implementation MLeaksMessenger

static NSString * leakSavePath =  @"http://qm.soulapp-inc.cn/api/vulpix/vulpix_view/post_check_point_data/";

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    [self alertWithTitle:title message:message delegate:nil additionalButtonTitle:nil];
}

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              delegate:(id<UIAlertViewDelegate>)delegate
 additionalButtonTitle:(NSString *)additionalButtonTitle {
    [alertView dismissWithClickedButtonIndex:0 animated:NO];
    UIAlertView *alertViewTemp = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:delegate
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:additionalButtonTitle, nil];
    
//    [alertViewTemp show];
//    alertView = alertViewTemp;
    NSString *className = [self getClassName:message];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *userPhoneName = [[UIDevice currentDevice] name];
    NSString *viewStack = [message stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSLog(@"%@: %@", title, className);
    
    NSDictionary *params = @{@"class_name":className, @"app_version":appVersion,
                             @"view_stack":message, @"phone_model":userPhoneName};
    [self sendLeakResult:params];

}

/**
 *  获取view名字作为ClassName
 **/
+ (NSString *)getClassName:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    temp=[temp stringByReplacingOccurrencesOfString:@"("withString:@""];
    temp=[temp stringByReplacingOccurrencesOfString:@")"withString:@""];
    NSArray *className = [temp componentsSeparatedByString:@","];
    return [className objectAtIndex:0];
}

/**
 *  发送内存泄漏数据到测试平台
 **/
+ (void)sendLeakResult:(NSDictionary *)dicData{
    
    NSString *boundary = @"wumeijun2019";
    NSURL *url = [NSURL URLWithString:leakSavePath];
    NSMutableString *bodyContent = [NSMutableString string];
    for(NSString *key in dicData.allKeys){
        id value = [dicData objectForKey:key];
        [bodyContent appendFormat:@"--%@\r\n",boundary];
        [bodyContent appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [bodyContent appendFormat:@"%@\r\n",value];
    }
    [bodyContent appendFormat:@"--%@--\r\n",boundary];
    NSData *bodyData=[bodyContent dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    [request addValue: [NSString stringWithFormat:@"%zd",bodyData.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    NSLog(@"请求的长度%@",[NSString stringWithFormat:@"%zd",bodyData.length]);
    __autoreleasing NSError *error=nil;
    __autoreleasing NSURLResponse *response=nil;
    NSLog(@"输出Bdoy中的内容>>\n%@",[[NSString alloc]initWithData:bodyData encoding:NSUTF8StringEncoding]);
    NSData *reciveData= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error){
        NSLog(@"出现异常%@",error);
    }else{
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
        if(httpResponse.statusCode==200){
            NSLog(@"服务器成功响应!>>%@",[[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding]);
            
        }else{
            NSLog(@"服务器返回失败>>%@",[[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding]);
            
        }
    }
        


//    NSLog(@"发送请求url=%@,params=%@",leakSavePath,params);
//    NSDictionary *headers = @{ @"Content-Type": @"application/x-www-form-urlencode"};
//    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
//
//
////    NSArray * result = [NSJSONSerialization JSONObjectWithData:postData options:NSJSONReadingMutableLeaves error:nil];
//
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:leakSavePath]
//                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                       timeoutInterval:10.0];
//    [request setHTTPMethod:@"POST"];
//    [request setAllHTTPHeaderFields:headers];
//    [request setHTTPBody:postData];
//
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
//                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                                    if (error) {
//                                                        NSLog(@"leakerror%@", error);
//                                                    } else {
//                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//                                                        NSLog(@"leakresponse%@", httpResponse);
//                                                    }
//                                                }];
//    [dataTask resume];
    
}



@end
