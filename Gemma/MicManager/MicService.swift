//
//  MicService.swift
//  Gemma
//
//  Created by Andre jones on 4/4/25.
//


import AVFoundation
import Foundation
import UIKit

class MicService: ObservableObject {
    
    var isAuthorized: Bool {
        get async {
            await AVCaptureDevice.requestAccess(for: .audio)
        }
    }
}

