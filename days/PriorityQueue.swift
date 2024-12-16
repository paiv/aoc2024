// PriorityQueue.swift
// author: paiv
// https://github.com/paiv/swift-priorityqueue

public struct PriorityQueue<Element> where Element:Comparable {

    public mutating func push(_ item: Element) {
        heap.add(item)
    }

    public mutating func pop() -> Element? {
        heap.removeTop()
    }

    public var count: Int {
        heap.count
    }

    public var isEmpty: Bool {
        heap.count == 0
    }

    private var heap = ArrayHeap()

    private struct ArrayHeap {
        private var items:[Element] = []

        var count: Int {
            return items.count
        }

        mutating func add(_ item: Element) {
            items.append(item)
            bubbleUp()
        }

        private mutating func bubbleUp() {
            var q = items.count - 1

            while q > 0 {
                let p = (q - 1) / 2

                guard items[p] >= items[q] else {
                    break
                }

                items.swapAt(p, q)
                q = p
            }
        }

        mutating func removeTop() -> Element? {
            guard items.count > 0 else {
                return nil
            }

            guard items.count > 1 else {
                return items.removeLast()
            }

            let top = items.first
            items[0] = items.removeLast()
            bubbleDown()
            return top
        }

        private mutating func bubbleDown(_ index: Int = 0) {
            var p = index

            while true {
                var q = p
                var i = p * 2 + 1

                if i < items.count && items[q] > items[i] {
                    q = i
                }

                i += 1
                if i < items.count && items[q] > items[i] {
                    q = i
                }

                guard q != p else {
                    return
                }

                items.swapAt(p, q)
                p = q
            }
        }
    }
}


extension PriorityQueue : Sequence, IteratorProtocol {

    public mutating func next() -> Element? {
        return pop()
    }
}
