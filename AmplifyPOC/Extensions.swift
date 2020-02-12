//
//  Extensions.swift
//  AmplifyPOC
//
//  Created by Cathal Tru on 12/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode

        URLSession.shared.dataTask(with: url) { data, res, err in

            if let response = res as? HTTPURLResponse, let unwrappedData = data {

                let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                switch result {

                case .success:

                    guard
                        response.statusCode == 200,
                        let mimeType = response.mimeType, mimeType.hasPrefix("image"),
                        err == nil,
                        let image = UIImage(data: unwrappedData)
                        else { return }

                    DispatchQueue.main.async {
                        self.image = image
                    }

                case .failure(let err):
                    print("🛑 FAILED: \(result) error:\(err)")
                }
            }

            if let err = err {
                print("🛑  ERROR: \(err.localizedDescription)")
            }

            }.resume()
    }

    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
