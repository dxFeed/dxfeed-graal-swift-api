//
//  NativeInstrumentProfileReader.swift
//  DXFeedFramework
//
//  Created by Aleksey Kosylo on 29.08.23.
//

import Foundation
@_implementationOnly import graal_api

class NativeInstrumentProfileReader {
    let mapper = InstrumentProfileMapper()
    let reader: UnsafeMutablePointer<dxfg_instrument_profile_reader_t>?

    deinit {
        if let reader = reader {
            let thread = currentThread()
            _ = try? ErrorCheck.nativeCall(thread,
                                           dxfg_JavaObjectHandler_release(thread,
                                                                          &(reader.pointee.handler)))
        }
    }

    init() throws {
        let thread = currentThread()
        reader = try ErrorCheck.nativeCall(thread, dxfg_InstrumentProfileReader_new(thread))
    }

    func getLastModified() -> Long? {
        let thread = currentThread()
        let result = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfileReader_getLastModified(thread, reader))
        return result
    }

    func wasComplete() -> Bool {
        let thread = currentThread()
        let result = try? ErrorCheck.nativeCall(thread, dxfg_InstrumentProfileReader_wasComplete(thread, reader))
        return result == 1
    }

    func readFromFile(address: String) throws -> [InstrumentProfile] {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread,
                                               dxfg_InstrumentProfileReader_readFromFile(thread,
                                                                                         reader,
                                                                                         address.toCStringRef()))
        let instruments = convertFromNativeList(result)
        _ = try ErrorCheck.nativeCall(thread, dxfg_CList_InstrumentProfile_release(thread, result))
        return instruments
    }

    func readFromFile(address: String, user: String, password: String) throws -> [InstrumentProfile] {
        let thread = currentThread()
        let result = try ErrorCheck.nativeCall(thread,
                                               dxfg_InstrumentProfileReader_readFromFile2(thread,
                                                                                          reader,
                                                                                          address.toCStringRef(),
                                                                                          user.toCStringRef(),
                                                                                          password.toCStringRef()))
        let instruments = convertFromNativeList(result)
        _ = try ErrorCheck.nativeCall(thread, dxfg_CList_InstrumentProfile_release(thread, result))
        return instruments
    }

    private func convertFromNativeList(_ result:
                                       UnsafeMutablePointer<dxfg_instrument_profile_list>) -> [InstrumentProfile] {
        let count = result.pointee.size
        var instruments = [InstrumentProfile]()
        for index in 0..<Int(count) {
            if let element = result.pointee.elements[index] {
                let instrumnetProfile = mapper.fromNative(native: element)
                instruments.append(instrumnetProfile)
            }
        }
        return instruments
    }

    static func resolveSourceURL(address: String) -> String {
        let thread = currentThread()
        guard let result = try? ErrorCheck.nativeCall(thread,
                                                      dxfg_InstrumentProfileReader_resolveSourceURL(
                                                        thread,
                                                        address.toCStringRef())) else {
            return address
        }
        return String(pointee: result)
    }

    func read(data: Data, address: String) throws -> [InstrumentProfile] {
        let thread = currentThread()
        let inputStream = try data.withUnsafeBytes({ pointer in
            let inputStream = try ErrorCheck.nativeCall(thread,
                                                        dxfg_ByteArrayInputStream_new(thread,
                                                                                      pointer.baseAddress,
                                                                                      Int32(data.count)))
            return inputStream
        })
        let result = try ErrorCheck.nativeCall(thread,
                                               dxfg_InstrumentProfileReader_read2(thread,
                                                                                  reader,
                                                                                  inputStream,
                                                                                  address.toCStringRef()))
        let instruments = convertFromNativeList(result)
        _ = try ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread,
                                                                             &(inputStream.pointee.handler)))
        _ = try ErrorCheck.nativeCall(thread, dxfg_CList_InstrumentProfile_release(thread, result))
        return instruments
    }

    func readCompressed(data: Data) throws -> [InstrumentProfile] {
        let thread = currentThread()
        let inputStream = try data.withUnsafeBytes({ pointer in
            let inputStream = try ErrorCheck.nativeCall(thread,
                                                        dxfg_ByteArrayInputStream_new(thread,
                                                                                      pointer.baseAddress,
                                                                                      Int32(data.count)))

            return inputStream
        })

        let result = try ErrorCheck.nativeCall(thread,
                                               dxfg_InstrumentProfileReader_readCompressed(thread,
                                                                                           reader,
                                                                                           inputStream))
        let instruments = convertFromNativeList(result)
        _ = try ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread,
                                                                             &(inputStream.pointee.handler)))

        _ = try ErrorCheck.nativeCall(thread, dxfg_CList_InstrumentProfile_release(thread, result))
        return instruments
    }

    func read(data: Data) throws -> [InstrumentProfile] {
        let thread = currentThread()
        let inputStream = try data.withUnsafeBytes({ pointer in
            let inputStream = try ErrorCheck.nativeCall(thread,
                                                        dxfg_ByteArrayInputStream_new(thread,
                                                                                      pointer.baseAddress,
                                                                                      Int32(data.count)))

            return inputStream
        })
        let result = try ErrorCheck.nativeCall(thread,
                                               dxfg_InstrumentProfileReader_read(thread,
                                                                                 reader,
                                                                                 inputStream))
        let instruments = convertFromNativeList(result)
        _ = try ErrorCheck.nativeCall(thread, dxfg_JavaObjectHandler_release(thread,
                                                                             &(inputStream.pointee.handler)))

        _ = try ErrorCheck.nativeCall(thread, dxfg_CList_InstrumentProfile_release(thread, result))
        return instruments
    }
}
