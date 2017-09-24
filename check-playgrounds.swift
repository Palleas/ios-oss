import Foundation
import Files

struct PlaygroundError: Error {
    let message: String
}

guard let productsDir = ProcessInfo.processInfo.environment["BUDDYBUILD_PRODUCTS_DIR"].flatMap({ try? Folder(path: $0) }) else {
    throw PlaygroundError(message: "Missing BUDDYBUILD_PRODUCTS_DIR")
}

guard let root = ProcessInfo.processInfo.environment["BUDDYBUILD_WORKSPACE"].flatMap({ try? Folder(path: $0) }) else {
    throw PlaygroundError(message: "Missing BUDDYBUILD_WORKSPACE")
}

print("Checking playgrounds...")


let playgrounds = root
    .subfolders
    .filter { $0.extension == "playground" }

for playground in playgrounds {
    print("Current playground \(playground.name)")

    let pages = playground
        .makeSubfolderSequence(recursive: true, includeHidden: false)
        .filter({ $0.extension == "xcplaygroundpage" })

    for page in pages {
        print("Current page \(page.name)")
        let pageContent = try page
            .makeFileSequence(recursive: true, includeHidden: false)
            .filter { $0.extension == "swift"}
            .map { try $0.readAsString() }
            .reduce("", +)


        try productsDir.createFile(named: "content-of-\(page.name).swift", contents: pageContent)

        let run = Process()
        run.launchPath = "/usr/bin/swift"


    }
}
