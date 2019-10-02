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
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		print("Start running")
		captureSession.startRunning()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		print("Stop running")
		captureSession.stopRunning()
	}
	
	private func setupCamera() {
	
		// Get camera
		let camera = bestCamera()
		
		guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
			fatalError("Can't create an input from this camera device")
		}
		
		guard captureSession.canAddInput(cameraInput) else {
			fatalError("This session can't handle this type of input")
		}
		
		captureSession.addInput(cameraInput)
		
		if captureSession.canSetSessionPreset(.hd1920x1080) {
			captureSession.sessionPreset = .hd1920x1080
		}
		
		captureSession.commitConfiguration()
		
		cameraView.session = captureSession
		
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

