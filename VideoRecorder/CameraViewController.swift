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
	lazy private var fileOutput = AVCaptureMovieFileOutput()
	
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// FUTURE: Choose between front / back cameras
		setupCamera()
		updateViews()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
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
		
		// Input
		guard captureSession.canAddInput(cameraInput) else {
			fatalError("This session can't handle this type of input")
		}
		captureSession.addInput(cameraInput)
		
		if captureSession.canSetSessionPreset(.hd1920x1080) {
			captureSession.sessionPreset = .hd1920x1080
		}
		
		// Output
		guard captureSession.canAddOutput(fileOutput) else {
			fatalError("Cannot record to a movie file")
		}
		captureSession.addOutput(fileOutput)
		
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
		record()
	}
	
	func record() {
		if fileOutput.isRecording {
			fileOutput.stopRecording()
		} else {
			fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
		}
	}
	
	private func newRecordingURL() -> URL {
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime]

		let name = formatter.string(from: Date())
		let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
		print(fileURL.path)
		return fileURL
	}
	
	func updateViews() {
		recordButton.isSelected = fileOutput.isRecording
		
		if recordButton.isSelected {
			recordButton.tintColor = .black
		} else {
			recordButton.tintColor = .red
		}
	}
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
	func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
		
		DispatchQueue.main.async {
			self.updateViews()
		}
	}
	
	func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
		
		DispatchQueue.main.async {
			self.updateViews()
		}
	}
}


