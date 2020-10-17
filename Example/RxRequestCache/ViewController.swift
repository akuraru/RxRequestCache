import UIKit
import RxSwift
import RxCocoa
import RxRequestCache

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    var repos: Observable<[Repository]>!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repos = fetchRepository().share(replay: 1)
        repos.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, element, cell in
                cell.textLabel?.text = element.name
                cell.detailTextLabel?.text = element.full_name
        }.disposed(by: disposeBag)
        
        repos.map({ String($0.count) })
            .bind(to: rx.title)
            .disposed(by: disposeBag)
    }
    
    func fetchRepository() -> Observable<[Repository]> {
        Cache.create(
            request: GithubRequest(path: "/users/akuraru/repos"),
            caching: FileCaching(),
            fetch: GithubClient().fetch(request:)
        )
    }
}

struct GithubRequest: CacheKey {
    let path: String
    
    func data() -> Data {
        path.data(using: .utf8)!
    }
}

class GithubClient {
    public typealias Request = GithubRequest
    public typealias Element = [Repository]
    
    func fetch(request: Request) -> Observable<Expiring<Element>> {
        let request = URLRequest(url: URL(string: "https://api.github.com" + request.path)!)
        return URLSession.shared.rx.data(request: request).map { data in
            Expiring(t: try! JSONDecoder().decode([Repository].self, from: data))
        }
    }
}

struct Repository: Codable {
    let id: Int
    let node_id: String
    let name: String
    let full_name: String
}
