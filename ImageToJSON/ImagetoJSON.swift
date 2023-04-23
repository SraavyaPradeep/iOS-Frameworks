//
//  ImagetoJSON.swift
//
//  Created by Sraavya Pradeep on 4/10/23.
//

import Foundation
import UIKit

// needs http to work
let ADDRESS: String = "http://localhost:8080/imageJSON"

class ImagetoJSON:UIViewController {
    
    var image = UIImage()
    var name = "sampleImage.jpeg"
    
    var uploadImageButton: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad();
        
        uploadImageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        uploadImageButton.layer.position.x = self.view.center.x
        uploadImageButton.layer.position.y = self.view.center.y
        uploadImageButton.setTitle("Upload Image", for: .normal)
        uploadImageButton.setTitleColor(UIColor.systemBlue, for: .normal)
        uploadImageButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        self.view.addSubview(uploadImageButton)
    }
    
    @objc func buttonAction(_ button : UIButton) {
        loadImage(name: "sampleImage", ext: "jpeg");
        uploadImage(fileName: name, image: self.image);
    }

    func loadImage(name: String, ext: String) {
        let path = Bundle.main.url(forResource: name, withExtension: ext)
        if let imageData = try? Data(contentsOf: path!) {
            if let loadedImage = UIImage(data: imageData) {
                 self.image = loadedImage
            }
        } else {
            print("Could not load contents of image")
        }
    }
    
    func uploadImage(fileName: String, image: UIImage){
        
//        var newImg = resizeImage(image: image, targetSize: CGSizeMake(225.0, 225.0))
        let url = URL(string: ADDRESS)
        let boundary = UUID().uuidString
        _ = URLSession.shared

        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        let paramName = "file"
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpegData(compressionQuality: 1)!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        print(data);
        
        urlRequest.httpBody = data

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                print("ERROR")
                return
            }
        }
        task.resume();
        print("Successfully Uploaded")
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
       let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
       UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
       image.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       return newImage!
   }
}
