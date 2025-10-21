import RxBlocking
import RxSwift
import XCTest
@testable import Chronicle_Staging

class TransactionViewModelTests: XCTestCase {
    var viewModel: TransactionViewModel!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        viewModel = TransactionViewModel()
        disposeBag = DisposeBag()
    }
    
    override func tearDown() {
        disposeBag = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testUpdateTransactions_groupsByDay_andSorts() {
        let calendar = Calendar.current
        let today = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dayBefore = calendar.date(byAdding: .day, value: -2, to: today)!
        
        let transactions: [UIModel.Transaction] = [
            .init(APIModel.Transaction.autoMock(id: "1", date: today.addingTimeInterval(60))),
            .init(APIModel.Transaction.autoMock(id: "2", date: today.addingTimeInterval(10))),
            .init(APIModel.Transaction.autoMock(id: "3", date: yesterday.addingTimeInterval(3600))),
            .init(APIModel.Transaction.autoMock(id: "4", date: dayBefore.addingTimeInterval(7200))),
            .init(APIModel.Transaction.autoMock(id: "5", date: nil))
        ]

        viewModel.updateTransactions(with: transactions)
        let groups = currentGroups()

        XCTAssertEqual(groups.count, 3, "Should have 3 groups")

        let groupDates = groups.compactMap { $0.date }
        XCTAssertTrue(groupDates.elementsEqual(groupDates.sorted(by: >)), "Groups should be in descending day order")

        let todayGroup = groups[0]
        XCTAssertEqual(todayGroup.transactions.map { $0.id }, ["1", "2", "5"])
        XCTAssertEqual(groups[1].transactions.map { $0.id }, ["3"])
        XCTAssertEqual(groups[2].transactions.map { $0.id }, ["4"])
    }
    
    func testAddTransaction_insertToGroup_andSorts() {
        let calendar = Calendar.current
        let today = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!

        viewModel.updateTransactions(with: [
            .init(APIModel.Transaction.autoMock(id: "1", date: today.addingTimeInterval(20))),
            .init(APIModel.Transaction.autoMock(id: "2", date: today.addingTimeInterval(40)))
        ])
        _ = currentGroups()

        viewModel.addTransaction(.init(APIModel.Transaction.autoMock(id: "3", date: today.addingTimeInterval(60))))
        let groups = currentGroups()

        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].transactions.map { $0.id }, ["3", "2", "1"])
    }

    func testAddTransaction_addedWithNewDate_andSorts() {
        let calendar = Calendar.current
        let today = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        viewModel.updateTransactions(with: [
            .init(APIModel.Transaction.autoMock(id: "1", date: yesterday))
        ])
        _ = currentGroups()

        viewModel.addTransaction(.init(APIModel.Transaction.autoMock(id: "2", date: today)))
        let groups = currentGroups()

        XCTAssertEqual(groups.count, 2)
        XCTAssertTrue(Calendar.current.isDate(groups[0].date!, inSameDayAs: today))
        XCTAssertTrue(Calendar.current.isDate(groups[1].date!, inSameDayAs: yesterday))
    }
    
    // MARK: - Helper
    
    private func currentGroups() -> [UIModel.TransactionGroup] {
        return (try? viewModel.transGroups
            .take(1)
            .toBlocking()
            .first()) ?? []
    }
}
