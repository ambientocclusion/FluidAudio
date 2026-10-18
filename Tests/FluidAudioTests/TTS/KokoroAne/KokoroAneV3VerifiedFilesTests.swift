import XCTest

@testable import FluidAudio

final class KokoroAneV3VerifiedFilesTests: XCTestCase {

    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    private func writeFile(_ name: String, _ contents: String) throws -> URL {
        let url = directory.appendingPathComponent(name)
        try Data(contents.utf8).write(to: url)
        return url
    }

    func testRecordedFileIsUnchangedAfterReload() throws {
        let file = try writeFile("weight.bin", "weights")
        let recordURL = directory.appendingPathComponent(KokoroAneV3Assets.VerifiedFiles.fileName)

        var record = KokoroAneV3Assets.VerifiedFiles(manifestHash: "abc")
        record.record("weight.bin", at: file)
        record.save(to: recordURL)

        let reloaded = KokoroAneV3Assets.VerifiedFiles.load(from: recordURL, manifestHash: "abc")
        XCTAssertTrue(reloaded.isUnchanged("weight.bin", at: file))
    }

    func testRewrittenFileIsNotTrusted() throws {
        let file = try writeFile("weight.bin", "weights")
        var record = KokoroAneV3Assets.VerifiedFiles(manifestHash: "abc")
        record.record("weight.bin", at: file)

        try Data("other weights".utf8).write(to: file)
        XCTAssertFalse(record.isUnchanged("weight.bin", at: file))
    }

    func testModificationDateChangeIsNotTrusted() throws {
        let file = try writeFile("weight.bin", "weights")
        var record = KokoroAneV3Assets.VerifiedFiles(manifestHash: "abc")
        record.record("weight.bin", at: file)

        try FileManager.default.setAttributes(
            [.modificationDate: Date(timeIntervalSinceNow: 60)], ofItemAtPath: file.path)
        XCTAssertFalse(record.isUnchanged("weight.bin", at: file))
    }

    func testDifferentManifestDiscardsRecord() throws {
        let file = try writeFile("weight.bin", "weights")
        let recordURL = directory.appendingPathComponent(KokoroAneV3Assets.VerifiedFiles.fileName)
        var record = KokoroAneV3Assets.VerifiedFiles(manifestHash: "abc")
        record.record("weight.bin", at: file)
        record.save(to: recordURL)

        let reloaded = KokoroAneV3Assets.VerifiedFiles.load(from: recordURL, manifestHash: "def")
        XCTAssertFalse(reloaded.isUnchanged("weight.bin", at: file))
    }

    func testMissingFileAndUnknownPathAreNotTrusted() throws {
        let record = KokoroAneV3Assets.VerifiedFiles(manifestHash: "abc")
        XCTAssertFalse(record.isUnchanged("weight.bin", at: directory.appendingPathComponent("weight.bin")))
    }
}
