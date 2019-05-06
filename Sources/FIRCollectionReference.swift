import FirebaseFirestore
import ReactiveSwift

extension Reactive where Base: CollectionReference {
    func getDocuments(on queueScheduler: Scheduler) -> SignalProducer<QuerySnapshot, NSError> {
        return SignalProducer { observer, disposable in
            self.base.getDocuments() { (snapshot, error) in
                if let error = error { return observer.send(error: error as NSError) }

                defer { observer.sendCompleted() }

                guard let snapshot = snapshot else { return }

                observer.send(value: snapshot)
            }
        }
        .observe(on: queueScheduler)
    }

    func addDocument(data: [String : Any], on queueScheduler: Scheduler) -> SignalProducer<DocumentReference, NSError> {
        return SignalProducer { observer, disposable in
            let documentReference = self.base.document()

            documentReference.setData(data) { error in
                if let error = error { return observer.send(error: error as NSError) }

                observer.send(value: documentReference)
                observer.sendCompleted()
            }
        }
        .observe(on: queueScheduler)
    }

    func document() -> SignalProducer<DocumentReference, NSError> {
        return SignalProducer(value: self.base.document())
    }
}
