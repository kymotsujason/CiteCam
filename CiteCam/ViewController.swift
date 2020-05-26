//
//  ViewController.swift
//  CiteCam
//
//  Barcode Scanner view that simply initiates a video feed that searches for a barcode.
//  On capture, translates into a ISBN and sends it to be translated into a citation.
//
//  Main function:
//  Scan barcodes with camera.
//  Convert barcodes to ISBN.
//  Send ISBN for conversion into citation.
//
//  Created by Jason Yue 11/04/16
//

import UIKit
import MTBBarcodeScanner

class ViewController: UIViewController {
    
    // Variables
    var scanner: MTBBarcodeScanner?
    
    // On load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set camera to entire view.
        scanner = MTBBarcodeScanner(previewView: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Begin scanning once fully loaded.
        self.scanner?.startScanning(resultBlock: { codes in
            let codeObjects = codes as! [AVMetadataMachineReadableCodeObject]?
            for code in codeObjects! {
                let stringValue = code.stringValue!
                
                // Ensure ISBN-13 protocol only.
                if (stringValue.characters.count == 13) {
                    var unfreeze = false
                    
                    // Freeze capture to let user know we found the barcode.
                    self.scanner?.freezeCapture()
                    
                    // Vibrate if device has vibration capability.
                    AudioServicesPlayAlertSound(UInt32(kSystemSoundID_Vibrate))
                    while(!unfreeze) {
                        unfreeze = GoogleBookService.bookSearch(isbn: stringValue)
                    }
                    self.scanner?.unfreezeCapture()
                }
            }
            
        }, error: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

