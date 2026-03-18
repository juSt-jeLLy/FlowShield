import Test
import "FlowShieldTypes"
import "GuardPolicy"

access(all) let serviceAccount = Test.serviceAccount()

access(all) fun setup() {
    var err = Test.deployContract(
        name: "FlowShieldTypes",
        path: "../contracts/FlowShieldTypes.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "GuardPolicy",
        path: "../contracts/GuardPolicy.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all) fun testPolicyLifecycle() {
    setup()

    let setupTx = Test.Transaction(
        code: Test.readFile("../transactions/setup_user.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: []
    )
    let setupRes = Test.executeTransaction(setupTx)
    Test.expect(setupRes, Test.beSucceeded())

    let assertPolicyTx = Test.Transaction(
        code: Test.readFile("../transactions/assert_policy_exists.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: []
    )
    let assertPolicyRes = Test.executeTransaction(assertPolicyTx)
    Test.expect(assertPolicyRes, Test.beSucceeded())

    let updateTx = Test.Transaction(
        code: Test.readFile("../transactions/set_policy.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: [true, UInt64(0), 10.0, 100.0, 86_400.0, UInt64(0)]
    )
    let updateRes = Test.executeTransaction(updateTx)
    Test.expect(updateRes, Test.beSucceeded())

}
