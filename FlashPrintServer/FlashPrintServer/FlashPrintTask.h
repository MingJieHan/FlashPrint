//
//  FlashPrintTask.h
//  FlashPrintServer
//
//  Created by Hans on 2025/4/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface FlashPrintTask : NSObject
-(id)init NS_UNAVAILABLE;
@property (nonatomic) NSUInteger task_id;
@property (nonatomic) NSString *image_urlString;
@property (nonatomic) NSData * _Nullable imageData;
@property (nonatomic) NSImage * _Nullable image;
@property (nonatomic) NSImage * _Nullable fixedImage;
+(NSMutableArray <FlashPrintTask *>*)initWithArray:(NSArray <NSDictionary *>*)tasks;

-(id)initWithDictionary:(NSDictionary *)dict;
@end
NS_ASSUME_NONNULL_END
