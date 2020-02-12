//
//  VideoVC.swift
//  AmplifyPOC
//
//  Created by Cathal Tru on 12/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//

// swiftlint:disable multiple_closures_with_trailing_closure

import UIKit
import AVKit
import MobileCoreServices

class VideoVC: UIViewController {

    @IBOutlet weak var outputLabel: UILabel!

    let videoURL = "media/original/25eb85fd8f9d4501a253fbb8b490b787/" + "6555c8ddd4a84c2d97d44e52a1f3546a/"
                    + "9c3a6a32396b4cca827a5f64ae9dfcd9/bdcb2569a82e424c8a25f620d711de1a.mov"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func downloadVideo(_ sender: Any) {

        let storage = AWSStorageService()
        storage.downloadVideofromS3bucket(with: videoURL, success: { (data) in

            DispatchQueue.main.async {
                self.outputLabel.text = "✅ Successful Download"
            }

            if let tmpFileURL = self.videoURLCreated(data) {

                let player = AVPlayer(url: tmpFileURL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                playerController.modalPresentationStyle = .fullScreen // iOS 13 default off
                DispatchQueue.main.async {
                    self.present(playerController, animated: true, completion: nil)
                }
            }

        }) { (_) in
            DispatchQueue.main.async {
                self.outputLabel.text = "🛑 Error downloading"
            }
        }

    }

    fileprivate func videoURLCreated(_ data: Data?) -> URL? {

        //NB Temporary stores file locally in NSTemporaryDirectory() - which gets wiped if memory low
        let filePath = NSTemporaryDirectory()
        let tmpFileURL = URL(fileURLWithPath: filePath).appendingPathComponent("video").appendingPathExtension("mov")
        let wasFileWritten = (try? data?.write(to: tmpFileURL, options: [.atomic])) != nil

        if !wasFileWritten {
            print("🛑 File was NOT Written")
            return nil
        } else {
            print("✅ File was written....\(tmpFileURL.absoluteString)")
            return tmpFileURL

        }
    }

    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Video was saved" : "Video failed to save"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func uploadVideo(_ sender: Any) {

         VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
    }

}
// MARK: - UIImagePickerControllerDelegate

extension VideoVC: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        dismiss(animated: true, completion: nil)

            guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
                mediaType == (kUTTypeMovie as String),
                let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
                UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
                else { return }

            // Handle a movie capture
            // Save to photo album
            UISaveVideoAtPathToSavedPhotosAlbum(url.path,
                                                self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)

            //Now upload it to S3 bucket
            do {
                let videoData = try Data(contentsOf: url)
                let storage = AWSStorageService()
                storage.uploadVideoToS3Bucket(data: videoData, success: { (response) in
                    print("✅ Successfully uploaded video: \(response)")
                }) { (_) in
                    print("🛑 Error Uploading of video failed")
                }
            } catch let err {
                print("🛑 Error getting video data: \(err.localizedDescription)")
            }
    }
}

// MARK: - UINavigationControllerDelegate

extension VideoVC: UINavigationControllerDelegate {
}
