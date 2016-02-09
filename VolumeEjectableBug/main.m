//
//  main.m
//  VolumeEjectableBug
//
//  Created by Boy van Amstel on 09/02/16.
//  Copyright © 2016 Danger Cove. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    // insert code here...
    
    // Get disks that return a value for the following keys
    NSArray *keys = [NSArray arrayWithObjects:NSURLVolumeNameKey, NSURLVolumeIsRemovableKey, NSURLVolumeIsEjectableKey, NSURLVolumeIsInternalKey, nil];
    // Skip hidden volumes
    NSVolumeEnumerationOptions options = NSVolumeEnumerationSkipHiddenVolumes;
    NSArray *urls = [[NSFileManager defaultManager] mountedVolumeURLsIncludingResourceValuesForKeys:keys options:options];
    
    // Loop through discovered disks
    NSString *output = @"";
    for (NSURL *url in urls) {
      
      // Get resource values
      NSError *error;
      NSNumber *isRemovable;
      NSNumber *isEjectable;
      NSNumber *isInternal;
      NSString *volumeName;
      [url getResourceValue:&isRemovable forKey:NSURLVolumeIsRemovableKey error:&error];
      [url getResourceValue:&isEjectable forKey:NSURLVolumeIsEjectableKey error:&error];
      [url getResourceValue:&isInternal forKey:NSURLVolumeIsInternalKey error:&error];
      [url getResourceValue:&volumeName forKey:NSURLVolumeNameKey error:&error];
      
      // Log error and exit
      if (error) {
        NSLog(@"Error getting values: %@", error);
        return 1;
      }
      
      // Get more drive info
      DADiskRef disk = NULL;
      DASessionRef session = DASessionCreate(kCFAllocatorDefault);
      CFDictionaryRef descDict = NULL;
      
      // Create session
      if (session == NULL) {
        NSLog(@"%@: Can't create a reference to a new DASession", volumeName);
        return 1;
      }
      
      // Create disk ref
      disk = DADiskCreateFromVolumePath(NULL, session, (__bridge CFURLRef)url);
      if (disk == NULL) {
        NSLog(@"%@: Can't create a DADisk reference", volumeName);
        return 1;
      }
      
      // Get disk description
      descDict = DADiskCopyDescription(disk);
      if (descDict == NULL) {
        NSLog(@"%@: Can't get the disk's Disk Arbitration description", volumeName);
        return 1;
      }
      
      // Get device protocol name
      NSString *deviceProtocolName = (__bridge NSString *)CFDictionaryGetValue(descDict, kDADiskDescriptionDeviceProtocolKey);
      if (deviceProtocolName) {
        output = [output stringByAppendingFormat:@"Disk: %@\n- Protocol: %@\n- Removable: %i\n- Ejectable: %i\n- Internal: %i\n\n", volumeName, deviceProtocolName, isRemovable.boolValue, isEjectable.boolValue, isInternal.boolValue];
        
      } else {
        NSLog(@"%@: Failed to get device protocol name", volumeName);
        return 1;
      }
      
      // Release
      CFRelease(descDict);
      CFRelease(disk);
      CFRelease(session);
    }
    
    // Log the result
    NSLog(@"Disk properties:\n%@", output);
  }
  return 0;
}
