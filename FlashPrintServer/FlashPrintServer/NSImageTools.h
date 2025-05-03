//
//  NSImageTools.h
//  FlashPrintServer
//
//  Created by Hans on 2025/4/28.
//
#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImageTools : NSObject
/*
 saturation 参数：传 1.0 就是原图，>1.0 是更鲜艳，<1.0 会变灰。
 */
+ (NSImage *)adjustSaturationOfImage:(NSImage *)image saturation:(CGFloat)saturation;


/*
 -1.f -> bright -> 1.f      0.f 表示不变
 0.f -> contrast -> 4.f, 1.f 表示不变
 */
+ (NSImage *)adjustSaturationOfImage:(NSImage *)image saturation:(CGFloat)saturation
                              bright:(CGFloat)bright contrast:(CGFloat)contrast;

//return Success
+(BOOL)printWithView:(NSView * _Nonnull )view
     withPrinterName:(NSString *)printerName
       withPaperName:(NSString *)paperName
       withPaperSize:(NSSize)paperSize
         withJobName:(NSString * _Nullable )jobName
           withError:(NSString * _Nullable * _Nullable )errorReason
           withPanel:(BOOL)panel;

//+ (void)printData:(NSData *)incomingPrintData;
@end

NS_ASSUME_NONNULL_END
