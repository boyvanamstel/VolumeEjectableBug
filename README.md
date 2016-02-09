# NSURLVolumeIsRemovableKey and NSURLVolumeIsEjectableKey return false while drives are ejectable and removable
When querying an NSURL that points to an external hard drive (note that it has to be an external hard drive. SD cards etc. do work properly) with NSURLVolumeIsRemovableKey and NSURLVolumeIsEjectableKey they always return false, while the volumes can actually be ejected from both Finder and code.

## Steps to Reproduce:
* Create an NSURL that points to a removable (external) drive.

```NSURL *url = [NSURL fileURLWithPath:@"/Volumes/Some_disk"];```

* Get the resource value for NSURLVolumeIsRemovableKey or NSURLVolumeIsEjectableKey:

```
// Get resource values
NSError *error;
NSNumber *isRemovable;
NSNumber *isEjectable;
[url getResourceValue:&isRemovable forKey:NSURLVolumeIsRemovableKey error:&error];
[url getResourceValue:&isEjectable forKey:NSURLVolumeIsEjectableKey error:&error];
```

*. Log the value somewhere.

NSLog(@"isRemovable: %i, isEjectable: %i", isRemovable.boolValue, isEjectable.boolValue);

* Note that isRemovable.boolValue and isEjectable.boolValue will be 0 for disks that can actually be removed.

## Expected Results:
isRemovable.boolValue and isEjectable.boolValue should be 1 for drives that can be ejected from the system through Finder or through code.

## Actual Results:
isRemovable.boolValue and isEjectable.boolValue return 0.
