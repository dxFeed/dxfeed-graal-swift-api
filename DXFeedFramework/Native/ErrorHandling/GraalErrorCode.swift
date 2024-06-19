//
//  GraalErrorCode.swift
//  DxFeedSwiftFramework
//
//  Created by Aleksey Kosylo on 20.03.2023.
//

import Foundation

enum GraalErrorCode: Int32, CustomStringConvertible {
    case noError = 0
    case unspecified = 1
    case nullArgument = 2
    case unattachedThread = 4
    case uninitializedIsolate = 5
    case locateImageFailed = 6
    case openImageFailed = 7
    case mapHeapFailed = 8
    case reserveAddressSpaceFailed = 801
    case insufficientAddressSpace = 802
    case protectHeapFailed = 9
    case unsupportedIsolateParametersVersion = 10
    case threadingInitializationFailed = 11
    case uncaughtException = 12
    case isolateInitializationFailed = 13
    case openAuxImageFailed = 14
    case readAuxImageMetaFailed = 15
    case mapAuxImageFailed = 16
    case insufficientAuxImageMemory = 17
    case auxImageUnsupported = 18
    case freeAddressSpaceFailed = 19
    case freeImageHeapFailed = 20
    case auxImagePrimaryImageMismatch = 21
    case argumentParsingFailed = 22
    case cpuFeatureCheckFailed = 23

    static let dict: [GraalErrorCode: String] = [
        .noError: "No error occurred.",
        .unspecified: "An unspecified error occurred.",
        .nullArgument: "An argument was NULL.",
        .unattachedThread: "The specified thread is not attached to the isolate.",
        .uninitializedIsolate: "The specified isolate is unknown.",
        .locateImageFailed: "Locating the image file failed.",
        .openImageFailed: "Opening the located image file failed.",
        .mapHeapFailed: "Mapping the heap from the image file into memory failed.",
        .reserveAddressSpaceFailed: "Reserving address space for the new isolate failed.",
        .insufficientAddressSpace: "The image heap does not fit in the available address space.",
        .protectHeapFailed: "Setting the protection of the heap memory failed.",
        .unsupportedIsolateParametersVersion: "The version of the specified isolate parameters is unsupported.",
        .threadingInitializationFailed: "Initialization of threading in the isolate failed.",
        .uncaughtException: "Some exception is not caught.",
        .isolateInitializationFailed: "Initialization the isolate failed.",
        .openAuxImageFailed: "Opening the located auxiliary image file failed.",
        .readAuxImageMetaFailed: "Reading the opened auxiliary image file failed.",
        .mapAuxImageFailed: "Mapping the auxiliary image file into memory failed.",
        .insufficientAuxImageMemory: "Insufficient memory for the auxiliary image.",
        .auxImageUnsupported: "Auxiliary images are not supported on this platform or edition.",
        .freeAddressSpaceFailed: "Releasing the isolate's address space failed.",
        .freeImageHeapFailed: "Releasing the isolate's image heap memory failed.",
        .auxImagePrimaryImageMismatch: "The auxiliary image was built from a different primary image.",
        .argumentParsingFailed: "The isolate arguments could not be parsed.",
        .cpuFeatureCheckFailed: """
        Current target does not support the following CPU features that are required by the image.
"""
    ]
    public var description: String {
        return GraalErrorCode.dict[self] ?? "Description for \(self) is undefined."
    }
}
