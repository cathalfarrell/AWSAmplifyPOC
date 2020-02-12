//
//  AWSStorageService.swift
//  S3TransferUtilitySampleSwift
//
//  Created by Cathal Tru on 12/07/2019.
//  Copyright © 2019 Amazon. All rights reserved.
//

import Foundation
import UIKit
import AWSS3

protocol StorageService {

    func downloadImagefromS3bucket(with imageUrl: String,
                                   success succ: @escaping (UIImage?) -> Void,
                                   failure fail: @escaping (String) -> Void)
}

class AWSStorageService: StorageService {

    @objc lazy var transferUtility = {
        AWSS3TransferUtility.default()
    }()

    @objc var completionDownloadHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
    @objc var completionUploadHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    @objc var progressBlock: AWSS3TransferUtilityProgressBlock?

    init() {}

    func downloadImagefromS3bucket(with imageUrl: String,
                                   success succ: @escaping (UIImage?) -> Void,
                                   failure fail: @escaping (String) -> Void) {

        //Returning response on the main thread
        let success: (UIImage?) -> Void = { image in
            DispatchQueue.main.async { succ(image) }
        }
        let failure: (String) -> Void = { error in
            DispatchQueue.main.async { fail(String(describing: error)) }
        }

        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            let progressDisplay = String(format: "%2.0f", progress.fractionCompleted*100) as String
            print("✅ Progress: \((progressDisplay))%")
        }

