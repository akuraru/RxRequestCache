import Foundation
import RxSwift

public protocol CacheKey {
    func data() -> Data
}

public protocol Client {
    associatedtype Request
    associatedtype Element
    
    func fetch(request: Request) -> Observable<Data>
    func parse(data: Data) -> Observable<Element>
}

public class Cache<Request: CacheKey, Element> {
    public static func create(
        request: Request,
        load: (Request) -> Observable<Data>,
        parse: @escaping (Data) -> Observable<Element>,
        fetch: @escaping (Request) -> Observable<Data>,
        save: @escaping (Request, Data) -> ()
    ) -> Observable<Element> {
        return load(request).flatMap(parse).catchError { _ in
            return fetch(request).flatMap { data in
                return parse(data).do(onNext: {_ in save(request, data) })
            }
        }
    }
    
    public static func create<Ca: Caching, Cl: Client> (
        request: Request,
        caching: Ca,
        client: Cl
    ) -> Observable<Element> where Ca.Request == Request, Cl.Request == Request, Cl.Element == Element {
        return self.create(
            request: request,
            load: caching.load(request:),
            parse: client.parse(data:),
            fetch: client.fetch(request:),
            save: caching.save(request:data:)
        )
    }
}
