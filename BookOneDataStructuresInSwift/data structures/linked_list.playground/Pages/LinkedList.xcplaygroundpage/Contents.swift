public class Node<Value> {
    public var value: Value
    public var next: Node?

    public init(value: Value, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        guard let next = next else {
            return "\(value)"
        }
        return "\(value) -> " + String(describing: next)
    }
}

// MARK: - Node declared


public struct LinkedList<Value> {
    public var head: Node<Value>?
    public var tail: Node<Value>?

    public init() {}

    public var isEmpty: Bool {
        head == nil
    }
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        guard let head = head else {
            return "empty list"
        }
        return String(describing: head)
    }
}

extension LinkedList: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Value

    public init(arrayLiteral elements: Value...) {
        self.init()
        for element in elements {
            self.append(element)
        }
    }
}

extension LinkedList {
    public mutating func push(_ value: Value) {
        copyNodes()
        head = Node(value: value, next: head)
        if tail == nil {
            tail = head
        }
    }

    public mutating func append(_ value: Value) {
        copyNodes()
        guard !isEmpty else {
            push(value)
            return
        }

        tail!.next = Node(value: value)
        tail = tail?.next
    }
}

func example1() {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    print(list)
}

func example2() {
    var list = LinkedList<Int>()
    list.append(1)
    list.append(2)
    list.append(3)
    print(list)
}

//example1()
example2()

extension  LinkedList {
    @discardableResult
    mutating func insert(_ value: Value, after node: Node<Value>) -> Node<Value> {
        copyNodes()
        guard tail !== node else {
            append(value)
            return tail!
        }

        node.next = Node(value: value, next: node.next)
        return node.next!
    }

    public func node(at index: Int) -> Node<Value>? {
        var currentNode = head
        var currentIndex = 0

        while currentNode != nil && currentIndex < index {
            currentNode = currentNode!.next
            currentIndex += 1
        }

        return currentNode
    }
}

func example3() {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    print("Before inserting: \(list)")
    var middleNode = list.node(at: 1)!
    for _ in 1...4 {
        middleNode = list.insert(-1, after: middleNode)
    }
    print("After inserting: \(list)")
}

example3()

// MARK: - Removing Operations

extension LinkedList {
    @discardableResult
    mutating func pop() -> Value? {
        copyNodes()
        defer {
            head = head?.next
            if isEmpty {
                tail = nil
            }
        }
        return head?.value
    }

    @discardableResult
    mutating func removeLast() -> Value? {
        copyNodes()
        guard let head = head else {
            return nil
        }

        guard head.next != nil else {
            return pop()
        }

        var prev = head
        var current = head

        while let next = current.next {
            prev = current
            current = next
        }

        prev.next = nil
        tail = prev
        return current.value
    }

    @discardableResult
    mutating func remove(after node: Node<Value>) -> Value? {
        guard let node = copyNodes(returningCopyOf: node) else { return nil }
        defer {
            if node.next === tail {
                tail = node
            }
            node.next = node.next?.next
        }
        return node.next?.value
    }
}

func example4() {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    print("Before removing last node: \(list)")
    let removedValue = list.removeLast()
    print("After removing last node: \(list)")
    print("Removed value: " + String(describing: removedValue))
}

example4()

func example5() {
    var list = LinkedList<Int>()
    list.push(3)
    list.push(2)
    list.push(1)
    print("Before removing at particular index: \(list)")
    let index = 1
    let node = list.node(at: index - 1)!
    let removedValue = list.remove(after: node)
    print("After removing at index \(index): \(list)")
    print("Removed value: " + String(describing: removedValue))
}

example5()

extension LinkedList: Collection {
    public var startIndex: Index {
        Index(node: head)
    }

    public var endIndex: Index {
        Index(node: tail?.next)
    }

    public struct Index: Comparable {
        public var node: Node<Value>?

        static public func ==(lhs: Index, rhs: Index) -> Bool {
            switch (lhs.node, rhs.node) {
            case let (left?, right?):
                return left.next === right.next
            case (nil, nil):
                return true
            default:
                return false
            }
        }

        static public func <(lhs: Index, rhs: Index) -> Bool {
            guard lhs != rhs else {
                return false
            }

            let nodes = sequence(first: lhs.node, next: { $0?.next })
            return nodes.contains { $0 === rhs.node }
        }
    }

    public func index(after i: Index) -> Index {
        return Index(node: i.node?.next)
    }

    public subscript(position: Index) -> Value {
        position.node!.value
    }
}

func example6() {
    var list = LinkedList<Int>()
    for i in 0...9 {
        list.append(i)
    }
    print("List: \(list)")
    print("First element: \(list[list.startIndex])")
    print("Array containing first 3 elements: \(Array(list.prefix(3)))")
    print("Array containing last 3 elements: \(Array(list.suffix(3)))")
    let sum = list.reduce(0, +)
    print("Sum of all values: \(sum)")
}

example6()

