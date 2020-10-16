import Foundation
import RxSwift
import CryptoKit

public class FileCaching<R: CacheKey>: Caching {
    public typealias Request = R
    
    let interval: TimeInterval
    let isExpired: (Data) -> Bool
    let queue = DispatchQueue.global()
    
    public init(interval: TimeInterval = .infinity, isExpired: @escaping (Data) -> Bool = {_ in false }) {
        self.interval = interval
        self.isExpired = isExpired
    }
    
    func key(request: Request) -> String {
        SHA256.hash(data: request.data()).compactMap { String(format: "%02x", $0) }.joined()
    }
    
    public func load(request: R) -> Observable<Data> {
        let key = self.key(request: request)
        let interval = self.interval
        let isExpired = self.isExpired
        
        return .create { (observer) in
            self.queue.async {
                let manager = FileManager()
                do {
                    var url = try manager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    url.appendPathComponent(key)
                    
                    let attributes = try manager.attributesOfItem(atPath: url.path)
                    if let creationDate = attributes[.creationDate] as? Date {
                        let i = Date().timeIntervalSince(creationDate)
                        if i < interval {
                            let data = try Data(contentsOf: url)
                            if !isExpired(data) {
                                observer.onNext(data)
                                return
                            }
                        }
                    }
                    try manager.removeItem(at: url)
                    observer.onError(NSError(domain: "caching", code: 400, userInfo: nil))
                } catch let error {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    public func save(request: R, data: Data) {
        let key = self.key(request: request)
        queue.async {
            let manager = FileManager()
            do {
                var url = try manager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                url.appendPathComponent(key)
                try data.write(to: url)
            } catch _ {
            }
        }
    }
}
