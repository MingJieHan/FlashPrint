//
//  FlashPrintTask.m
//  FlashPrintServer
//
//  Created by Hans on 2025/4/27.
//

#import "FlashPrintTask.h"
#define DICT_KEY_STATUS @"status"
#define DICT_KEY_ID @"id"
#define DICT_KEY_IMAGE @"image"
#define DICT_KEY_NOTE @"note"
#define DICT_KEY_CREATE @"create_date"

@implementation FlashPrintTask
@synthesize image_urlString, task_id;
@synthesize imageData;
@synthesize image, fixedImage;

+(NSMutableArray <FlashPrintTask *>*)initWithArray:(NSArray <NSDictionary *>*)tasks{
    if (nil == tasks){
        return nil;
    }
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in tasks){
        FlashPrintTask *t = [[FlashPrintTask alloc] initWithDictionary:dict];
        [results addObject:t];
    }
    return results;
}



-(id)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self){
        task_id = [[dict valueForKey:DICT_KEY_ID] integerValue];
        image_urlString = [[dict valueForKey:DICT_KEY_IMAGE] stringValue];
    }
    return self;
}
@end