func exampleCOW() {
    let array1 = [1, 2]
    var array2 = array1

    print("\n\n\narray1: \(array1)")
    print("array2: \(array2)")

    print("---after adding 3 to array 2---")
    array2.append(3)
    print("array1: \(array1)")
    print("array2: \(array2)")
}

exampleCOW()

func exampleCOWForLinkedList() {
    var list1 = LinkedList<Int>()

    list1.append(1)
    list1.append(2)
    var list2 = list1

    print("List1: \(list1)")
    print("List2: \(list2)")
    print("After appending 3 to list2")
    list2.append(3)
    print("List1: \(list1)")
    print("List2: \(list2)")
}

exampleCOWForLinkedList()

extension LinkedList {
    private mutating func copyNodes() {
        guard !isKnownUniquelyReferenced(&head) else {
            return
        }

        guard var oldNode = head else {
            return
        }

        head = Node(value: oldNode.value)
        var newNode = head

        while let nextOldNode = oldNode.next {
            newNode!.next = Node(value: nextOldNode.value)
            newNode = newNode!.next

            oldNode = nextOldNode
        }

        tail = newNode
    }

    private mutating func copyNodes(returningCopyOf node: Node<Value>?) -> Node<Value>? {
        guard !isKnownUniquelyReferenced(&head) else {
            return nil
        }
        guard var oldNode = head else {
            return nil
        }

        head = Node(value: oldNode.value)
        var newNode = head
        var nodeCopy: Node<Value>?

        while let nextOldNode = oldNode.next {
            if oldNode === node {
                nodeCopy = newNode
            }
            newNode!.next = Node(value: nextOldNode.value)
            newNode = newNode!.next
            oldNode = nextOldNode
        }

        return nodeCopy
    }
}


// MARK: - Exercises

/*
 Challenge 1: Print in reverse
 Create a function that prints the nodes of a linked list in reverse order. For example:

 1 -> 2 -> 3 -> nil
 // should print out the following:
 3
 2
 1
 */

func exercise1() {
    print("\n\n\n\n")
    var originalList: LinkedList = [1, 2, 3, 4, 5, 7]
    var newList: LinkedList<Int> = []

    var oldValue: Node<Int>?
    oldValue = originalList.head

    while let element = oldValue {
        newList.push(element.value)
        oldValue = oldValue!.next
    }

    while let element = newList.pop() {
        print(element)
    }
}

exercise1()


/*
 Challenge 2: Find the middle node
 Create a function that finds the middle node of a linked list. For example:

 1 -> 2 -> 3 -> 4 -> nil
 // middle is 3
 1 -> 2 -> 3 -> nil
 // middle is 2
*/

func exercise2() {
    print("\n\n\n\n\n")
    var originalList: LinkedList = [1, 2, 3, 4, 5, 7]

    var fast = originalList.head
    var slow = originalList.head

    while fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
    }

    print(slow!.value)
}


exercise2()

/*
 Challenge 3: Reverse a linked list
 Create a function that reverses a linked list. You do this by manipulating the nodes
 so that they’re linked in the other direction. For example:

 // before
 1 -> 2 -> 3 -> nil
 // after
 3 -> 2 -> 1 -> nil
 */

func exercise3() {
    print("\n\n\n\n\n")

    var originalList: LinkedList = [1, 2, 3, 4, 5, 7]

    var currentNode = originalList.head
    var prev: Node<Int>?
    var next: Node<Int>?

    while currentNode != nil {
        next = currentNode?.next
        currentNode?.next = prev
        prev = currentNode
        currentNode = next
    }

    originalList.head = prev

    print(originalList)
}

// დამტანჯა ამან, უნდა დავუბრუნდე, ვერ ვიგებ ნორმალურად.

exercise3()
/*
 Challenge 4: Merge two lists
 Create a function that takes two sorted linked lists and merges them into a single
 sorted linked list. Your goal is to return a new linked list that contains the nodes
 from two lists in sorted order. You may assume the sort order is ascending. For
 example:

 // list1
 1 -> 4 -> 10 -> 11
 // list2
 -1 -> 2 -> 3 -> 6
 // merged list
 -1 -> 1 -> 2 -> 3 -> 4 -> 6 -> 10 -> 11
 */

func exercise4() {
    var firstList: LinkedList = [1, 2, 3, 4, 5]
    var secondlist: LinkedList = [5, 6, 7, 8, 9, 10]

    var firstListNode = firstList.head
    var secondlistNode = secondlist.head

    while firstListNode != nil || secondlistNode != nil {
        let first = firstListNode?.value
        let second = secondlistNode?.value

    }
}
/*
 Challenge 5: Remove all occurrences
 Create a function that removes all occurrences of a specific element from a linked
 list. The implementation is similar to the remove(at:) method you implemented for
 the linked list. For example:

 // original list
 1 -> 3 -> 3 -> 3 -> 4
 // list after removing all occurrences of 3
 1 -> 4
 */
