//
//  IconGeneratorViewModel.swift
//  IconGenerator
//
//  Created by MANAS VIJAYWARGIYA on 06/04/22.
//

import SwiftUI

class IconGeneratorViewModel: ObservableObject {
    
    // MARK: - Select Image for Icon
    @Published var pickedImage: NSImage?
    
    // MARK: - Loading & Alert
    @Published var isGenerating: Bool = false
    @Published var alertMsg: String = ""
    @Published var showAlert: Bool = false
    
    @Published var iconSizes: [Int] = [
        // 40, 60, 58, 87, 80, 120, 120, 180, 20, 40, 29, 58, 40, 80, 76, 152, 167, 1024, 16, 32, 32, 64, 128, 256, 256, 512, 512, 1024
        40, 20, 60, 58, 87, 80, 120, 180, 29, 58, 76, 152, 167, 1024, 16, 32, 64, 128, 256, 512,
    ]
    
    // MARK: - Picking Image using NSOpen Panel
    func PickImage() {
        let panel = NSOpenPanel()
        panel.title = "Choose a Picture"
        panel.showsResizeIndicator = true
        panel.showsHiddenFiles = false
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.image, .jpeg, .png]
        
        if panel.runModal() == .OK {
            if let result = panel.url?.path {
                let image = NSImage(contentsOf: URL(fileURLWithPath: result))
                self.pickedImage = image
            } else {
                // MARK: - Error
            }
        }
    }
    
    func generateIconSet() {
        // MARK: Steps
        // 1. Ask user where to store icons (Location)
        folderSelector { [self] folderURL in
            // 2. Creating AppIcon.appiconset folder in it
            let modifiedURL = folderURL.appendingPathComponent("Assets.xcassets").appendingPathComponent("AppIcon.appiconset")
            
            self.isGenerating = true
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let manager = FileManager.default
                    try manager.createDirectory(at: modifiedURL, withIntermediateDirectories: true, attributes: [:])
                    
                    // 3. Writing Contents.json file inside the folder
                    self.writeContentsFile(folderURL: modifiedURL.appendingPathComponent("Contents.json"))
                    
                    // 4. Generating Icon sets & writing inside the folder
                    if let pickedImage = self.pickedImage {
                        self.iconSizes.forEach { size in
                            let imageSize = CGSize(width: CGFloat(size), height: CGFloat(size))
                            let imageURL = modifiedURL.appendingPathComponent("\(size).png")
                            pickedImage.resizeImage(size: imageSize)
                                .writeImage(to: imageURL)
                        }
                        
                        DispatchQueue.main.async {
                            self.isGenerating = false
                            // saved alert
                            self.alertMsg = "Generated Successfully!"
                            self.showAlert.toggle()
                        }
                    }
                    
                }
                catch {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.isGenerating = false
                    }
                }
            }
        }
    }
    
    // MARK: Writing Contents.json
    func writeContentsFile(folderURL: URL) {
        do {
            let bundle = Bundle.main.path(forResource: "Contents", ofType: "json") ?? ""
            let url = URL(fileURLWithPath: bundle)
            
            try Data(contentsOf: url).write(to: folderURL, options: .atomic)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: Folder Selector using NSOpenPanel
    func folderSelector(completion: @escaping (URL) -> ()) {
        let panel = NSOpenPanel()
        panel.title = "Choose a Folder"
        panel.showsResizeIndicator = true
        panel.showsHiddenFiles = false
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowedContentTypes = [.folder]
        
        if panel.runModal() == .OK {
            if let result = panel.url?.path {
                completion(URL(fileURLWithPath: result))
            } else {
                // MARK: - Error
            }
        }
    }
}


// MARK: Entending NSImage to resize the image to its new size
extension NSImage {
    func resizeImage(size: CGSize) -> NSImage {
        // Reducing Scaling factor
        let scale = NSScreen.main?.backingScaleFactor ?? 1
        
        let newSize = CGSize(width: size.width / scale, height: size.height / scale)
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        
        // Drawing Image
        self.draw(in: NSRect(origin: .zero, size: newSize))
        
        newImage.unlockFocus()
        
        return newImage
    }
    
    // MARK: writing Resied Image to png format
    func writeImage(to: URL) {
        // Converting as PNG
        guard let data = tiffRepresentation, let representation = NSBitmapImageRep(data: data), let pngData = representation.representation(using: .png, properties: [:]) else { return }
        
        try? pngData.write(to: to, options: .atomic)
    }
}
