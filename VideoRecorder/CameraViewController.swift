//
//  CameraViewController.swift
//  VideoRecorder
//
//  Created by Paul Solt on 10/2/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

	lazy private var captureSession = AVCaptureSession()
	
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// FUTURE: Choose between front / back cameras
		setupCamera()
	}
	
	private func setupCamera() {
	
		// Get camera
		let camera = bestCamera()
		
		// Settings
		
		// Set the capture session on the cameraView
	}
	
	private func bestCamera() -> AVCaptureDevice {
		// Find a camera to use
		
		if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
			return device
		} else {
			print("No ultra wide camera found on back")
		}
		
		if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
			return device
		}
		
		fatalError("No cameras on the device (or you're running in the simulator)")
	}
	


    @IBAction func recordButtonPressed(_ sender: Any) {

	}
}

