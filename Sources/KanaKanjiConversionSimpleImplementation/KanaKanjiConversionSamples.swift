import class Foundation.Bundle

public struct Word: Hashable {
    public init(word: String, yomi: String, score: Int, posTag: Int) {
        self.word = word
        self.yomi = yomi
        self.score = score
        self.posTag = posTag
    }

    var word: String
    var yomi: String
    var score: Int
    var posTag: Int
}

class Node: Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.position == rhs.position && lhs.word == rhs.word
    }
    
    init(position: Int, word: Word, bestChild: Node) {
        self.position = position
        self.word = word
        self.bestChild = bestChild
    }
    
    private init(position: Int, word: Word, bestChild: Node?) {
        self.position = position
        self.word = word
        self.bestChild = bestChild
    }

    var position: Int
    var word: Word
    // スコアを最大にするNode
    var bestChild: Node?
    // そのスコア
    var bestScore: Int = 0
    
    static let BOS = Node(position: 0, word: Word(word: "", yomi: "", score: 0, posTag: 0), bestChild: nil)
}

// 全探索で最適解を探索する
public struct KanaKanjiConversionSimpleImplementation {
    
    public init() {}
    
    private let dictionaryDirectory = Bundle.module.resourceURL!.appendingPathComponent("Dictionary", isDirectory: true).absoluteURL
    
    private var dictionaryWords: [Character: [Word]] = [:]
    private var postagScores: [Int: [Int: Int]] = [:]
        
    mutating func loadDictionary(character: Character) {
        let fileURL = dictionaryDirectory.appendingPathComponent("words/\(character).tsv", isDirectory: false)
        if let content = try? String(contentsOf: fileURL, encoding: .utf8) {
            // contentをパースする
            let lines = content.split(separator: "\n")
            var words: [Word] = []
            for line in lines {
                let items = line.split(separator: "\t", omittingEmptySubsequences: false)
                if items.count < 6 {
                    continue
                }
                let yomi = String(items[0])
                let word = items[1].isEmpty ? yomi : String(items[1])
                let posid = Int(items[2])!
                // 辞書側の値をIntに調整（結果に影響はない）
                let score = items[5].isEmpty ? -3000 : Int(Double(items[5])! * 100)
                words.append(Word(word: word, yomi: yomi, score: score, posTag: posid))
            }
            self.dictionaryWords[character] = words
        }
    }

    mutating func loadPostagData(tag: Int) {
        let fileURL = dictionaryDirectory.appendingPathComponent("postags/\(tag).csv", isDirectory: false)
        if let content = try? String(contentsOf: fileURL, encoding: .utf8) {
            // contentをパースする
            let lines = content.split(separator: "\n")
            // 最初の行はデフォルト値
            let items = lines[0].split(separator: ",")
            let defaultScore = Int(Double(items[1])! * 100)
            // データ
            var postagData: [Int: Int] = Dictionary(uniqueKeysWithValues: (0...1318).map{($0, defaultScore)})

            for line in lines[1...] {
                let items = line.split(separator: ",")
                if items.count != 2 {
                    continue
                }
                let tag = Int(items[0])!
                let score = Int(Double(items[1])! * 100)
                postagData[tag] = score
            }
            self.postagScores[tag] = postagData
        }
    }
    
    /// 入力のカナ列に対して単語の候補を返す
    mutating func getWordInDictionary(yomi: String) -> [Word] {
        let yomiKatakana = yomi.applyingTransform(.hiraganaToKatakana, reverse: false)!
        guard let firstCharacter = yomiKatakana.first else {
            return []
        }
        if !dictionaryWords.keys.contains(firstCharacter) {
            self.loadDictionary(character: firstCharacter)
        }
        return dictionaryWords[firstCharacter]!.filter {
            $0.yomi == yomiKatakana
        }
    }

    mutating func getScoreBetweenPosTag(tagLeft: Int, tagRight: Int) -> Int {
        if !postagScores.keys.contains(tagLeft) {
            self.loadPostagData(tag: tagLeft)
        }
        return self.postagScores[tagLeft]![tagRight]!
    }

    func getScoreOfWord(word: Word) -> Int {
        return word.score
    }

    // Viterbiアルゴリズムを用いて、かな漢字変換を行う
    public mutating func convertToKanji(kana: [Character]) -> String {
        let kanaCharacters = Array(kana)
        let n = kanaCharacters.count
        var nodes: [[Node]] = Array(repeating: [], count: n + 1)
        nodes[0].append(Node.BOS)

        for i in 0 ..< n {
            for j in 1 ... n-i {
                let yomi = String(kanaCharacters[i ..< i + j])
                let candidates = getWordInDictionary(yomi: yomi)
                for candidate in candidates {
                    let cost = getScoreOfWord(word: candidate)
                    let posTag = candidate.posTag

                    var maxScore = Int.min
                    var bestPrevNode: Node?
                    
                    for prevNode in nodes[i] {
                        let prevScore = prevNode.bestScore + getScoreBetweenPosTag(tagLeft: prevNode.word.posTag, tagRight: posTag)
                        
                        if prevScore > maxScore {
                            maxScore = prevScore
                            bestPrevNode = prevNode
                        }
                    }
                    guard let bestPrevNode else {
                        continue
                    }
                    let newNode = Node(position: i + j, word: candidate, bestChild: bestPrevNode)
                    newNode.bestScore = cost + maxScore
                    nodes[i + j].append(newNode)
                }
            }
        }

        // 最終位置から遡って最適な経路を復元する
        var result = ""
        if var currentNode = nodes[n].min(by: {$0.bestScore > $1.bestScore}) {
            while currentNode != Node.BOS {
                result = currentNode.word.word + result
                currentNode = currentNode.bestChild!
            }
            return result
        } else {
            return "Conversion Failed"
        }
    }
}
