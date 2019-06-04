//
//  CameraViewController.swift
//  sport-on
//
//  Created by dimarious on 10.02.2019.
//  Copyright © 2019 Dmytro Doroshchuk. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var video = AVCaptureVideoPreviewLayer()

    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()       
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.post(name: NSNotification.Name("viewWillPresented"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.post(name: NSNotification.Name("viewWillDismissed"), object: nil)
        turnOffFlashlight()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("BarCodeViewControllerIsDismissed"), object: nil)
    }
    
    lazy var scanBarcodeFrame: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowRadius = 10.0
        view.layer.shadowOpacity = 0.9
        view.layer.shadowOffset = CGSize.zero
        view.layer.masksToBounds = false
        return view
    }()
    
    lazy var manuallyEnteringButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "pen.png")
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(alertForManualEntering), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width * 0.15, height: view.bounds.size.width * 0.15)
        button.layer.cornerRadius = button.bounds.size.width * 0.5
        button.clipsToBounds = true
        button.tintColor = .black
        button.backgroundColor = .white
        button.imageEdgeInsets = UIEdgeInsetsMake(5,5,5,5)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func alertForManualEntering() {
        Feedback.addAction.taptic(style: .light, enable: UserDefaults.standard.bool(forKey: "vibration"))
        let alert = UIAlertController(title: "add_card_manually".localized, message: "enter_13_digits".localized, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "add".localized, style: .default, handler: { _ in
            let textField = alert.textFields![0] as UITextField
            guard let enteredText = textField.text else { return }
            UserDefaults.standard.set(enteredText, forKey: "code")
            UserDefaults.standard.synchronize()
            self.showAlert(title: "card_added".localized, message: "№\(enteredText)", actionTitle: "ok".localized)
        })
        addAction.isEnabled = false
        alert.addTextField { textfield in
            textfield.keyboardType = .numberPad
            textfield.placeholder = "0123456789123"
            NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textfield,
                                                   queue: OperationQueue.main, using: { _  in
                                                    addAction.isEnabled = textfield.text?.count == 13
            })}
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .destructive, handler: nil))
        present(alert, animated: true)
    }
    
    lazy var flashButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "flash.png")
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width * 0.15, height: view.bounds.size.width * 0.15)
        button.layer.cornerRadius = button.bounds.size.width * 0.5
        button.clipsToBounds = true
        button.tintColor = .black
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(flashlightToggle), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    @objc func dismissCameraVC() {
        Feedback.addAction.taptic(style: .light, enable: UserDefaults.standard.bool(forKey: "vibration"))
        turnOffFlashlight()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func flashlightToggle() {
        Feedback.addAction.taptic(style: .light, enable: UserDefaults.standard.bool(forKey: "vibration"))
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                flashButton.backgroundColor = .white
                flashButton.tintColor = .black
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                    flashButton.backgroundColor = .black
                    flashButton.tintColor = UIColor(hexString: "#ffcc00")
                } catch {
                    print(error)
                }
            }
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    func turnOffFlashlight() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
            }
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    func showAlert(title: String, message: String, actionTitle: String) {
        Feedback.addAction.taptic(style: .success, enable: UserDefaults.standard.bool(forKey: "vibration"))
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: {_ in
            self.dismissCameraVC()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupUI() {
        view.backgroundColor = .black
        videoCapturing()
        [scanBarcodeFrame, flashButton, manuallyEnteringButton].forEach(self.view.addSubview)
        
        NSLayoutConstraint.activate([
            scanBarcodeFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanBarcodeFrame.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanBarcodeFrame.heightAnchor.constraint(equalToConstant: view.bounds.size.width * 0.3),
            scanBarcodeFrame.widthAnchor.constraint(equalToConstant: view.bounds.size.width * 0.8),
        
            flashButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            flashButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            flashButton.heightAnchor.constraint(equalTo: scanBarcodeFrame.heightAnchor, multiplier: 0.5),
            flashButton.widthAnchor.constraint(equalTo: flashButton.heightAnchor, multiplier: 1),
            
            manuallyEnteringButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            manuallyEnteringButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            manuallyEnteringButton.heightAnchor.constraint(equalTo: flashButton.heightAnchor, multiplier: 1),
            manuallyEnteringButton.widthAnchor.constraint(equalTo: flashButton.heightAnchor, multiplier: 1)
        ])
        showHintViews()
    }
    
    func showHintViews() {
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
        if !isFirstLaunch {
            hintUI()
            UserDefaults.standard.set(true, forKey: "firstLaunch")
        }
    }
    
    //MARK: Hint UI
    
    lazy var hintBackground: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        view.backgroundColor = .black
        view.alpha = 0.75
        return view
    }()
    
    lazy var hintScanLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "scan_with_frame".localized
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.contentMode = .center
        return label
    }()
    
    lazy var hintManualLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "damaged_barcode".localized
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textAlignment = .left
        label.contentMode = .center
        return label
    }()
    
    lazy var hintFlashLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "turn_flashlight".localized
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textAlignment = .left
        label.contentMode = .center
        return label
    }()
    
    lazy var hintClosehLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "swipe_view".localized
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.contentMode = .center
        return label
    }()
    
    lazy var hintOkButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(removeHintView), for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitle("ok".localized, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width * 0.15, height: view.bounds.size.width * 0.15)
        button.layer.cornerRadius = button.bounds.size.width * 0.5
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var hintManualArrow: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "arrow.png")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .white
        view.transform = view.transform.rotated(by: .pi * 3 / 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var hintFlashArrow: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "arrow-l.png")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .white
        view.transform = view.transform.rotated(by: .pi)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var hintScanArrow: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "arrow-l.png")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .white
        view.transform = view.transform.rotated(by: .pi * 3 / -4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    func hintUI() {
        [hintBackground, hintClosehLabel, hintScanLabel, hintManualLabel, hintFlashLabel, hintOkButton, hintManualArrow, hintFlashArrow, hintScanArrow] .forEach(view.addSubview)
        
        NSLayoutConstraint.activate([
            hintScanLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintScanLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: view.bounds.size.width * -0.3),
            
            hintClosehLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintClosehLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.size.width * 0.2),
            
            hintManualLabel.leadingAnchor.constraint(equalTo: manuallyEnteringButton.leadingAnchor),
            hintManualLabel.bottomAnchor.constraint(equalTo: manuallyEnteringButton.topAnchor, constant: view.bounds.size.width * -0.2),
            
            hintManualArrow.leadingAnchor.constraint(equalTo: manuallyEnteringButton.leadingAnchor, constant: view.bounds.size.width * 0.1),
            hintManualArrow.bottomAnchor.constraint(equalTo: manuallyEnteringButton.topAnchor, constant: view.bounds.size.width * -0.05),
            hintManualArrow.heightAnchor.constraint(equalTo: flashButton.heightAnchor, multiplier: 0.75),
            hintManualArrow.widthAnchor.constraint(equalTo: flashButton.widthAnchor, multiplier: 0.75),
            
            hintFlashArrow.trailingAnchor.constraint(equalTo: flashButton.trailingAnchor, constant: view.bounds.size.width * -0.2),
            hintFlashArrow.bottomAnchor.constraint(equalTo: flashButton.bottomAnchor, constant: flashButton.frame.height * -0.75),
            hintFlashArrow.heightAnchor.constraint(equalTo: flashButton.heightAnchor, multiplier: 0.75),
            hintFlashArrow.widthAnchor.constraint(equalTo: flashButton.widthAnchor, multiplier: 0.75),
            
            hintScanArrow.centerXAnchor.constraint(equalTo: hintScanLabel.centerXAnchor, constant: view.bounds.size.width * -0.4),
            hintScanArrow.centerYAnchor.constraint(equalTo: hintScanLabel.centerYAnchor, constant: view.bounds.size.width * 0.075),
            hintScanArrow.heightAnchor.constraint(equalTo: flashButton.heightAnchor, multiplier: 0.75),
            hintScanArrow.widthAnchor.constraint(equalTo: flashButton.widthAnchor, multiplier: 0.75),
            
            hintFlashLabel.trailingAnchor.constraint(equalTo: flashButton.trailingAnchor),
            hintFlashLabel.bottomAnchor.constraint(equalTo: flashButton.topAnchor, constant: view.bounds.size.width * -0.1),
            
            hintOkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hintOkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            hintOkButton.heightAnchor.constraint(equalTo: flashButton.heightAnchor, multiplier: 1),
            hintOkButton.widthAnchor.constraint(equalTo: flashButton.widthAnchor, multiplier: 1)
        ])
    }
    
    @objc func removeHintView() {
        Feedback.addAction.taptic(style: .light, enable: UserDefaults.standard.bool(forKey: "vibration"))
        [hintBackground, hintScanLabel, hintClosehLabel, hintManualLabel, hintFlashLabel, hintOkButton, hintManualArrow, hintFlashArrow, hintScanArrow].forEach { $0.removeFromSuperview() }
    }
    
    func videoCapturing() {
        let session = AVCaptureSession()
        guard let capturedevice = AVCaptureDevice.default(for: AVMediaType.video) else {return}
        do {
            let input = try AVCaptureDeviceInput(device: capturedevice)
            session.addInput(input)
        } catch {
            print("error")
        }
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.ean13]
        video = AVCaptureVideoPreviewLayer(session: session)
        video.videoGravity = AVLayerVideoGravity.resizeAspectFill
        video.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
        video.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        view.layer.addSublayer(video)
        session.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects != nil && metadataObjects.count != 0 else { return }
        guard let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }
        if let codeNumber = object.stringValue, object.type == AVMetadataObject.ObjectType.ean13 {
            UserDefaults.standard.set(object.stringValue, forKey: "code")
            UserDefaults.standard.synchronize()
            showAlert(title: "card_added".localized, message: "№\(codeNumber)", actionTitle: "ok".localized)
        }
    }
}
