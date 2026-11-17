//
//  UploadTests.swift
//  SnitchTests
//
//  Created by BOniani on 16/11/2026.
//

import Foundation
import Testing
@testable import Snitch

struct UploadTests {
    private let first = UUID()
    private let second = UUID()

    private var batch: Data {
        let events = [first, second].map { #"{"event":"tapped","uuid":"\#($0.uuidString.lowercased())"}"# }
        return Data(#"{"api_key":"phc_test","batch":[\#(events.joined(separator: ","))]}"#.utf8)
    }

    private func gzip(_ data: Data, fileName: String? = nil) throws -> Data {
        var bytes: [UInt8] = [0x1f, 0x8b, 8, fileName == nil ? 0 : 0x08, 0, 0, 0, 0, 0, 0xff]
        if let fileName { bytes += Array(fileName.utf8) + [0] }
        bytes += try (data as NSData).compressed(using: .zlib) as Data
        let size = UInt32(data.count)
        bytes += [0, 0, 0, 0] + (0..<4).map { UInt8(truncatingIfNeeded: size >> ($0 * 8)) }
        return Data(bytes)
    }

    private func entry(body: Data) -> NetworkEntry {
        NetworkEntry(url: URL(string: "https://posthog.test/batch"), method: "POST", requestBody: body)
    }

    @Test func unzipsGzip() throws {
        #expect(Gzip.unzip(try gzip(batch)) == batch)
        #expect(Gzip.unzip(try gzip(batch, fileName: "batch.json")) == batch)
    }

    @Test func leavesOtherDataAlone() throws {
        #expect(Gzip.unzip(batch) == nil)
        #expect(Gzip.unzip(try gzip(batch).prefix(20)) == nil)
    }

    @Test func aGzipUploadIsUnzippedAndListsItsEvents() throws {
        let upload = entry(body: try gzip(batch))
        #expect(upload.unzippedRequestBody == batch)
        #expect(upload.requestBodyIDs == [first, second])
    }

    @Test func aPlainBodyListsItsIDsWithoutUnzipping() {
        let upload = entry(body: batch)
        #expect(upload.unzippedRequestBody == nil)
        #expect(upload.requestBodyIDs == [first, second])
    }

    @Test func binaryBodiesHaveNoIDs() {
        #expect(entry(body: Data([0xff, 0xfe, 0x00, 0x81])).requestBodyIDs.isEmpty)
    }

    @Test func showsTheUnzippedBodyOnTheRequestSideOnly() throws {
        let upload = entry(body: try gzip(batch))
        #expect(upload.readableBody(on: .request) == batch)
        #expect(upload.readableBodySize(on: .request) == batch.count)
        #expect(upload.isUnzipped(on: .request))
        #expect(!upload.isUnzipped(on: .response))
        #expect(upload.body(on: .request) != batch)
    }

    @MainActor
    @Test func linksEventsAndTheUploadThatSentThem() {
        let network = NetworkStore()
        let other = entry(body: Data(#"{"query":"shoes"}"#.utf8))
        let upload = entry(body: batch)
        network.insert(other)
        network.insert(upload)

        let events = EventStore()
        let sent = AnalyticsEvent(source: "PostHog", name: "tapped", date: Date(timeIntervalSince1970: 1), id: first)
        let later = AnalyticsEvent(source: "PostHog", name: "viewed", date: Date(timeIntervalSince1970: 2), id: second)
        let unsent = AnalyticsEvent(source: "PostHog", name: "queued", date: Date(timeIntervalSince1970: 3))
        [sent, later, unsent].forEach(events.insert)

        let inspector = InspectorModel(store: network)
        let log = EventLogModel(store: events)
        #expect(inspector.upload(carrying: first)?.id == upload.id)
        #expect(inspector.upload(carrying: unsent.id) == nil)
        #expect(log.events(in: upload).map(\.name) == ["viewed", "tapped"])
        #expect(log.events(in: other).isEmpty)
    }
}
