import Flutter
import UIKit
import SwiftyTesseract

public class SwiftTesseractPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tesseract", binaryMessenger: registrar.messenger())
    let instance = SwiftTesseractPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        initializeTessData()
        if call.method == "extractText" {

            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                return
            }

            let params: [String : Any] = args as! [String : Any]
            let language: String? = params["language"] as? String
            let path:String? = params["tessData"] as? String
             
            let lang = RecognitionLanguage.custom(language! as String)
           let swiftyTesseract = SwiftyTesseract(language: lang,dataSource:  Test(pathToTrainedData: path!) as LanguageModelDataSource)
            
             let  imagePath = params["imagePath"] as! String
            guard let image = UIImage(contentsOfFile: imagePath)else { return }

            swiftyTesseract.performOCR(on: image) { recognizedString in

                guard let extractText = recognizedString else { return }
                result(extractText)
            }
        }
    }

    func initializeTessData() {

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL = documentsURL!.appendingPathComponent("tessdata")

        let sourceURL = Bundle.main.bundleURL.appendingPathComponent("tessdata")

        let fileManager = FileManager.default
        do {
            try fileManager.createSymbolicLink(at: sourceURL, withDestinationURL: destURL)
        } catch {
            print(error)
        }
    }
}
class Test :LanguageModelDataSource{
    var pathToTrainedData: String
    
    init(pathToTrainedData: String) {
        self.pathToTrainedData=pathToTrainedData
    }
    
    
}
