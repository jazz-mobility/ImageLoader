/// Least Recently Used cache eviction policy using a doubly linked list and dictionary for constant time access and look up
final class LRUEvictionStrategy<Key: Hashable>: CacheEvictionStrategy {
    private var map: [Key: Node<Key>] = [:]
    private var head: Node<Key>? // most recently used
    private var tail: Node<Key>? // least recently used
    
    func trackAccess(for key: Key) {
        if let node = map[key] {
            remove(node)
            addToFront(node)
        } else {
            let node = Node(key: key)
            addToFront(node)
            map[key] = node
        }
    }
    
    func keyToEvict() -> Key? {
        tail?.key
    }
    
    func removeKey(_ key: Key) {
        guard let node = map[key] else { return }
            
        remove(node)
        map.removeValue(forKey: key)
    }
    
    func removeAll() {
        map.removeAll()
        head = nil
        tail = nil
    }
}

// MARK: - Private helpers
private extension LRUEvictionStrategy {
    func addToFront(_ node: Node<Key>) {
        node.next = head
        node.previous = nil
        
        if let currentHead = head {
            currentHead.previous = node
        }
        
        head = node
        
        if tail == nil {
            tail = head
        }
    }
    
    func remove(_ node: Node<Key>) {
        let previous = node.previous
        let next = node.next
        
        if let previousNode = previous {
            previousNode.next = next
        } else {
            head = next
        }
        
        if let nextNode = next {
            nextNode.previous = previous
        } else {
            tail = previous
        }
        
        node.previous = nil
        node.next = nil
    }
}

// MARK: - Node

/// A node for doubly linked list
private class Node<Key: Hashable> {
    let key: Key
    var previous: Node?
    var next: Node?
    
    init(key: Key, previous: Node? = nil, next: Node? = nil) {
        self.key = key
        self.previous = previous
        self.next = next
    }
}
