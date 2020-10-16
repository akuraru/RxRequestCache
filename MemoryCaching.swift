import RxSwift
import UIKit

class MemoryCaching: Caching {
    var memory = [Data: Data]()
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
    
    func load(request: CacheKey) -> Observable<Data> {
        let queue = self.queue
        return Observable.create { [weak self] observer in
            queue.async {[weak self] in
                let key = request.data()
                if let data = self?.memory[key] {
                    observer.onNext(data)
                } else {
                    observer.onError(NSError(domain: "caching", code: 400, userInfo: nil))
                }
            }
            return Disposables.create()
        }
    }
    
    func save(request: CacheKey, data: Data) {
        queue.async {[weak self] in
            let key = request.data()
            self?.memory[key] = data
        }
    }
}
