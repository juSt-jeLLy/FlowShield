import Test
import "FlowToken"
import "FlowShieldTypes"
import "FlowShieldErrors"
import "GuardPolicy"
import "ProtectionVault"
import "FlowShieldAdmin"
import "ActionRouter"
import "MockSwap"

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
        name: "DeFiActionsUtils",
        path: "../../imports/6d888f175c158410/DeFiActionsUtils.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "DeFiActions",
        path: "../../imports/6d888f175c158410/DeFiActions.cdc",
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

    err = Test.deployContract(
        name: "MockSwap",
        path: "../contracts/MockSwap.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all) fun testSlipShieldProtectedSwap() {
    setup()

    let setPolicyTx = Test.Transaction(
        code: Test.readFile("../transactions/set_policy.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: [true, UInt64(500), 5.0, 50.0, 86_400.0, UInt64(100)]
    )
    let setPolicyRes = Test.executeTransaction(setPolicyTx)
    Test.expect(setPolicyRes, Test.beSucceeded())

    let fundTx = Test.Transaction(
        code: Test.readFile("../transactions/fund_vault.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: [10.0, /storage/flowTokenVault]
    )
    let fundRes = Test.executeTransaction(fundTx)
    Test.expect(fundRes, Test.beSucceeded())

    let depositEvents = Test.eventsOfType(Type<ProtectionVault.VaultDeposit>())
    let depositEvent = depositEvents[depositEvents.length - 1] as! ProtectionVault.VaultDeposit
    let tokenId = depositEvent.tokenId

    let protectedTx = Test.Transaction(
        code: Test.readFile("../transactions/mock_protected_swap.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: [10.0, 8.0, 0.0]
    )
    let protectedRes = Test.executeTransaction(protectedTx)
    Test.expect(protectedRes, Test.beSucceeded())

    let stats = ProtectionVault.getStats(tokenId: tokenId)
    assert(stats.totalPremiums == 0.08, message: "expected premium to be 0.08")
    assert(stats.totalRefunds == 1.58, message: "expected refund to be 1.58")
    assert(stats.balance == 8.5, message: "expected vault balance to be 8.5")
}
