//
//  SaveDocumentPicker.swift
//  Spently
//
//  Created by David Wang on 2025/6/30.
//

import SwiftUI

struct SaveDocumentPicker: UIViewControllerRepresentable {
    var exporting: URL
    var asCopy: Bool = false
    var onSave: ([URL]) -> Void
    var onCancel: () -> Void

    init(exporting: URL, asCopy: Bool, onSave: @escaping ([URL]) -> Void, onCancel: @escaping () -> Void) {
        self.exporting = exporting
        self.asCopy = asCopy
        self.onCancel = onCancel
        self.onSave = onSave
    }
    
    init(exporting: URL, asCopy: Bool, onSave: @escaping ([URL]) -> Void) {
        self.init(exporting: exporting, asCopy: asCopy, onSave: onSave, onCancel: {})
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIDocumentPickerViewController(forExporting: [exporting], asCopy: asCopy)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator) {
        uiViewController.dismiss(animated: false)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: SaveDocumentPicker
        
        init(_ parent: SaveDocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onSave(urls)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onCancel()
        }
    }
}

#Preview {
//    SaveDocumentPicker()
}
