import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// =======================================================
// EXERCISE 1 — BASIC CONTINUATION
// =======================================================
// Goal:
// Convert a completion-handler API into async/await
// using withCheckedContinuation

func fetchInt(completion: @Sendable @escaping (Int) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        completion(99)
    }
}

func fetchIntAsync() async -> Int {
    await withCheckedContinuation { continuation in
        fetchInt { value in
            continuation.resume(returning: value)
        }
    }
}

// TEST (should print 99)
Task {
    let value = await fetchIntAsync()
    print("Exercise 1:", value)
}

// =======================================================
// EXERCISE 2 — THROWING CONTINUATION
// =======================================================
// Goal:
// Convert Result-based API into async throws
// using withCheckedThrowingContinuation

enum NetworkError: Error {
    case offline
}

func fetchMessage(shouldFail: Bool,
                  completion: @Sendable @escaping (Result<String, Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        shouldFail
        ? completion(.failure(NetworkError.offline))
        : completion(.success("Swift is fast"))
    }
}

// TODO:
// Implement async throwing version
func fetchMessageAsync(shouldFail: Bool) async throws -> String {
    try await withCheckedThrowingContinuation { throwingContinuation in
        fetchMessage(shouldFail: shouldFail) { result in
            switch result {
            case .success(let value):
                throwingContinuation.resume(returning: value)
            case .failure(let error):
                throwingContinuation.resume(throwing: error)
            }
        }
    }
}

// TEST
Task {
    do {
        let value = try await fetchMessageAsync(shouldFail: false)
        print("Exercise 2:", value)
    } catch {
        print("Exercise 2 error:", error)
    }
}

// =======================================================
// EXERCISE 3 — FIX THE DOUBLE-RESUME BUG
// =======================================================
// ⚠️ This code CRASHES at runtime
// Goal:
// Fix it so the continuation is resumed exactly once

func brokenAPI(completion: @escaping (Int) -> Void) {
    completion(1)
    completion(2) // ❌ bug
}

func brokenAPIAsync() async -> Int {
    var checkedContinuation: CheckedContinuation<Int, Never>?

    return await withCheckedContinuation { continuation in
        checkedContinuation = continuation
        brokenAPI { value in
            checkedContinuation?.resume(returning: value)
            checkedContinuation = nil
        }
    }
}

// TODO:
// Fix brokenAPIAsync WITHOUT modifying brokenAPI

// TEST (should print 1 and NOT crash)
Task {
    let value = await brokenAPIAsync()
    print("Exercise 3:", value)
}

// =======================================================
// EXERCISE 4 — DELEGATE → CONTINUATION
// =======================================================
// Goal:
// Bridge a delegate-style API to async/await

class FakeDownloader {
    var onFinish: (() -> Void)?

    func start() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.onFinish?()
        }
    }
}

// TODO:
// Implement async wrapper for FakeDownloader
func waitForDownload() async {
    let downloader = FakeDownloader()
    await withCheckedContinuation { continuation in
        downloader.onFinish = { continuation.resume() }
        downloader.start()
    }
}

// TEST
Task {
    print("Exercise 4: waiting...")
    await waitForDownload()
    print("Exercise 4: done")
}

// =======================================================
// EXERCISE 5 — FIX A MEMORY / LIFETIME BUG
// =======================================================
// ⚠️ This async function NEVER resumes
// Goal:
// Fix the continuation lifetime issue

class OneShotTimer {
    func fire(after seconds: Double, completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

func neverResumes() async {
    let timer = OneShotTimer()

    await withCheckedContinuation { continuation in
        timer.fire(after: 1) { [timer] in
            _ = timer
            continuation.resume()
        }
    }
}

// TODO:
// The bug is subtle. Fix it so this ALWAYS resumes.

// TEST
Task {
    print("Exercise 5: waiting...")
    await neverResumes()
    print("Exercise 5: done")
}