        self.completionDownloadHandler = { (task, location, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    failure("🛑 Failed with error: \(error.localizedDescription)")
                } else {
                    if data != nil {
                        print("✅ Successfully downloaded image")
                        if let image = UIImage(data: data!) {
                            success(image)
                        } else {
                            failure("Problem parsing data into an image")
                        }
                    } else {
                        failure("No data returned from download")
                    }
                }
            })
        }

        transferUtility.downloadData(
            fromBucket: s3DownloadBucket,
            key: imageUrl,
            expression: expression,
            completionHandler: completionDownloadHandler).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    print("🛑 Error: %@", error.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        failure("Problem parsing data into an image")
                    })
                }

                if task.result != nil {
                    DispatchQueue.main.async(execute: {
                        print("😀 Downloading...")
                    })
                    print("😀 Download Starting!")
                    // Do something with download.
                }
                return nil
        }

    }

    func downloadVideofromS3bucket(with videoUrl: String,
                                   success succ: @escaping (Data?) -> Void,
                                   failure fail: @escaping (String) -> Void) {

        //Returning response on the main thread
        let success: (Data?) -> Void = { videoData in
            DispatchQueue.main.async { succ(videoData) }
        }
        let failure: (String) -> Void = { error in
            DispatchQueue.main.async { fail(String(describing: error)) }
        }

        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = {(task, progress) in
            let progressDisplay = String(format: "%2.0f", progress.fractionCompleted*100) as String
            print("✅ Progress: \((progressDisplay))%")
        }

        self.completionDownloadHandler = { (task, location, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    failure("🛑 Failed with error: \(error.localizedDescription)")
                } else {
                    if data != nil {
                        print("✅ Successfully downloaded video: \(data!.count) Bytes")
                        success(data)
                    } else {
                        failure("No data returned from download")
                    }
                }
            })
        }

        transferUtility.downloadData(
            fromBucket: s3DownloadBucket,
            key: videoUrl,
            expression: expression,
            completionHandler: completionDownloadHandler).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    print("🛑 Error: %@", error.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        failure("Problem parsing data")
                    })
                }

                if task.result != nil {
                    DispatchQueue.main.async(execute: {
                        print("😀 Downloading...")
                    })
                    print("😀 Download Starting")
                    // Do something with download.
                }
                return nil
        }

    }

    func uploadImageToS3bucket(with data: Data,
                               success succ: @escaping (String) -> Void,
                               failure fail: @escaping (String) -> Void) {

        //Returning response on the main thread
        let success: (String) -> Void = { response in
            DispatchQueue.main.async { succ(response) }
        }
        let failure: (String) -> Void = { error in
            DispatchQueue.main.async { fail(String(describing: error)) }
        }

        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in
            let progressDisplay = String(format: "%2.0f", progress.fractionCompleted*100) as String
            print("✅ Progress: \((progressDisplay))%")
        }

        self.completionUploadHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    failure("🛑 Failed with error: \(error)")
                } else {
                    success("✅ Successful upload: Bytes Uploaded: \(data.count) - TASK: \(task)")
                }
            })
        }

        //Create a unique key for S3 upload
        let organisationID = "62cbbbee8c564f42a42fe350a9003532"
        let workRequestID = "a162904a99d846299188351d049d422a"
        let dataPointID = "17b060bca208408d8155a6855ea0006c"
        let fileType = "image"
        let fileExtension = "png"

        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let fileComponentsArray = [organisationID, workRequestID, dataPointID, fileType, uuid]
        let s3UploadKeyName: String = fileComponentsArray.joined(separator: "_") + ".\(fileExtension)"

        transferUtility.uploadData(
            data,
            bucket: s3UploadBucket,
            key: s3UploadKeyName,
            contentType: "image/png",
            expression: expression,
            completionHandler: completionUploadHandler).continueWith { (task) -> AnyObject? in

                //NB: Ensure you update UI on main thread

                if let error = task.error {
                    failure("🛑 Error: \(error.localizedDescription)")
                }

                if task.result != nil {

                    print("😀 Upload Starting: BUCKET: \(s3UploadBucket) KEY:\(s3UploadKeyName)")

                    // Do something with uploadTask.
                }

                return nil
        }
    }

    // MARK: Upload video

    func uploadVideoToS3Bucket(data: Data,
                               success succ: @escaping (String) -> Void,
                               failure fail: @escaping (String) -> Void) {

        //Returning response on the main thread
        let success: (String) -> Void = { response in
            DispatchQueue.main.async { succ(response) }
        }
        let failure: (String) -> Void = { error in
            DispatchQueue.main.async { fail(String(describing: error)) }
        }

        let expression = AWSS3TransferUtilityMultiPartUploadExpression()
        expression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Update a progress bar.
                let progressDisplay = String(format: "%2.0f", progress.fractionCompleted*100) as String
                print("✅ Progress: \((progressDisplay))%")
            })
        }

        var completionHandler: AWSS3TransferUtilityMultiPartUploadCompletionHandlerBlock
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Alert a user for transfer completion.
                // On failed uploads, `error` contains the error object.
                DispatchQueue.main.async(execute: {
                    if let error = error {
                        failure("🛑 Failed with error: \(error)")
                    } else {
                        success("✅ Successful upload: Bytes Uploaded: \(data.count) - TASK: \(task)")
                    }
                })
            })
        }

        let organisationID = "62cbbbee8c564f42a42fe350a9003532"
        let workRequestID = "a162904a99d846299188351d049d422a"
        let dataPointID = "17b060bca208408d8155a6855ea0006c"
        let fileType = "video"
        let fileExtension = "mov"

        let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let fileComponentsArray = [organisationID, workRequestID, dataPointID, fileType, uuid]
        let s3UploadKeyName: String = fileComponentsArray.joined(separator: "_") + ".\(fileExtension)"

        transferUtility.uploadUsingMultiPart(data: data,
                                             bucket: s3UploadBucket,
                                             key: s3UploadKeyName,
                                             contentType: "video/mp4",
                                             expression: expression,
                                             completionHandler: completionHandler).continueWith {(task) ->
                                                AnyObject? in

                                                //NB: Ensure you update UI on main thread

                                                if let error = task.error {
                                                    failure("🛑 Error: \(error.localizedDescription)")
                                                }

                                                if task.result != nil {

                                                    print("😀 Upload Starting: BUCKET: \(s3UploadBucket)")
                                                    print("😀 KEY:\(s3UploadKeyName)")

                                                    // Do something with uploadTask.
                                                }

                                                return nil
        }
    }

}
