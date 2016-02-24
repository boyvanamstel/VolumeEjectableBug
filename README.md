# rdar://24565565

# Answer from Apple

Engineering has determined that this issue behaves as intended based on the following information: 

In the IORegistry, the “Elements” volume is “disk8” and both the “Removable” and “Ejectable” properties are “No”. That’s why the NSURLVolumeIsRemovableKey and NSURLVolumeIsEjectableKey are returning false.

The fact that Finder is displaying the eject icon is based on NSURLVolumeIsInternalKey being false (the drive is external), not due to  NSURLVolumeIsRemovableKey or NSURLVolumeIsEjectableKey. The Finder provides a way to unmount/eject external devices.

NSURLVolumeIsRemovableKey means the drive (i.e. a floppy disk, MO, DVD, etc) has media that is removable. NSURLVolumeIsEjectableKey means the device should have DADiskEject() called on it before it is unmounted (which on a disk drive with non-removable media may be needed to shut the hardware down safely).

## NSURLVolumeIsRemovableKey and NSURLVolumeIsEjectableKey return false while drives are ejectable and removable
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

```NSLog(@"isRemovable: %i, isEjectable: %i", isRemovable.boolValue, isEjectable.boolValue);```

* Note that isRemovable.boolValue and isEjectable.boolValue will be 0 for disks that can actually be removed.

## Expected Results:
isRemovable.boolValue and isEjectable.boolValue should be 1 for drives that can be ejected from the system through Finder or through code.

## Actual Results:
isRemovable.boolValue and isEjectable.boolValue return 0.

## Application Output:

When I run the command line application I made, it returns the following output:

```
2016-02-09 12:57:48.325 VolumeEjectableBug[17743:373814] Disk properties:
Disk: Macintosh HD
- Protocol: SATA
- Removable: 0
- Ejectable: 0
- Internal: 1

Disk: Some Disk
- Protocol: FireWire
- Removable: 0
- Ejectable: 0
- Internal: 0

Disk: Another Disk
- Protocol: FireWire
- Removable: 0
- Ejectable: 0
- Internal: 0

Disk: B
- Protocol: USB
- Removable: 1
- Ejectable: 1
- Internal: 0

Disk: G
- Protocol: USB
- Removable: 1
- Ejectable: 1
- Internal: 0

Disk: Elements
- Protocol: USB
- Removable: 0
- Ejectable: 0
- Internal: 0

Program ended with exit code: 0
```

Especially the disks called Elements, Some Disk and Another Disk are interesting. They appear ejectable in Finder and can be ejected through code, but they return 0 for both NSURLVolumeIsRemovableKey and NSURLVolumeIsEjectableKe.
