//
//  UrlCachedImages.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 27/12/2022.
//

import Foundation
import UIKit

class UrlCachedImages {
    
    var cache = URLCache(memoryCapacity: 1024*1024*10,
                         diskCapacity: 1024*1024*100,
                         directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("cachedImages"))
      
    func cachedImage(req: URLRequest) -> UIImage? {
        guard let data = self.cache.cachedResponse(for: req)?.data else { return nil }
        let img = UIImage(data: data)
        return img
    }
    
    func getCachedImage(url: URL, item: Item, completion: @escaping (Item, UIImage?)->Void) {
        let req = URLRequest(url: url)
        if let img = cachedImage(req: req) {
            DispatchQueue.main.async {
                completion(item, img)
            }
            return
        }
        else {
            URLSession.shared.dataTask(with: req) { data, response, error in
                if let error2 = error {
                    print(error2.localizedDescription)
                    DispatchQueue.main.async {
                        completion(item, nil)
                    }
                    return
                }
                else {
                    if let data2 = data, let response2 = response, let image = UIImage(data: data2) {
                        let cachedResponse = CachedURLResponse(response: response2, data: data2)
                        self.cache.storeCachedResponse(cachedResponse, for: req)
                        DispatchQueue.main.async {
                            completion(item, image)
                        }
                        
                        return
                    }
                }
            }.resume()
        }
    }
}
