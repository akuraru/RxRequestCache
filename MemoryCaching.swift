import RxSwift
import UIKit

class MemoryCaching<R: CacheKey, E: Codable>: Caching {
    public typealias Request = R
    public typealias Element = E
    
    var memory = [Data: Expiring<E>]()
    let queue = DispatchQueue.global()
    
    init() {
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(self.didReceiveMemoryWarning),
                         name: UIApplication.didReceiveMemoryWarningNotification,
                         object: nil
            )
    }
    
    @objc func didReceiveMemoryWarning() {
        self.memory = [:]
    }
    
    func load(request: R) -> Observable<E> {
        let queue = self.queue
        return Observable.create { [weak self] observer in
            queue.async {[weak self] in
                let key = request.data()
                if let data = self?.memory[key], Date() < data.expiredAt {
                    observer.onNext(data.t)
                } else {
                    observer.onError(NSError(domain: "caching", code: 400, userInfo: nil))
                }
            }
            return Disposables.create()
        }
    }
    
    func save(request: R, expiring: Expiring<E>) {
        queue.async {[weak self] in
            let key = request.data()
            self?.memory[key] = expiring
        }
    }
}
