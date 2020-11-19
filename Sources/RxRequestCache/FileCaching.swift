import Foundation
import RxSwift
import CryptoKit

public class FileCaching<R: CacheKey, E: Codable>: Caching {
    public typealias Request = R
    public typealias Element = E
    
    let interval: TimeInterval
    let queue = DispatchQueue.global()
    
    public init(interval: TimeInterval = .infinity) {
        self.interval = interval
    }
    
    func key(request: Request) -> String {
        SHA256.hash(data: request.data()).compactMap { String(format: "%02x", $0) }.joined()
    }
    
    public func load(request: R) -> Observable<Element> {
        let key = self.key(request: request)
        let interval = self.interval
        
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
                            let expiring = try JSONDecoder().decode(Expiring<E>.self, from: data)
                            if Date() < expiring.expiredAt {
                                observer.onNext(expiring.t)
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
    
    public func save(request: R, expiring: Expiring<E>) {
        let key = self.key(request: request)
        queue.async {
            let manager = FileManager()
            do {
                var url = try manager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                url.appendPathComponent(key)
                let data = try JSONEncoder().encode(expiring)
                try data.write(to: url)
            } catch _ {
            }
        }
    }
    
    public func remove(request: R) {
        let key = self.key(request: request)
        let manager = FileManager()
        do {
            var url = try manager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            url.appendPathComponent(key)
            try manager.removeItem(at: url)
        } catch _ {
        }
    }
}
