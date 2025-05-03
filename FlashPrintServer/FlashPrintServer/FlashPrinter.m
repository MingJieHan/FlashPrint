//
//  FlashPrinter.m
//  FlashPrintServer
//
//  Created by Hans on 2025/4/28.
//

#import "FlashPrinter.h"

@interface FlashPrinter(){
    
}
@end

@implementation FlashPrinter
@dynamic name;
@dynamic saturation, bright, contrast;
@dynamic watermark, watermarkHeight, watermarkAlignment;
@dynamic paperName, paperWidth, paperHeight;

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ (%@)", self.name, self.paperName];
}
@end
