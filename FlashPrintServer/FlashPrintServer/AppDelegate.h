//
//  AppDelegate.h
//  FlashPrintServer
//
//  Created by Hans on 2025/4/25.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

