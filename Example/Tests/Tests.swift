import XCTest
import RxRequestCache

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        let infinity = Date(timeIntervalSinceReferenceDate: .greatestFiniteMagnitude)
        let now = Date()
        XCTAssert(now < infinity, "Pass")
    }
    
    func testJson() {
        struct Tes: Codable {
            let date: Date
        }
        
        let t = Tes(date: Date(timeIntervalSinceReferenceDate: .greatestFiniteMagnitude))
        let data = try! JSONEncoder().encode(t)
        let string = String(data: data, encoding: .utf8)!
        XCTAssertEqual(string, "{\"date\":1.7976931348623157e+308}")
    }
}
