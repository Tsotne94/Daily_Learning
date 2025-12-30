/*
 Challenge 1: Reverse an Array
 Create a function that uses a stack to print the contents of an array in reversed order.
 */

import UIKit

public struct Stack<Element> {
    private var storage: [Element] = []

    public init() { }

    public init(_ elements: [Element]) {
        storage = elements
    }

    public mutating func push(_ element: Element) {
        storage.append(element)
    }

    @discardableResult
    public mutating func pop() -> Element? {
        storage.popLast()
    }

    public func peek() -> Element? {
        storage.last
    }

    public var isEmpty: Bool {
        peek() == nil
    }
}

extension Stack: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        ----top----
        \(storage.map { "\($0)" }.reversed().joined(separator:"\n"))
        """
    }
}

extension Stack: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        storage = elements
    }
}

let stack = Stack(arrayLiteral: 1,2,3,4,5,6)

func printReversed<Element>(_ stack: Stack<Element>) {
    var innerStack = stack
    while let value = innerStack.pop() {
        print(value)
    }
}

printReversed(stack)

/*
 Challenge 2: Balance the parentheses
 Check for balanced parentheses. Given a string, check if there are ( and ) characters,
 and return true if the parentheses in the string are balanced. For example:
 // 1
 h((e))llo(world)() // balanced parentheses
 // 2
 (hello world // unbalanced parentheses
 */

func checkBalancedParentheses(string: String) -> Bool {
    var stack = Stack<Character>()
    
    for character in string {
        if character == "(" {
            stack.push(character)
        } else if character == ")" {
            if stack.isEmpty {
                return false
            } else {
                stack.pop()
            }
        }
    }
    return stack.isEmpty
}
