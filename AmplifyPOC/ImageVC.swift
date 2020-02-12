//
//  ImageVC.swift
//  AmplifyPOC
//
//  Created by Cathal Tru on 04/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//

// swiftlint:disable multiple_closures_with_trailing_closure

import UIKit

class ImageVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    let imageUrl = "media/300x200/" + "516cfb3ae02541208ee8bce20af6563a/9bc016944a434945bb507228bd4673ed/"
                    + "872148f74ae447c2804ecf028c34dbd5/1294cd33ae2c49758119e275e2ae1da5.jpg"

    let originalImageUrl = "media/original/" + "25eb85fd8f9d4501a253fbb8b490b787/6555c8ddd4a84c2d97d44e52a1f3546a/"
                    +   "9c3a6a32396b4cca827a5f64ae9dfcd9/5c8eaa0226c44cba97749cbbb05b681e.jpg"

    let thumbnailImageUrl = "media/300x200/" + "25eb85fd8f9d4501a253fbb8b490b787/6555c8ddd4a84c2d97d44e52a1f3546a/"
                    + "9c3a6a32396b4cca827a5f64ae9dfcd9/5c8eaa0226c44cba97749cbbb05b681e.jpg"

    let testImage = "assets/300x200/" + "0868e828d2804c67bdfcdadaf90f4ac3/" + "55465a492e4745da9d1abb252c1e3209.png"

    @objc let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //imageView.downloaded(from: imageURL)
        self.imagePicker.delegate = self
    }

    @IBAction func downloadImage(_ sender: Any) {

        let storage = AWSStorageService()
        storage.downloadImagefromS3bucket(with: testImage, success: { (image) in
            print("Success")

            DispatchQueue.main.async {
                self.outputLabel.text = "✅ Successful download"
                self.imageView.image = image
            }

            //showImage
        }) { (errString) in
            DispatchQueue.main.async {
                self.outputLabel.text = " 🛑 ERROR: \(errString)"
            }
        }

    }

    @IBAction func uploadImage(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary

        imagePicker.modalPresentationStyle = .fullScreen // iOS 13 default off
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true, completion: nil)
        }

    }

}

extension ImageVC: UIImagePickerControllerDelegate {

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if "public.image" == info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)]
            as? String {

            if let image: UIImage =
                info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)]
                    as? UIImage {
                //<- If you want to resize first?
                //image = image.resizeImage(targetSize: CGSize(width: 200.0, height: 200.0))
                if let imageData = image.pngData() {
                    //self.uploadImage(with: imageData)
                    let storage = AWSStorageService()
                    storage.uploadImageToS3bucket(with: imageData, success: { (response) in
                        DispatchQueue.main.async {
                            self.outputLabel.text = "\(response)"
                            self.imageView.image = image
                        }
                    }) { (errorString) in
                        DispatchQueue.main.async {
                            self.outputLabel.text = " 🛑 ERROR: \(errorString)"
                        }
                    }
                } else {
                    print("🛑 Error converting image into PNG")
                }
            }
        }

        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any])
    -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

extension UIImage {
    // MARK: - Resize Image Test
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let size1 = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        let size2 = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let newSize = widthRatio > heightRatio ?  size1 : size2
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
