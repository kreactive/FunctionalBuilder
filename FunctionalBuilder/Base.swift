//
//  Base.swift
//  FunctionalBuilder
//
//  Created by Antoine Palazzolo on 22/10/15.
//
//
public struct ComposeError : ErrorType {
    var underlyingErrors : [ErrorType]
    init(_ content : [ErrorType]) {
        self.underlyingErrors = content
    }
}

protocol ComposeResultType {
    var error : ErrorType? {get}
}
enum ComposeResult<T> : ComposeResultType {
    case Success(T)
    case Failure(ErrorType)
    
    init<Input>(input : Input, f : Input throws -> T) {
        do {
            self = ComposeResult.Success(try f(input))
        } catch {
            self = ComposeResult.Failure(error)
        }
    }
    var error : ErrorType? {
        if case ComposeResult.Failure(let error) = self {
            return error
        }
        return nil
    }
    var value : T {
        if case ComposeResult.Success(let val) = self {
            return val
        }
        fatalError()
    }
}



public protocol ComposeType {
    typealias Output
    typealias Input
    var pure : Input throws -> Output {get}
    func pureMap<T>(transform : Output throws -> T) -> Input throws -> T
}
extension ComposeType {
    public func pureMap<T>(transform : Output throws -> T) -> Input throws -> T {
        return { (i : Input) in try transform(self.pure(i))}
    }
}

// and operator

infix operator <&> { associativity left precedence 150 }

public func <&><Input,A,B>(a : Input throws -> A, b : Input throws -> B) -> Composed2<Input,A,B> {
    return Composed2(f1 : a,f2 : b)
}
public func <&><Input,Out1,T : ComposeType,Out2 where T.Output == Out2, T.Input == Input>(a : Input throws -> Out1, b : T) -> Composed2<Input,Out1,Out2> {
    return Composed2(f1 : a,f2 : b.pure)
}

