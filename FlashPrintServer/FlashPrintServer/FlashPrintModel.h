//
//  FlashPrintModel.h
//  FlashPrintServer
//
//  Created by Hans on 2025/4/29.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FlashPrinter.h"
NS_ASSUME_NONNULL_BEGIN
@interface FlashPrintModel : NSObject
+(FlashPrintModel *)shared;
-(FlashPrinter *)currentPrinter;
-(NSMutableArray <FlashPrinter *>*)existPrinters;
-(BOOL)save;
-(BOOL)removeItem:(NSManagedObject *)item;

-(FlashPrinter *)createFlashPrinter;
@end
NS_ASSUME_NONNULL_END
