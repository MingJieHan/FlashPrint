//
//  NSImageTools.m
//  FlashPrintServer
//
//  Created by Hans on 2025/4/28.
//

#import "NSImageTools.h"

@implementation NSImageTools
+ (NSImage *)adjustSaturationOfImage:(NSImage *)image saturation:(CGFloat)saturation{
    return [NSImageTools adjustSaturationOfImage:image saturation:saturation bright:0.f contrast:1.f];
}

+ (NSImage *)adjustSaturationOfImage:(NSImage *)image saturation:(CGFloat)saturation
                              bright:(CGFloat)bright contrast:(CGFloat)contrast{
    
    // 1. 转成 CIImage
    NSData *imageData = [image TIFFRepresentation];
    CIImage *ciImage = [CIImage imageWithData:imageData];
    
    // 2. 创建饱和度滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setValue:@(saturation) forKey:kCIInputSaturationKey]; // 1.0 是原图，>1 更鲜艳，<1 更灰
    
    [filter setValue:@(bright) forKey:kCIInputBrightnessKey];   //亮度
    
    [filter setValue:@(contrast) forKey:kCIInputContrastKey];   //对比度
    
    
    // 3. 生成输出的 CIImage
    CIImage *outputCIImage = filter.outputImage;
    
    // 4. 渲染成 CGImage
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputCIImage fromRect:[outputCIImage extent]];
    
    // 5. 转回 NSImage
    NSImage *resultImage = [[NSImage alloc] initWithCGImage:cgImage size:image.size];
    CGImageRelease(cgImage);
    
    return resultImage;
}


+(BOOL)printWithView:(NSView *)view
     withPrinterName:(NSString *)printerName
       withPaperName:(NSString *)paperName
       withPaperSize:(NSSize)paperSize
         withJobName:(NSString * _Nullable )jobName
           withError:(NSString * _Nullable * _Nullable )errorReason
           withPanel:(BOOL)panel{
    if (nil == printerName || printerName.length < 1){
        *errorReason = @"printer name is failed.";
        return NO;
    }
    if (nil == paperName || paperName.length < 1){
        *errorReason = @"Paper name if failed.";
        return NO;
    }
    
    NSPrintInfo *info = NSPrintInfo.sharedPrintInfo;
    NSPrinter *targetP = [NSPrinter printerWithName:printerName];
    if (nil == targetP){
        *errorReason = [NSString stringWithFormat:@"Printer %@ NOT Found.", printerName];
        return NO;
    }
    info.printer = targetP;
    
    if (view.frame.size.width > view.frame.size.height){
        [info setOrientation:NSPaperOrientationLandscape];
//        [view rotateByAngle:-90.f];
//        [view setFrame:NSMakeRect(0.f, 0.f, image.size.height, image.size.width)];
    }else{
        [info setOrientation:NSPaperOrientationPortrait];
    }

    [info setPaperSize:paperSize];      //必须设置
    [info setPaperName:paperName];      //必须设置
    
    [info setTopMargin:0.f];
    [info setBottomMargin:0.f];
    [info setLeftMargin:0.f];
    [info setRightMargin:0.f];
    
    [info setVerticalPagination:NSPrintingPaginationModeFit];
    [info setHorizontalPagination:NSPrintingPaginationModeFit];
    
    [info setVerticallyCentered:YES];
    [info setHorizontallyCentered:YES];
        
    NSPrintOperation *o = [NSPrintOperation printOperationWithView:view printInfo:info];
    if (jobName && jobName.length > 0){
        o.jobTitle = jobName;
    }else{
        o.jobTitle = @"Hans_Printer";
    }
    o.showsProgressPanel = NO;
    if (panel){
        o.showsPrintPanel = YES;
    }else{
        o.showsPrintPanel = NO;
    }
    return [o runOperation];
}
@end
