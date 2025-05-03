//
//  FlashPrinter.h
//  FlashPrintServer
//
//  Created by Hans on 2025/4/28.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@interface FlashPrinter : NSManagedObject
@property (nonatomic) NSString *name;   //打印机名称

@property (nonatomic) float saturation; //色饱和度调整
@property (nonatomic) float bright;     //亮度调整
@property (nonatomic) float contrast;   //对比度调整

@property (nonatomic) NSString *paperName;  //打印纸名字
@property (nonatomic) float paperWidth;     //打印纸宽度， 仅程序内使用
@property (nonatomic) float paperHeight;    //打印纸高度， 仅程序内使用

@property (nonatomic) NSData * _Nullable watermark;     //水印图片内容 png 底透明
@property (nonatomic) float watermarkHeight;            //水印图片高度，所占图片总高度的百分比  1% - 10%
@property (nonatomic) NSNumber *watermarkAlignment;     //水印位置


-(NSString *)description;
@end
NS_ASSUME_NONNULL_END
