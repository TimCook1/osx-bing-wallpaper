//: Playground - noun: a place where people can play

import Cocoa

class NetworkService
{
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.configuration)
    
    let url: NSURL
    
    init(url: NSURL)
    {
        self.url = url
    }
    
    func downloadImage(completion: @escaping ((NSData) -> Void))
    {
        let request = NSURLRequest(url: self.url as URL)
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if error == nil {
                if let httpResponse = response as? HTTPURLResponse {
                    switch (httpResponse.statusCode) {
                    case 200:
                        if let data = data {
                            completion(data as NSData)
                        }
                    default:
                        print(httpResponse.statusCode)
                    }
                }
            } else {
                print("Error download data: \(error?.localizedDescription)")
            }
        }
        dataTask.resume()
    }
    
}

let IMAGE_URL = NSURL(string: "https://www.bing.com/az/hprichbg/rb/RossFountain_EN-AU11490955168_1920x1080.jpg")

let networkService = NetworkService(url: IMAGE_URL!)
networkService.downloadImage(completion: { (data) in
    let image = NSImage(data: data as Data)
    let file = "image.jpg"
    
    let cgImage = image?.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage!)
    let jpegData = bitmapRep.representation(using: NSBitmapImageFileType.JPEG, properties: [:])!
    
    do {
        try jpegData.write(to: URL(string: "file:///Volumes/MacOS/Users/johnstray/Pictures/image.jpg")!)
    } catch {
        NSLog("error!")
    }
})