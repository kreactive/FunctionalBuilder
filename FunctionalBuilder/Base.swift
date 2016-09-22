//
//  Base.swift
//  FunctionalBuilder
//
//  Created by Antoine Palazzolo on 22/10/15.
//
//
public struct ComposeError : Error {
    public var underlyingErrors : [Error]
    public init(_ content : [Error]) {
        self.underlyingErrors = content
    }
}

protocol ComposeResultType {
    var error : Error? {get}
}
enum ComposeResult<T> : ComposeResultType {
    case success(T)
    case failure(Error)
    
    init<Input>(input : Input, f : (Input) throws -> T) {
        do {
            self = ComposeResult.success(try f(input))
        } catch {
            self = ComposeResult.failure(error)
        }
    }
    var error : Error? {
        if case ComposeResult.failure(let error) = self {
            return error
        }
        return nil
    }
    var value : T {
        if case ComposeResult.success(let val) = self {
            return val
        }
        fatalError()
    }
}



public protocol ComposeType {
    associatedtype Output
    associatedtype Input
    var pure : (Input) throws -> Output {get}
    func pureMap<T>(_ transform : @escaping (Output) throws -> T) -> (Input) throws -> T
}
extension ComposeType {
    public func pureMap<T>(_ transform : @escaping (Output) throws -> T) -> (Input) throws -> T {
        return { (i : Input) in try transform(self.pure(i))}
    }
}

// and operator

infix operator <&> : Composition
precedencegroup Composition {
    associativity: left
}

public func <&><Input,A,B>(a : @escaping (Input) throws -> A, b : @escaping (Input) throws -> B) -> Composed2<Input,A,B> {
    return Composed2(f1 : a,f2 : b)
}
public func <&><Input,Out1,T : ComposeType,Out2>(a : @escaping (Input) throws -> Out1, b : T) -> Composed2<Input,Out1,Out2>
    where T.Output == Out2, T.Input == Input {
    return Composed2(f1 : a,f2 : b.pure)
}

