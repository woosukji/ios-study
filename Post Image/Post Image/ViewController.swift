//
//  ViewController.swift
//  Post Image
//
//  Created by 지우석 on 2022/07/01.
//

import UIKit
import Foundation
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func handleChangeButton(_ sender: UIButton) {
        print("Image Selected")
                
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
    }
    
    @IBAction func handleSendButton(_ sender: UIButton) {
        if let imgData = imageView.image?.jpegData(compressionQuality: 1.0) {
//            let imgSize = imageView.image?.size
//            let imgScale = imageView.image?.scale
            postImageData(filename: "test02.jpg", imgData: imgData)
        }
    }
    
    func postImageData(filename: String, imgData: Data) {
        
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        let tick = mach_absolute_time()
        
        let url = "[Server URI]"
    
        let parameters = [
            "filename": filename,
            "sequenceNo": "0506"
        ]
        
        _ = AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
            }

            multipartFormData.append(imgData, withName: "img", fileName: filename, mimeType: "image/jpg")

        }, to: url).responseDecodable(of: ImagePostData.self) { response in
            let diff = Double(mach_absolute_time() - tick) * Double(info.numer) / Double(info.denom)
            print("\(diff / 1_000_000) milliseconds")
            
            debugPrint(response)
            
            switch response.result {
                case .success(let upload):
                    print("img successfully uploaded")
//                    print(upload)
                case .failure(let err):
                    print("upload failure")
//                    print(err)
            }
        }
    }
    
    func requestIdentify(userName: String,
                             imgData: Data) {

//            var urlComponent = URLComponents(string: BaseAPI.shared.getBaseString())
//            urlComponent?.path = RequestURL.identify.getRequestURL
//            guard let url = urlComponent?.url else {
//                return
//            }
        let url = "[Server URI]"
    
//        let header: HTTPHeaders = [
//            "Content-Type": "multipart/form-data"
//        ]
        let parameters = [
            "filename":userName,
            "sequenceNo": "0506"
        ]
        


        _ = AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
            }

            multipartFormData.append(imgData, withName: "img", fileName: "\(userName).jpg", mimeType: "image/jpg")

        }, to: url).responseDecodable(of: ImagePostData.self) { response in
            switch response.result {
            case .success(let upload):
                print(upload)
//                        guard let httpStatusCode
//                            = HttpStatusCode(rawValue: decodedData.statusCode) else {
//                            print("status error")
////                                completion(.failed(NSError(domain: "status error",
////                                                           code: 0,
////                                                           userInfo: nil)))
//                                return
//                        }
//                        completion(.success(httpStatusCode))
//                        print(decodedData.statusCode)

//                    } else {
//                        completion(.failed(NSError(domain: "decode error",
//                                                   code: 0,
//                                                   userInfo: nil)))
//                        print("decode error")
//                        return
//                    }
//                }
            case .failure(let err):
//                completion(.failed(err))
                print(err)
            }
            
        }
    }
    
    /*
    func requestIdentify() {
        guard let sendData = imgObservable.value else {
            return
        }
        let boundary = generateBoundaryString()
        let body: [String: String] = ["userName": userName]
        let bodyData = createBody(parameters: body,
                                  boundary: boundary,
                                  data: sendData,
                                  mimeType: "image/jpg",
                                  filename: "identifyImage.jpg")

        requestIdentifys(boundary: boundary, bodyData: bodyData) { response in
            switch response {
            case .success(let statusCode):
                print(statusCode)
            case .failed(let err):
                print(err)
            }
        }
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    private func createBody(parameters: [String: String],
                            boundary: String,
                            data: Data,
                            mimeType: String,
                            filename: String) -> Data {
        var body = Data()
        let imgDataKey = "img"
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(imgDataKey)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--".appending(boundary.appending("--")).data(using: .utf8)!)
        
        return body as Data
    }
    
    
    
    func requestIdentifys(boundary: String,
                         bodyData: Data,
                         completion: @escaping (DataResponse<HttpStatusCode>) -> Void) {
        var urlComponent = URLComponents(string: BaseAPI.shared.getBaseString())
        urlComponent?.path = RequestURL.identify.getRequestURL
        let header: [String: String] = [
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
        guard let url = urlComponent?.url,
            let request = requestMaker.makeRequest(url: url,
                                                   method: .post,
                                                   header: header,
                                                   body: bodyData) else {
                                                    return
                                                    
        }
        
        network.dispatch(request: request) { result in
            switch result {
            case .success(let data):
                
                if let decodedData = try? JSONDecoder().decode(ResponseSimple<String>.self,
                                                               from: data) {
                    print(decodedData)
                    guard let httpStatusCode = HttpStatusCode(rawValue: decodedData.statusCode) else {
                        return completion(.failed(NSError(domain: "status error",
                                                          code: 0,
                                                          userInfo: nil)))
                    }
                    completion(.success(httpStatusCode))
                } else {
                    completion(.failed(NSError(domain: "decode error",
                                               code: 0,
                                               userInfo: nil)))
                    return
                }
                
            case .failure(let error):
                completion(.failed(error))
                return
            }
        }
    } */
}


extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
        
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

