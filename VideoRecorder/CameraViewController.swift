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
	private var player: AVPlayer!
	
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// FUTURE: Choose between front / back cameras
		setupCamera()
		updateViews()
		
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
//		tapGesture.numberOfTapsRequired = 2
		view.addGestureRecognizer(tapGesture)
	}
	
	@objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
		// TODO: handle states!!!
		switch tapGesture.state {
		case .began:
			print("Tapped!")
		case .ended:
			print("Tapped (end)")
			
			replayRecording()
			
		default:
			print("Handle other states: \(tapGesture.state.rawValue)")
		}
	}
	
	private func replayRecording() {
		if let player = player {
			player.seek(to: CMTime.zero)
			player.play()
		}
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
		
		let microphone = audio()
		guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
			fatalError("Can't create input from microphone")
		}
		guard captureSession.canAddInput(audioInput) else {
			fatalError("Can't add audio input")
		}
		captureSession.addInput(audioInput)
		
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
	
	private func audio() -> AVCaptureDevice {
		
//		if let device = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .back)
		if let device = AVCaptureDevice.default(for: .audio) {
			return device
		}
		fatalError("No audio")
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
	
	func playMovie(url: URL) {
		player = AVPlayer(url: url)
		
		let playerLayer = AVPlayerLayer(player: player)
		var topRect = self.view.bounds
		topRect.size.height /= 4
		topRect.size.width /= 4
		topRect.origin.y = view.layoutMargins.top
		
		playerLayer.frame = topRect
		view.layer.addSublayer(playerLayer)
		
		player.play()
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
			self.playMovie(url: outputFileURL)
		}
	}
}


