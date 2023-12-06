//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation

/// List of graal error codes.
/// 
/// The error description was obtained from github.
/// [Graal GitHub] (https://github.com/oracle/graal/blob/f195395329fba573afc6f81c5e70a18ac334dd10/substratevm/src/com.oracle.svm.core/src/com/oracle/svm/core/c/function/CEntryPointErrors.java#L43)
enum GraalErrorCode: Int32, CustomStringConvertible {
    case noError = 0
    /// An unspecified error occurred
    case unspecified = 1
    /// An unspecified error occurred
    case nullArgument = 2
    /// The specified thread is not attached to the isolate
    case unattachedThread = 4
    /// The specified isolate is unknown
    case uninitializedIsolate = 5
    /// Locating the image file failed
    case locateImageFailed = 6
    /// Opening the located image file failed
    case openImageFailed = 7
    /// Mapping the heap from the image file into memory failed
    case mapHeapFailed = 8
    /// Reserving address space for the new isolate failed
    case reserveAddressSpaceFailed = 801
    /// The image heap does not fit in the available address space
    case insufficientAddressSpace = 802
    /// Setting the protection of the heap memory failed
    case protectHeapFailed = 9
    /// The version of the specified isolate parameters is unsupported
    case unsupportedIsolateParametersVersion = 10
    /// Initialization of threading in the isolate failed
    case threadingInitializationFailed = 11
    /// Some exception is not caught
    case uncaughtException = 12
    /// Initialization the isolate failed
    case isolateInitializationFailed = 13
    /// Opening the located auxiliary image file failed
    case openAuxImageFailed = 14
    /// Reading the opened auxiliary image file failed
    case readAuxImageMetaFailed = 15
    /// Mapping the auxiliary image file into memory failed
    case mapAuxImageFailed = 16
    /// Insufficient memory for the auxiliary image
    case insufficientAuxImageMemory = 17
    /// Auxiliary images are not supported on this platform or edition
    case auxImageUnsupported = 18
    /// Releasing the isolate's address space failed
    case freeAddressSpaceFailed = 19
    /// Releasing the isolate's image heap memory failed
    case freeImageHeapFailed = 20
    /// The auxiliary image was built from a different primary image
    case auxImagePrimaryImageMismatch = 21
    /// The isolate arguments could not be parsed
    case argumentParsingFailed = 22
    /// Current target does not support the following CPU features that are required by the image
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
