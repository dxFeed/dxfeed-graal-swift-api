//
//  Copyright (C) 2023 Devexperts LLC. All rights reserved.
//  This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
//  If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
/// Represents an extension of ``Order`` introducing analytics information,
/// e.g. adding to this order iceberg related information ``icebergPeakSize``, ``icebergHiddenSize``, ``icebergExecutedSize``
///
/// The collection of analytic order events of a symbol represents the most recent analytic information
/// that is available about orders on the market at any given moment of time.
///
/// [For more details see](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/AnalyticOrder.html)
public class AnalyticOrder: Order {
    public override var type: EventCode {
        return .analyticOrder
    }
    /*
     * Analytic flags property has several significant bits that are packed into an integer in the following way:
     *      31...2       1    0
     * +--------------+-------+-------+
     * |              |   IcebergType |
     * +--------------+-------+-------+
     */

    // TYPE values are taken from Type enum.
    private let icebergTypeMask = 3
    private let icebergTypeShift = 0

    /// Gets or sets iceberg peak size of this analytic order.
    public var icebergPeakSize: Double = .nan
    /// Gets or sets iceberg hidden size of this analytic order.
    public var icebergHiddenSize: Double = .nan
    /// Gets or sets iceberg executed size of this analytic order.
    public var icebergExecutedSize: Double = .nan
    /// Gets or sets iceberg type of this analytic order.
    public var icebergFlags: Int32 = 0
    /// Initializes a new instance of the <see cref="AnalyticOrder"/> class.
    public override init(_ eventSymbol: String) {
        super.init(eventSymbol)
    }

    /// Returns string representation of this candle event.
    override func toString() -> String {
        return
"""
AnalyticOrder{\(baseFieldsToString()), \
icebergPeakSize=\(icebergPeakSize), \
icebergHiddenSize=\(icebergHiddenSize) +
icebergExecutedSize=\(icebergExecutedSize) +
icebergType=\(icebergType)}
"""
    }
}

extension AnalyticOrder {
    /// Gets or sets iceberg type of this analytic order.
    public var icebergType: IcebergType {
        get {
            IcebergTypeExt.valueOf(value: BitUtil.getBits(flags: Int(icebergFlags),
                                                          mask: icebergTypeMask,
                                                          shift: icebergTypeShift))
        }
        set {
            icebergFlags = Int32(BitUtil.setBits(flags: Int(icebergFlags),
                                                 mask: icebergTypeMask,
                                                 shift: icebergTypeShift,
                                                 bits: newValue.rawValue))
        }
    }
}
