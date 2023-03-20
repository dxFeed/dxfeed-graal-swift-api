//
//  GraalErrorCode.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 20.03.2023.
//

import Foundation

enum GraalErrorCode: Int32 {
    //No error occurred.
    case noError = 0
    
    //An unspecified error occurred.
    case unspecified = 1
    
    //An argument was NULL.
    case nullArgument = 2
    
    //The specified thread is not attached to the isolate.
    case unattachedThread = 4
    
    //The specified isolate is unknown.
    case uninitializedIsolate = 5
    
    //Locating the image file failed.
    case locateImageFailed = 6
    
    //Opening the located image file failed.
    case openImageFailed = 7
    
    //Mapping the heap from the image file into memory failed.
    case mapHeapFailed = 8
    
    //Reserving address space for the new isolate failed.
    case reserveAddressSpaceFailed = 801
    
    //The image heap does not fit in the available address space.
    case insufficientAddressSpace = 802
    
    //Setting the protection of the heap memory failed.
    case protectHeapFailed = 9
    
    //The version of the specified isolate parameters is unsupported.
    case unsupportedIsolateParametersVersion = 10
    
    //Initialization of threading in the isolate failed.
    case threadingInitializationFailed = 11
    
    //Some exception is not caught.
    case uncaughtException = 12
    
    //Initialization the isolate failed.
    case isolateInitializationFailed = 13
    
    //Opening the located auxiliary image file failed.
    case openAuxImageFailed = 14
    
    //Reading the opened auxiliary image file failed.
    case readAuxImageMetaFailed = 15
    
    //Mapping the auxiliary image file into memory failed.
    case mapAuxImageFailed = 16
    
    //Insufficient memory for the auxiliary image.
    case insufficientAuxImageMemory = 17
    
    //Auxiliary images are not supported on this platform or edition.
    case auxImageUnsupported = 18
    
    //Releasing the isolate's address space failed.
    case freeAddressSpaceFailed = 19
    
    //Releasing the isolate's image heap memory failed.
    case freeImageHeapFailed = 20
    
    //The auxiliary image was built from a different primary image.
    case auxImagePrimaryImageMismatch = 21
    
    //The isolate arguments could not be parsed.
    case argumentParsingFailed = 22
    
    //Current target does not support the following CPU features that are required by the image.
    case cpuFeatureCheckFailed = 23
}
