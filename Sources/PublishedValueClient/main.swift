import Combine
import PublishedValue

// class implementation
@PublishedValue(of: Int.self, named: "value")
class Foo {
    init(value: Int) {
        self.value = value
    }
    func gimmeSomething() -> Int {
        value
    }

    func update(value: Int) {
        self.value = value
    }
}

let foo = Foo(value: 6)
var cancellables: Set<AnyCancellable> = []

foo.$value
    .sink { value in
        print("received value: \(value)")
    }
    .store(in: &cancellables)

foo.update(value: 4)
foo.update(value: 5)
foo.update(value: 99)

// Protocol implementation
@PublishedValue(of: String.self, named: "name")
protocol NameRepositoryProtocol {
    func update(name: String)
}

@PublishedValue(of: String.self, named: "name")
class NameRepository: NameRepositoryProtocol {
    init(name: String) {
        self.name = name
    }

    func update(name: String) {
        self.name = name
    }
}

let nameRepo: NameRepositoryProtocol = NameRepository(name: "Cletus")
nameRepo.namePublisher
    .sink { name in
        print("received name: \(name)")
    }
    .store(in: &cancellables)

nameRepo.update(name: "biggie smalls")
