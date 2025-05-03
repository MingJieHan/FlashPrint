//
//  FlashPrinterService.m
//  FlashPrintServer
//
//  Created by Hans on 2025/4/27.
//

#import "FlashPrinterService.h"
NSString *serverBaseURL = @"http://192.168.3.106:8000";
@interface FlashPrinterService(){
    
}
@end

@implementation FlashPrinterService
+(void)saveLastServer{
    [NSUserDefaults.standardUserDefaults setValue:serverBaseURL forKey:@"LastServer"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+(NSString *)loadLastServer{
    NSString *s = [NSUserDefaults.standardUserDefaults valueForKey:@"LastServer"];
    if (nil == s){
        s = @"https://flashprint.hanmingjie.com";
    }
    return s;
}

+(BOOL)taskListWithHandler:(FlashPrinterService_TasksHandler)handler{
    NSString *urlString = [NSString stringWithFormat:@"%@/task/printer_tasks.html", serverBaseURL];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (nil != error){
            NSLog(@"taskList return error:%@", error.localizedDescription);
            return;
        }
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        if (200 != res.statusCode){
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", html);
            NSLog(@"taskList return code is NOT 200.");
            return;
        }
        [FlashPrinterService saveLastServer];
        NSError *jsonError = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
        NSArray <NSDictionary *>*tasks = [dict valueForKey:@"tasks"];
        handler(tasks);
        return;
    }];
    [task resume];
    return YES;
}

+(BOOL)taskRequestPrinting:(NSInteger)task_id withHandler:(FlashPrinterService_StatusChangeHandler)handler{
    NSString *urlString = [NSString stringWithFormat:@"%@/task/printer_try_printing?task_id=%ld", serverBaseURL, task_id];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (nil != error){
            NSLog(@"taskRequestPrinting return error:%@", error.localizedDescription);
            handler(NO, error.localizedDescription);
            return;
        }
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        if (200 != res.statusCode){
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", html);
            NSLog(@"taskRequestPrinting return code is NOT 200.");
            handler(NO, html);
            return;
        }
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([html isEqualToString:@"OK"]){
            handler(YES, nil);
        }else{
            handler(NO, html);
        }
        return;
    }];
    [task resume];
    return YES;
}

+(BOOL)task:(NSInteger)task_id print:(BOOL)success withHandler:(FlashPrinterService_StatusChangeHandler)handler{
    NSString *urlString = nil;
    if (success){
        urlString = [NSString stringWithFormat:@"%@/task/printer_try_printed?task_id=%ld", serverBaseURL, task_id];
    }else{
        urlString = [NSString stringWithFormat:@"%@/task/printer_let_failed?task_id=%ld", serverBaseURL, task_id];
    }
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (nil != error){
            NSLog(@"task print return error:%@", error.localizedDescription);
            handler(NO, error.localizedDescription);
            return;
        }
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        if (200 != res.statusCode){
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", html);
            NSLog(@"task print return code is NOT 200.");
            handler(NO, html);
            return;
        }
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([html isEqualToString:@"OK"]){
            handler(YES, nil);
        }else{
            handler(NO, html);
        }
        return;
    }];
    [task resume];
    return YES;
}

+(BOOL)downloadImageForTask:(NSString * _Nonnull )image_URLString withHandler:(FlashPrinterService_DownloadImageHandler)handler{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:image_URLString]];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (nil != error){
            NSLog(@"downloadImage %@ \nreturn error:%@", image_URLString, error.localizedDescription);
            handler(nil, error.localizedDescription);
            return;
        }
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        if (200 != res.statusCode){
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@", html);
            NSLog(@"downloadImage return code is NOT 200.");
            handler(nil, html);
            return;
        }
        if (data){
            handler(data, nil);
        }else{
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            handler(nil, html);
        }
        return;
    }];
    [task resume];
    return YES;
}
@end
