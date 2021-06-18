//
//  ViewController.swift
//  SpeachRecognation
//
//  Created by Cong Fandi on 16/06/21.
//

import UIKit
import Speech

class SpeechRecognitionWithNextAndBack: UIViewController,SFSpeechRecognizerDelegate {
    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    var index:Int = 0
    let colorData:[String] = ["Red","Orange","Yellow","Green","Blue","Purple","Black","Gray"]
    
    func next() -> Int{
        if(index<colorData.count-1){
            index=index+1
        }
        return index
    }
    
    func back() -> Int{
        if(index>0){
            index=index-1
        }
        return index
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
    }
    
    //MARK: - Colors
    enum Color: String {
        case Red, Orange, Yellow, Green, Blue, Purple, Black, Gray
        
        var create: UIColor {
            switch self {
            case .Red:
                return UIColor.red
            case .Orange:
                return UIColor.orange
            case .Yellow:
                return UIColor.yellow
            case .Green:
                return UIColor.green
            case .Blue:
                return UIColor.blue
            case .Purple:
                return UIColor.purple
            case .Black:
                return UIColor.black
            case .Gray:
                return UIColor.gray
            }
        }
    }
    
    //MARK: IBActions and Cancel
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isRecording == true {
            cancelRecording()
            isRecording = false
            startButton.backgroundColor = UIColor.gray
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
            startButton.backgroundColor = UIColor.red
        }
    }
    
    func cancelRecording() {
        recognitionTask?.finish()
        recognitionTask = nil
        
        // stop audio
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    //MARK: - Recognize Speech
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(title: "Speech Recognizer Error", message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                print("bestStrung \(bestString)")
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(bestString[indexTo...])
                }
                self.speechMatch(lastString: lastString)
            } else if let error = error {
                self.sendAlert(title: "Speech Recognizer Error", message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    func speechMatch(lastString:String){
        if(lastString.caseInsensitiveCompare("next") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[self.next()])
        }
        if(lastString.caseInsensitiveCompare("back") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[self.back()])
        }
        if(lastString.caseInsensitiveCompare("first") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[0])
        }
        if(lastString.caseInsensitiveCompare("first") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[0])
        }
        if(lastString.caseInsensitiveCompare("last") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData.last!)
        }
        if(lastString.caseInsensitiveCompare("second") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[1])
        }
        if(lastString.caseInsensitiveCompare("two") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[1])
        }
        if(lastString.caseInsensitiveCompare("three") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[2])
        }
        if(lastString.caseInsensitiveCompare("third") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[2])
        }
        if(lastString.caseInsensitiveCompare("four") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[3])
        }
        if(lastString.caseInsensitiveCompare("five") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[4])
        }
        if(lastString.caseInsensitiveCompare("six") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[5])
        }
        if(lastString.caseInsensitiveCompare("sevent") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[6])
        }
        if(lastString.caseInsensitiveCompare("eight") == .orderedSame){
            self.checkForColorsSaid(resultString: self.colorData[7])
        }
    }
    //MARK: - Check Authorization Status
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition not yet authorized"
                @unknown default:
                    return
                }
            }
        }
    }
    
    //MARK: - UI / Set view color.
    func checkForColorsSaid(resultString: String) {
        let finalColor = resultString.prefix(1).uppercased()+resultString.lowercased().dropFirst();
        print("warna \(finalColor)")
        guard let color = Color(rawValue: finalColor) else { return }
        colorView.backgroundColor = color.create
        self.detectedTextLabel.text = resultString
    }
    
    //MARK: - Alert
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
