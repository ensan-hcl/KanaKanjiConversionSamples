import XCTest
@testable import KanaKanjiConversionSimpleImplementation

final class KanaKanjiConversionSamplesTests: XCTestCase {
    func testConversion() throws {
        var converter = KanaKanjiConversionSimpleImplementation()
        XCTAssertEqual(converter.convertToKanji(kana: Array("かんじ")), "感じ")
        XCTAssertEqual(converter.convertToKanji(kana: Array("へんかんけっか")), "変換結果")
        XCTAssertEqual(converter.convertToKanji(kana: Array("これはあいふぉんです")), "これはiPhoneです")
        XCTAssertEqual(converter.convertToKanji(kana: Array("あずーきーはかなかんじへんかんえんじんです")), "azooKeyはかな漢字変換エンジンです")
    }
}
