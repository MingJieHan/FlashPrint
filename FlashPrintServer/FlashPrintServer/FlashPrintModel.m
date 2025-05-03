//
//  FlashPrintModel.m
//  FlashPrintServer
//
//  Created by Hans on 2025/4/29.
//

#import "FlashPrintModel.h"
#define ENTITY_NAME_PRINTER_TABEL @"FlashPrinter"

static FlashPrintModel * staticFlashPrintModel;
@interface FlashPrintModel(){
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}
@end

@implementation FlashPrintModel
+(FlashPrintModel *)shared{
    if (nil == staticFlashPrintModel){
        staticFlashPrintModel = [[FlashPrintModel alloc] init];
    }
    return staticFlashPrintModel;
}

-(FlashPrinter *)currentPrinter{
    NSArray *printers = [self existPrinters];
    if (0 == printers.count){
        return nil;
    }
    return printers.firstObject;
}

-(id)init{
    self = [super init];
    if (self){
        NSString *store_string = [NSHomeDirectory() stringByAppendingString:@"/Documents/FlashPrintData.sqlite"];
        NSURL *storeURL = [NSURL fileURLWithPath:store_string];
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FlashPrintModel" withExtension:@"momd"];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        if (nil == managedObjectModel){
            return nil;
        }
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        
        NSError *error = nil;
        NSPersistentStore *persistentStore = nil;
        if (nil == persistentStore){
            persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
            if (nil == persistentStore || error){
                NSLog(@"place store error.");
                return nil;
            }
        }
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
        [managedObjectContext persistentStoreCoordinator];
    }
    return self;
}



-(NSMutableArray <FlashPrinter *>*)existPrinters{
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME_PRINTER_TABEL inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completedDate" ascending:NO];
//    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
//    [fetchRequest setSortDescriptors:sortDescriptors];
    
//    NSPredicate *p = [NSPredicate predicateWithFormat:@"(book == %@ AND chapter=%ld AND section >= %ld AND section <= %ld)", bookName, chapter, fromSection, toSection];
//    [fetchRequest setPredicate:p];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error filtering search: %@", [error description]);
        return nil;
    }
    return [[NSMutableArray alloc] initWithArray:fetchedObjects];
}

-(BOOL)save{
    return [managedObjectContext save:nil];;
}

-(BOOL)removeItem:(NSManagedObject *)item{
    [managedObjectContext deleteObject:item];
    return [self save];
}

-(FlashPrinter *)createFlashPrinter{
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME_PRINTER_TABEL inManagedObjectContext:managedObjectContext];
    FlashPrinter *result = [[FlashPrinter alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    result.name = @"Unnamed";
    result.saturation = 1.f;
    result.contrast = 1.f;
    result.bright = 0.f;
    result.watermark = nil;
    return result;
}
@end
