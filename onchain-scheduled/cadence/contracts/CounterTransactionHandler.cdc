import "FlowTransactionScheduler"
import "Counter"

access(all) contract CounterTransactionHandler {

    /// Handler resource that implements the Scheduled Transaction interface
    access(all) resource Handler: FlowTransactionScheduler.TransactionHandler {
        access(FlowTransactionScheduler.Execute) fun executeTransaction(id: UInt64, data _data: AnyStruct?) {
            Counter.increment()
            let newCount = Counter.getCount()
            log("Transaction executed (id: \(id.toString())) newCount: \(newCount.toString())")
        }

        access(all) view fun getViews(): [Type] {
            return [Type<StoragePath>(), Type<PublicPath>()]
        }

        access(all) fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<StoragePath>():
                    return /storage/CounterTransactionHandler
                case Type<PublicPath>():
                    return /public/CounterTransactionHandler
                default:
                    return nil
            }
        }
    }

    /// Factory for the handler resource
    access(all) fun createHandler(): @Handler {
        return <- create Handler()
    }
}
