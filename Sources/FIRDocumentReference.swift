import Foundation
import FirebaseFirestore
import ReactiveSwift

extension Reactive where Base: DocumentReference {
    func getDocument(on queueScheduler: Scheduler) -> SignalProducer<DocumentSnapshot, NSError> {
        return SignalProducer { observer, disposable in
            self.base.getDocument() { (snapshot, error) in
                if let error = error {
                    return observer.send(error: error as NSError)
                }

                defer { observer.sendCompleted() }

                guard let snapshot = snapshot else { return }

                observer.send(value: snapshot)
            }
        }
        .observe(on: queueScheduler)
    }

    func setData(_ data: [String : Any], on queueScheduler: Scheduler) -> SignalProducer<[String : Any], NSError> {
        return SignalProducer { observer, disposable in
            self.base.setData(data) { error in
                if let error = error {
                    return observer.send(error: error as NSError)
                }
            }

            defer { observer.sendCompleted() }

            observer.send(value: data)
        }
        .observe(on: queueScheduler)
    }

    func delete() -> SignalProducer<Void, NSError> {
        return SignalProducer { observer, disposable in
            self.base.delete() { error in
                if let error = error {
                    return observer.send(error: error as NSError)
                }

                defer { observer.sendCompleted() }

                observer.send(value: ())
            }
        }
    }

    func updateData(_ fields: [AnyHashable : Any], on queueScheduler: Scheduler)
    -> SignalProducer<Void, NSError> {
        return SignalProducer { observer, lifetime in
            self.base.updateData(fields) { (error) in
                if let error = error {
                    return observer.send(error: error as NSError)
                }

                defer { observer.sendCompleted() }

                return observer.send(value: ())
            }
        }
        .observe(on: queueScheduler)
    }

    func addSnapshotListener(on queueScheduler: Scheduler) -> SignalProducer<DocumentSnapshot, NSError> {
        return SignalProducer { observer, lifetime in
            let listener = self.base.addSnapshotListener { snapshot, error in
                if let error = error {
                    return observer.send(error: error as NSError)
                }

                guard let snapshot = snapshot else { return observer.sendCompleted() }

                observer.send(value: snapshot)
            }

            lifetime.observeEnded {
                observer.sendCompleted()
                listener.remove()
            }
        }
        .observe(on: queueScheduler)
    }
}
