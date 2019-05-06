import FirebaseAuth
import ReactiveSwift

public extension Reactive where Base: FirebaseAuth.Auth {

    var currentUser: SignalProducer<FirebaseAuth.User?, Never> {
        return SignalProducer { observer, lifetime in
            let handler = self.base.addStateDidChangeListener() { auth, user in
                observer.send(value: user)
            }

            lifetime += self.lifetime.ended.observeCompleted(observer.sendCompleted)

            lifetime += AnyDisposable { [weak base = self.base] in
                base?.removeStateDidChangeListener(handler)
            }
        }
    }

    func createUser(withEmail email: String, password: String) -> SignalProducer<FirebaseAuth.User, NSError> {
        return SignalProducer { observer, _ in
            self.base.createUser(withEmail: email, password: password) { authResult, error in
                if let error = error as NSError? {
                    return observer.send(error: error)
                }

                guard let auth = authResult else {
                    return observer.send(error: FirebaseAuth.Auth.Error.createUserNilUser)
                }

                defer {
                    observer.sendCompleted()
                }

                observer.send(value: auth.user)
            }
        }
    }

    func fetchProviders(forEmail email: String) -> SignalProducer<[String], NSError> {
        return SignalProducer { observer, _ in
            self.base.fetchProviders(forEmail: email) { providers, error in
                if let error = error as NSError {
                    return observer.send(error: error)
                }

                guard let providers = providers, providers.isEmpty == false else {
                    return observer.send(error: FirebaseAuth.Auth.Error.emailNotFound)
                }

                defer {
                    observer.sendCompleted()
                }

                observer.send(value: providers)
            }
        }
    }

    func sendPasswordReset(withEmail email: String) -> SignalProducer<Void, NSError> {
        return SignalProducer { observer, _ in
            self.base.sendPasswordReset(withEmail: email) { error in
                if let error = error as NSError? {
                    return observer.send(error: error)
                }

                observer.send(value: ())
                observer.sendCompleted()
            }
        }
    }

    func signIn(with credential: AuthCredential) -> SignalProducer<FirebaseAuth.User, NSError> {
        return SignalProducer { observer, _ in

            self.base.signInAndRetrieveData(with: credential) { dataResult, error in
                if let error = error as? NSError {
                    return observer.send(error: error)
                }

                guard let user = dataResult?.user else { return observer.send(error: .invalidUser) }

                defer {
                    observer.sendCompleted()
                }

                observer.send(value: user)
            }
        }
    }

    func signIn(withEmail email: String, password: String) -> SignalProducer<FirebaseAuth.User, NSError> {
            return SignalProducer { observer, _ in
                self.base.signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        return observer.send(error: .custom(error))
                    }

                    guard let auth = authResult else { return observer.send(error: .invalidUser) }

                    defer {
                        observer.sendCompleted()
                    }

                    observer.send(value: auth.user)
                }
            }
    }

    func signOut() -> SignalProducer<Void, NSError> {
        return SignalProducer { observer, disposable in
            do {
                try self.base.signOut()

                observer.send(value: ())
                observer.sendCompleted()
            } catch {
                observer.send(error: error)
            }
        }
    }

    func signInAnonymously() -> SignalProducer<FirebaseAuth.User?, NSError> {
        return SignalProducer { observer, _ in
            self.base.signInAnonymously { authData, error in
                if let error = error as NSError? {
                    observer.send(error: error)
                } else {
                    observer.send(value: authData?.user)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    func signIn(withCustomToken token: String) -> SignalProducer<FirebaseAuth.User?, NSError> {
        return SignalProducer { observer, _ in
            self.base.signIn(withCustomToken: token) { authData, error in
                if let error = error as NSError? {
                    observer.send(error: error)
                } else {
                    observer.send(value: authData?.user)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    func confirmPasswordReset(withCode code: String, newPassword: String) -> SignalProducer<Void, NSError> {
        return SignalProducer { observer, _ in
            self.base.confirmPasswordReset(withCode: code, newPassword: newPassword) { error in
                if let error = error as NSError? {
                    observer.send(error: error)
                } else {
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
        }
    }

    func verify(passwordResetCode code: String) -> SignalProducer<String?, NSError> {
        return SignalProducer { observer, disposable in
            self.base.verifyPasswordResetCode(code) { email, error in
                if let error = error as NSError? {
                    observer.send(error: error)
                } else {
                    observer.send(value: email)
                    observer.sendCompleted()
                }
            }
        }
    }

    func sendPasswordReset(withEmail email: String) -> SignalProducer<Void, NSError> {
        return SignalProducer { observer, disposable in
            self.base.sendPasswordReset(withEmail: email) { error in
                if let error = error as NSError? {
                    observer.send(error: error)
                } else {
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
        }
    }

    func check(actionCode: String) -> SignalProducer<FirebaseAuth.ActionCodeInfo?, NSError> {
        return SignalProducer { observer, disposable in
            self.base.checkActionCode(actionCode) { info, error in
                if let error = error as NSError? {
                    observer.send(error: error)
                } else {
                    observer.send(value: info)
                    observer.sendCompleted()
                }
            }
        }
    }

    func apply(actionCode: String) -> SignalProducer<Void, NSError> {
        return SignalProducer { observer, disposable in
            self.base.applyActionCode(actionCode) { error in
                if let error = error as NSError? {
                    observer.send(error: error)
                } else {
                    observer.send(value: ())
                    observer.sendCompleted()
                }
            }
        }
    }
}

extension FirebaseAuth.Auth {
    enum Error: Swift.Error {
        case custom(Swift.Error)
        case invalidUser
        case emailNotFound(String)
        case create(Swift.Error)
        case createUserNilUser
        case signOut(Swift.Error)
        case passwordReset(Swift.Error)
    }
}
