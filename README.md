<picture>
 <source media="(prefers-color-scheme: dark)" srcset="docs/images/logo_dark.svg">
 <img alt="light" src="docs/images/logo_light.svg">
</picture>

This package provides access to [dxFeed market data](https://dxfeed.com/market-data/).
The library is built as a language-specific wrapper over
the [dxFeed Graal Native](https://dxfeed.jfrog.io/artifactory/maven-open/com/dxfeed/graal-native-api/) library,
which was compiled with [GraalVM Native Image](https://www.graalvm.org/latest/reference-manual/native-image/)
and [dxFeed Java API](https://docs.dxfeed.com/dxfeed/api/overview-summary.html) (our flagman API).

:warning: It’s an **alpha** version and still under active development. **Don’t use it in a production environment.**


![Language](https://img.shields.io/badge/language-swift-blueviolet)
![Platform](https://img.shields.io/badge/platform-ios--arm64%20%7C%20osx--x64%20%7C%20osx--arm64-lightgrey)
![License](https://img.shields.io/badge/license-MPL--2.0-orange)


## Table of Contents

- [Overview](#overview)
    * [Milestones](#milestones)
    * [Future Development](#future-development)
    * [Implementation Details](#implementation-details)
- [Documentation](#documentation)
- [Usage](#usage)
- [Current State](#current-state)

## Overview

dxFeed Graal Swift API allows developers to create efficient applications in Swift language. This enables developers to leverage all the benefits of native app development, resulting in maximum performance and usability for end users.


### Milestones

As part of our ongoing development efforts, we are pleased to announce that a new repository is currently under construction and is expected to be completed by Q4’2023. We are working diligently to ensure that this new repository meets all of our standards for performance, security, and scalability. We will be providing regular updates throughout the development process.

If you have any questions, please contact us via
our [customer portal](https://jira.in.devexperts.com/servicedesk/customer/portal/1/create/122).

### Future Development

Features planned with **high priority**:

* add all market events
* add FEED Endpoint role
* provide tools and samples
* provide Swift packages
* generate documentation

---
Features planned for the **next stage**:

* Implement a model
  of [incremental updates](https://kb.dxfeed.com/en/data-services/real-time-data-services/-net-api-incremental-updates.html)
  in Java API and add it to Swift API
* Implement OrderBookModel with advanced logic (e.g., OnNewBook, OnBookUpdate, OnBookIncrementalChange) in Java API and
  add it to Swift API
* Add samples or implement a convenient API
  for [Candlewebservice](https://kb.dxfeed.com/en/data-services/aggregated-data-services/candlewebservice.html)

### Implementation Details

We use [GraalVM Native Image](https://www.graalvm.org/latest/reference-manual/native-image/) technology and specially
written code that *wraps* Java methods into native ones
to get dynamically linked libraries for different platforms (Linux, macOS, and Windows) based on
the [latest Java API package](https://dxfeed.jfrog.io/artifactory/maven-open/com/devexperts/qd/dxfeed-api/).

Then, the resulting dynamic link library (dxFeed Graal-native) is used through
C [ABI](https://en.wikipedia.org/wiki/Application_binary_interface) (application binary interface),
and we write programming interfaces that describe our business model (similar to Java API).

As a result, we get a full-featured, similar performance as with Java API.
Regardless of the language, writing the final application logic using API calls will be very similar (only the syntax
will be amended, *"best practices"*, specific language restrictions)

Below is a scheme of this process:

<picture>
 <source media="(prefers-color-scheme: dark)" srcset="docs/images/scheme_dark.svg">
 <img alt="light" src="docs/images/scheme_light.svg">
</picture>

## Documentation

Find useful information in our self-service dxFeed Knowledge Base or Swift API documentation:

- [dxFeed Graal Swift API documentation]()
- [dxFeed Knowledge Base](https://kb.dxfeed.com/index.html?lang=en)
    * [Getting Started](https://kb.dxfeed.com/en/getting-started.html)
    * [Troubleshooting](https://kb.dxfeed.com/en/troubleshooting-guidelines.html)
    * [Market Events](https://kb.dxfeed.com/en/data-model/dxfeed-api-market-events.html)
    * [Event Delivery contracts](https://kb.dxfeed.com/en/data-model/model-of-event-publishing.html#event-delivery-contracts)
    * [dxFeed API Event classes](https://kb.dxfeed.com/en/data-model/model-of-event-publishing.html#dxfeed-api-event-classes)
    * [Exchange Codes](https://kb.dxfeed.com/en/data-model/exchange-codes.html)
    * [Order Sources](https://kb.dxfeed.com/en/data-model/qd-model-of-market-events.html#order-x)
    * [Order Book reconstruction](https://kb.dxfeed.com/en/data-model/dxfeed-order-book/order-book-reconstruction.html)
    * [Symbology Guide](https://kb.dxfeed.com/en/data-model/symbology-guide.html)


## Usage

```csharp
let endpoint = DXEndpoint.builder()
    .withPropery("dxfeed.address", "demo.dxfeed.com:7300")
    .build()
let subscription = endpoint.getFeed().createSubscription(EventType.Quote)
subscription.addListener { events in
     for e in events {
         print(e)
     }
}
subscription.addSymbols("AAPL")
```

<details>
<summary>Output</summary>
<br>

```
I 221219 224811.681 [main] QD - Using QDS-3.313+file-UNKNOWN+mars-UNKNOWN+monitoring-UNKNOWN+tools-UNKNOWN, (C) Devexperts
I 221219 224811.695 [main] QD - Using scheme com.dxfeed.api.impl.DXFeedScheme DH2FdjP0DtOEIOAbE4pRVpmJsPnaZzAo1mICPJ6b06w
I 221219 224812.010 [main] QD - qd with collectors [Ticker, Stream, History]
I 221219 224812.017 [main] ClientSocket-Distributor - Starting ClientSocketConnector to demo.dxfeed.com:7300
I 221219 224812.017 [demo.dxfeed.com:7300-Reader] ClientSocketConnector - Resolving IPs for demo.dxfeed.com
I 221219 224812.021 [demo.dxfeed.com:7300-Reader] ClientSocketConnector - Connecting to 208.93.103.170:7300
I 221219 224812.170 [demo.dxfeed.com:7300-Reader] ClientSocketConnector - Connected to 208.93.103.170:7300
D 221219 224812.319 [demo.dxfeed.com:7300-Reader] QD - Distributor received protocol descriptor multiplexor@WQMPz [type=qtp, version=QDS-3.306, opt=hs, mars.root=mdd.demo-amazon.multiplexor-demo1] sending [TICKER, STREAM, HISTORY, DATA] from 208.93.103.170
Quote{AAPL, eventTime=0, time=20221219-223311.000, timeNanoPart=0, sequence=0, bidTime=20221219-223311, bidExchange=Q, bidPrice=132.16, bidSize=2, askTime=20221219-223311, askExchange=K, askPrice=132.17, askSize=10}
Quote{AAPL, eventTime=0, time=20221219-223312.000, timeNanoPart=0, sequence=0, bidTime=20221219-223312, bidExchange=Q, bidPrice=132.16, bidSize=6, askTime=20221219-223312, askExchange=K, askPrice=132.17, askSize=10}
Quote{AAPL, eventTime=0, time=20221219-223312.000, timeNanoPart=0, sequence=0, bidTime=20221219-223312, bidExchange=K, bidPrice=132.16, bidSize=10, askTime=20221219-223312, askExchange=V, askPrice=132.17, askSize=4}
```

</details>

## Current State

### Endpoint Roles

- [ ] [Feed](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXEndpoint.Role.html#FEED)
  connects to the remote data feed provider and is optimized for real-time or delayed data processing,
  **this is a default role**

- [ ] [StreamFeed](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXEndpoint.Role.html#STREAM_FEED)
  is similar to `Feed` and also connects to the remote data feed provider but is designed for bulk data parsing from
  files

- [ ] [Publisher](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXEndpoint.Role.html#PUBLISHER)
  connects to the remote publisher hub (also known as multiplexor) or creates a publisher on the local host

- [ ] [StreamPublisher](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXEndpoint.Role.html#STREAM_PUBLISHER)
  is similar to `Publisher` and also connects to the remote publisher hub, but is designed for bulk data publishing


- [ ] [LocalHub](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXEndpoint.Role.html#LOCAL_HUB)
  is a local hub without the ability to establish network connections. Events published via `Publisher` are delivered to
  local `Feed` only

- [ ] [OnDemandFeed](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXEndpoint.Role.html#ON_DEMAND_FEED)
  is similar to `Feed`, but it is designed to be used
  with  [OnDemandService](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/ondemand/OnDemandService.html) for historical
  data replay only

### Event Types

- [ ] [Order](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Order.html)
  is a snapshot of the full available market depth for a symbol

- [ ] [SpreadOrder](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/SpreadOrder.html)
  is a snapshot of the full available market depth for all spreads

- [ ] [AnalyticOrder](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/AnalyticOrder.html)
  is an `Order` extension that introduces analytic information, such as adding iceberg-related information to a given
  order

- [ ] [Trade](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Trade.html)
  is a snapshot of the price and size of the last trade during regular trading hours and an overall day volume and day
  turnover

- [ ] [TradeETH](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/TradeETH.html)
  is a snapshot of the price and size of the last trade during extended trading hours and the extended trading hours day
  volume and day turnover

- [ ] [Candle](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/Candle.html)
  event with open, high, low, and close prices and other information for a specific period

- [ ] [Quote](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Quote.html)
  is a snapshot of the best bid and ask prices and other fields that change with each quote

- [ ] [Profile](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Profile.html)
  is a snapshot that contains the security instrument description

- [ ] [Summary](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/Summary.html)
  is a snapshot of the trading session, including session highs, lows, etc.

- [x] [TimeAndSale](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/TimeAndSale.html)
  represents a trade or other market event with price, such as the open/close price of a market, etc.

- [ ] [Greeks](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/option/Greeks.html)
  is a snapshot of the option price, Black-Scholes volatility, and greeks

- [ ] [Series](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/option/Series.html)
  is a snapshot of computed values available for all options series for a given underlying symbol based on options
  market prices

- [ ] [TheoPrice](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/option/TheoPrice.html)
  is a snapshot of the theoretical option price computation that is periodically performed
  by [dxPrice](http://www.devexperts.com/en/products/price.html) model-free computation

- [ ] [Underlying](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/option/Underlying.html)
  is a snapshot of computed values available for an option underlying symbol based on the market’s option prices

- [ ] [OptionSale](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/market/OptionSale.html)
  represents a trade or another market event with the price (for example, market open/close price, etc.) for each option
  symbol listed under the specified `Underlying`

- [ ] [Configuration](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/misc/Configuration.html)
  is an event with an application-specific attachment

- [ ] [Message](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/misc/Message.html)
  is an event with an application-specific attachment

### Subscription Symbols

- [x] String
  is a string representation of the symbol

- [ ] [TimeSeriesSubscriptionSymbol](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/osub/TimeSeriesSubscriptionSymbol.html)
  represents subscription to time-series events

- [ ] [IndexedEventSubscriptionSymbol](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/osub/IndexedEventSubscriptionSymbol.html)
  represents subscription to a specific source of indexed events

- [ ] [WildcardSymbol.ALL](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/osub/WildcardSymbol.html)
  represents a  *wildcard* subscription to all events of the specific event type

- [ ] [CandleSymbol](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/CandleSymbol.html)
  is a symbol used with [DXFeedSubscription](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html)
  class to subscribe for [Candle](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/event/candle/Candle.html) events

### Subscriptions & Models

- [ ] [DXFeedSubscription](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedSubscription.html)
  is a subscription for a set of symbols and event types

- [ ] [DXFeedTimeSeriesSubscription](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeedTimeSeriesSubscription.html)
  extends `DXFeedSubscription` to conveniently subscribe to time series events for a set of symbols and event types
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/api/DXFeedConnect.java))

- [ ] [GetLastEvent](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#getLastEvent-E-)
  returns the last event for the specified event instance
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/api/DXFeedSample.java))

- [ ] [GetLastEvents](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#getLastEvents-java.util.Collection-)
  returns the last events for the specified event instances list

- [ ] [GetLastEventPromise](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#getLastEventPromise-java.lang.Class-java.lang.Object-)
  requests the last event for the specified event type and symbol
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/console/LastEventsConsole.java))

- [ ] [GetLastEventsPromises](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#getLastEventsPromises-java.lang.Class-java.util.Collection-)
  requests the last events for the specified event type and symbol collection

- [ ] [GetLastEventIfSubscribed](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#getLastEventIfSubscribed-java.lang.Class-java.lang.Object-)
  returns the last event for the specified event type and symbol if there’s a subscription for it

- [ ] [GetIndexedEventsPromise](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#getIndexedEventsPromise-java.lang.Class-java.lang.Object-com.dxfeed.event.IndexedEventSource-)
  requests an indexed events list for the specified event type, symbol, and source

- [ ] [GetIndexedEventsIfSubscribed](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#getIndexedEventsIfSubscribed-java.lang.Class-java.lang.Object-com.dxfeed.event.IndexedEventSource-)
  returns a list of indexed events for the specified event type, symbol, and source, if there’s a subscription for it

- [ ] [GetTimeSeriesPromise](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#getTimeSeriesPromise-java.lang.Class-java.lang.Object-long-long-)
  requests time series events for the specified event type, symbol, and time range
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/_simple_/FetchDailyCandles.java))

- [ ] [GetTimeSeriesIfSubscribed](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/api/DXFeed.html#getTimeSeriesIfSubscribed-java.lang.Class-java.lang.Object-long-long-)
  requests time series events for the specified event type, symbol, and time range if there’s a subscription for it

- [ ] [TimeSeriesEventModel](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/model/TimeSeriesEventModel.html)
  is a model of a list of time series events
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/ui/swing/DXFeedCandleChart.java))

- [ ] [IndexedEventModel](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/model/IndexedEventModel.html)
  is an indexed event list model
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/ui/swing/DXFeedTimeAndSales.java))

- [ ] [OrderBookModel](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/model/market/OrderBookModel.html)
  is a model of convenient Order Book management
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/ui/swing/DXFeedMarketDepth.java))

### IPF & Schedule

- [ ] [InstrumentProfile](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/ipf/InstrumentProfile.html)
  represents basic profile information about a market instrument
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/ipf/DXFeedIpfConnect.java))

- [ ] [InstrumentProfileCollector](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/ipf/live/InstrumentProfileCollector.html)
  collects instrument profile updates and provides the live instrument profiles list
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/ipf/DXFeedLiveIpfSample.java))

- [ ] [Schedule](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/schedule/Schedule.html)
  provides an API to retrieving and exploring the trading schedules of various exchanges and different financial
  instrument classes
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/schedule/ScheduleSample.java))

### Services

- [ ] [OnDemandService](https://docs.dxfeed.com/dxfeed/api/com/dxfeed/ondemand/OnDemandService.html)
  provides on-demand historical tick data replay controls
  ([Java API sample](https://github.com/devexperts/QD/blob/master/dxfeed-samples/src/main/java/com/dxfeed/sample/ondemand/OnDemandSample.java))
