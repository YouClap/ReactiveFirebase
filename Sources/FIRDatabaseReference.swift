import FirebaseDatabase
import ReactiveSwift

public extension Reactive where Base: DatabaseReference {

    func observe(_ event: DataEventType = .value, on queueScheduler: Scheduler)
    -> SignalProducer<DataSnapshot, NSError> {
        return SignalProducer { observer, lifetime in
            let observerID = self.base.observe(event, with: { snapshot in
                observer.send(value: snapshot)
            }, withCancel: { error in
                observer.send(error: error as NSError)
            })

            lifetime.observeEnded { [weak base = self.base] in
                base?.removeObserver(withHandle: observerID)
                observer.sendCompleted()
            }
            }
            .observe(on: queueScheduler)
    }

    var snapshot: SignalProducer<DataSnapshot, NSError> {
        return SignalProducer { observer, lifetime in
            self.base.observeSingleEvent(of: .value, with: { snapshot in
                observer.send(value: snapshot)
                observer.sendCompleted()
            }, withCancel: { error in
                observer.send(error: error as NSError)
            })

            lifetime.observeEnded {
                observer.sendCompleted()
            }
        }
    }

    var exists: SignalProducer<Bool, NSError> {
        return self.snapshot .map { $0.hasChildren() }
    }
    
    /// A signal that sets the value of this reference. Sends the `FIRDatabaseReference`.
    func set(value: Any?) -> SignalProducer<FIRDatabaseReference, NSError> {
        return SignalProducer { observer, disposable in
            self.base.setValue(value) { error, ref in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: ref)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    /// A signal that sets the priority of this reference. Sends the `FIRDatabaseReference`.
    func set(priority: Any?) -> SignalProducer<FIRDatabaseReference, NSError> {
        return SignalProducer { observer, disposable in
            self.base.setPriority(priority) { error, ref in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: ref)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    /// A signal that sets the value of this reference with a priority. Sends the `FIRDatabaseReference`.
    func set(value: Any?, priority: Any?) -> SignalProducer<FIRDatabaseReference, NSError> {
        return SignalProducer { observer, disposable in
            self.base.setValue(value, andPriority: priority) { error, ref in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: ref)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    /// A signal that updates fields at this reference. Sends the `FIRDatabaseReference`.
    func update(_ values: [AnyHashable: Any]) -> SignalProducer<FIRDatabaseReference, NSError> {
        return SignalProducer { observer, disposable in
            self.base.updateChildValues(values) { error, ref in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: ref)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    /// A signal that removes the value at this reference. Sends the `FIRDatabaseReference`.
    func remove() -> SignalProducer<FIRDatabaseReference, NSError> {
        return SignalProducer { observer, disposable in
            self.base.removeValue { error, ref in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: ref)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    /// A signal that sends a `Bool` value indicating whether or not a key exists.
    func has(_ key: String) -> SignalProducer<Bool, NSError> {
        return self.snapshot
            .map { snapshot in
                return snapshot.hasChild(key)
            }
    }
    
    /// A signal that runs a transaction on this reference. Sends an optional `FIRDataSnapshot`.
    func run(_ transaction: @escaping (_ data: FIRMutableData) -> Void) -> SignalProducer<FIRDataSnapshot?, NSError> {
        return SignalProducer { observer, disposabel in
            self.base.runTransactionBlock({ data -> FIRTransactionResult in
                transaction(data)
                return FIRTransactionResult.success(withValue: data)
            }, andCompletionBlock: { error, completed, snapshot in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: snapshot)
                    observer.sendCompleted()
                }
            })
        }
    }
    
    /// A signal that sets the value on disconnect. Sends this reference once the event has been queued up.
    func onDisconnectSet(value: Any?) -> SignalProducer<FIRDatabaseReference, NSError> {
        return SignalProducer { observer, disposable in
            self.base.onDisconnectSetValue(value) { error, ref in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: ref)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    /// A signal that sets the value and priority on disconnect. Sends this reference once the event has been queued up.
    func onDisconnectSet(value: Any?, priority: Any?) -> SignalProducer<FIRDatabaseReference, NSError> {
        return SignalProducer { observer, disposable in
            self.base.onDisconnectSetValue(value, andPriority: priority) { error, ref in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: ref)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    /// A signal that removes the value at this reference on disconnect. Sends this reference once the event has been queued up.
    func onDisconnectRemove() -> SignalProducer<FIRDatabaseReference, NSError> {
        return SignalProducer { observer, disposable in
            self.base.onDisconnectRemoveValue { error, ref in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: ref)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    /// A signal that updates the child values at this reference on disconnect. Sends this reference once the event has been queued up.
    func onDisconnectUpdate(_ values: [AnyHashable: Any]) -> SignalProducer<FIRDatabaseReference, NSError> {
        return SignalProducer { observer, disposable in
            self.base.onDisconnectUpdateChildValues(values) { error, ref in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: ref)
                    observer.sendCompleted()
                }
            }
        }
    }
    
    /// A signal that cancels all disconnect operations at this reference. Sends this reference once the event has been acknowledged.
    func cancelDisconnectOperations() -> SignalProducer<FIRDatabaseReference, NSError> {
        return SignalProducer { observer, disposable in
            self.base.cancelDisconnectOperations { error, ref in
                if let error = error as? NSError {
                    observer.send(error: error)
                } else {
                    observer.send(value: ref)
                    observer.sendCompleted()
                }
            }
        }
    }
}
