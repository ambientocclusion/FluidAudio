import Foundation

/// A step of `KokoroAneManager.initialize`, reported so apps can show what a long load is doing.
/// Counts are 1-based positions within the current group of files or models.
public enum KokoroAneLoadStage: Sendable, Equatable {
    /// Reading the pinned asset manifest (fetched on first use).
    case checkingManifest
    /// Checksumming a cached file that has not been verified since it last changed.
    case verifyingFile(name: String, index: Int, count: Int)
    case downloadingFile(name: String, index: Int, count: Int)
    /// Compiling a source `.mlpackage` on device; happens once per model.
    case compilingModel(name: String, index: Int, count: Int)
    case loadingModel(name: String, index: Int, count: Int)
    /// Loading the variant's text frontend (G2P models, lexicons, dictionaries).
    case preparingTextFrontend
    case loadingVoice(String)
}

public typealias KokoroAneLoadProgressHandler = @Sendable (KokoroAneLoadStage) -> Void
