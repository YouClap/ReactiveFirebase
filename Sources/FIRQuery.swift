import Foundation
import FirebaseFirestore
import ReactiveSwift

extension Reactive where Base: Query {
    func getDocuments(on queueScheduler: Scheduler) -> SignalProducer<QuerySnapshot, NSError> {
        return SignalProducer { observer, lifetime in
            self.base.getDocuments() { snapshot, error in
                if let error = error {
                    return observer.send(error: error as NSError)
                }

                defer { observer.sendCompleted() }

                guard let snapshot = snapshot else { return }

                return observer.send(value: snapshot)
            }

            lifetime.observeEnded { observer.sendCompleted() }
        }
        .observe(on: queueScheduler)
    }

    func addSnapshotListener(on queueScheduler: Scheduler) -> SignalProducer<QuerySnapshot, NSError> {
        return SignalProducer { observer, lifetime in
            let listener = self.base.addSnapshotListener { snapshot, error in
                if let error = error {
                    return observer.send(error: error as NSError)
                }

                guard let snapshot = snapshot else { return }

                return observer.send(value: snapshot)
            }

            lifetime.observeEnded {
                observer.sendCompleted()
                listener.remove()
            }
        }
        .observe(on: queueScheduler)
    }
}
