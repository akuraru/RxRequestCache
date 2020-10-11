import RxSwift

public protocol Caching {
    associatedtype Request = CacheKey
    func load(request: Request) -> Observable<Data>
    func save(request: Request, data: Data)
}
