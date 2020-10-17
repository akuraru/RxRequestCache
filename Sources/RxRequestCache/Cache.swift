import Foundation
import RxSwift

public protocol CacheKey {
    func data() -> Data
}

public class Expiring<T: Codable>: Codable {
    public let t: T
    public let expiredAt: Date
    
    public init(t: T, expiredAt: Date = Date(timeIntervalSinceReferenceDate: .greatestFiniteMagnitude)) {
        self.t = t
        self.expiredAt = expiredAt
    }
}

public class Cache {
    public static func create<Request: CacheKey, Element:Codable> (
        request: Request,
        load: (Request) -> Observable<Element>,
        fetch: @escaping (Request) -> Observable<Expiring<Element>>,
        save: @escaping (Request, Expiring<Element>) -> ()
    ) -> Observable<Element> {
        return load(request).catchError { _ in
            return fetch(request).map { data in
                save(request, data)
                return data.t
            }
        }
    }
    
    public static func create<Request: CacheKey, Element: Codable, Ca: Caching> (
        request: Request,
        caching: Ca,
        fetch: @escaping (Request) -> Observable<Expiring<Element>>
    ) -> Observable<Element> where Ca.Request == Request, Ca.Element == Element {
        create(
            request: request,
            load: caching.load(request:),
            fetch: fetch,
            save: caching.save(request:expiring:)
        )
    }
}
