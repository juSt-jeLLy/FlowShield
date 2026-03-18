import Test
import "FlowToken"
import "FlowShieldTypes"
import "FlowShieldErrors"
import "GuardPolicy"
import "ProtectionVault"
import "FlowShieldAdmin"
import "ActionRouter"

access(all) let serviceAccount = Test.serviceAccount()

access(all) fun setup() {
    var err = Test.deployContract(
        name: "FlowShieldTypes",
        path: "../contracts/FlowShieldTypes.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "FlowShieldErrors",
        path: "../contracts/FlowShieldErrors.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "GuardPolicy",
        path: "../contracts/GuardPolicy.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "ProtectionVault",
        path: "../contracts/ProtectionVault.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "FlowShieldAdmin",
        path: "../contracts/FlowShieldAdmin.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "ActionRouter",
        path: "../contracts/ActionRouter.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all) fun testSlippageRefund() {
    setup()

    // Enable protection with no premium for predictable refund math.
    let setPolicyTx = Test.Transaction(
        code: Test.readFile("../transactions/set_policy.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: [true, UInt64(0), 10.0, 100.0, 86_400.0, UInt64(0)]
    )
    let setPolicyRes = Test.executeTransaction(setPolicyTx)
    Test.expect(setPolicyRes, Test.beSucceeded())

    // Fund the refund pool.
    let fundTx = Test.Transaction(
        code: Test.readFile("../transactions/fund_vault.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: [10.0, /storage/flowTokenVault]
    )
    let fundRes = Test.executeTransaction(fundTx)
    Test.expect(fundRes, Test.beSucceeded())

    // Simulate a swap with actualOut < expectedOut to trigger a refund.
    let settleTx = Test.Transaction(
        code: Test.readFile("../transactions/settle_mock_swap.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: [10.0, 5.0]
    )
    let settleRes = Test.executeTransaction(settleTx)
    Test.expect(settleRes, Test.beSucceeded())

    let tokenId = Type<@FlowToken.Vault>().identifier
    let stats = ProtectionVault.getStats(tokenId: tokenId)
    assert(stats.totalRefunds == 5.0, message: "expected totalRefunds to be 5.0")
    assert(stats.balance == 5.0, message: "expected vault balance to be 5.0 after refund")
}
