//
//  FlashPrinterService.h
//  FlashPrintServer
//
//  Created by Hans on 2025/4/27.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull serverBaseURL;

typedef void (^FlashPrinterService_TasksHandler) (NSArray  * _Nullable tasks);
typedef void (^FlashPrinterService_StatusChangeHandler) (BOOL success, NSString * _Nullable errorReason);
typedef void (^FlashPrinterService_DownloadImageHandler) (NSData * _Nullable imageData, NSString * _Nullable errorReason);


NS_ASSUME_NONNULL_BEGIN
@interface FlashPrinterService : NSObject
+(NSString *)loadLastServer;

+(BOOL)taskListWithHandler:(FlashPrinterService_TasksHandler)handler;

//向服务器请求打印Task，回复成功后，开始在本地打印，打印成功或失败都要返回信息给服务器
+(BOOL)taskRequestPrinting:(NSInteger)task_id withHandler:(FlashPrinterService_StatusChangeHandler)handler;

//告诉服务器，task 是否打印成功了
+(BOOL)task:(NSInteger)task_id print:(BOOL)success withHandler:(FlashPrinterService_StatusChangeHandler)handler;

//下载Task的图片文件
+(BOOL)downloadImageForTask:(NSString * _Nonnull )image_URLString withHandler:(FlashPrinterService_DownloadImageHandler)handler;
@end
NS_ASSUME_NONNULL_END
