import RxSwift

public protocol Caching {
    associatedtype Request: CacheKey
    associatedtype Element: Codable
    func load(request: Request) -> Observable<Element>
    func save(request: Request, expiring: Expiring<Element>)
}
