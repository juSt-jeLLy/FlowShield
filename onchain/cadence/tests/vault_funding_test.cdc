import Test
import "FlowToken"
import "FlowShieldTypes"
import "ProtectionVault"

access(all) let serviceAccount = Test.serviceAccount()

access(all) fun setup() {
    var err = Test.deployContract(
        name: "FlowShieldTypes",
        path: "../contracts/FlowShieldTypes.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())

    err = Test.deployContract(
        name: "ProtectionVault",
        path: "../contracts/ProtectionVault.cdc",
        arguments: []
    )
    Test.expect(err, Test.beNil())
}

access(all) fun testVaultFunding() {
    setup()

    let fundTx = Test.Transaction(
        code: Test.readFile("../transactions/fund_vault.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: [5.0, /storage/flowTokenVault]
    )
    let fundRes = Test.executeTransaction(fundTx)
    Test.expect(fundRes, Test.beSucceeded())

    let depositEvents = Test.eventsOfType(Type<ProtectionVault.VaultDeposit>())
    assert(depositEvents.length > 0, message: "expected a VaultDeposit event")
    let depositEvent = depositEvents[depositEvents.length - 1] as! ProtectionVault.VaultDeposit
    let tokenId = depositEvent.tokenId

    let statsAfterDeposit = ProtectionVault.getStats(tokenId: tokenId)
    assert(statsAfterDeposit.balance >= 5.0, message: "expected vault balance to be >= 5.0")
    let depositsAfter = statsAfterDeposit.totalDeposits

    let withdrawTx = Test.Transaction(
        code: Test.readFile("../transactions/withdraw_vault.cdc"),
        authorizers: [serviceAccount.address],
        signers: [serviceAccount],
        arguments: [tokenId, 2.0, /public/flowTokenReceiver]
    )
    let withdrawRes = Test.executeTransaction(withdrawTx)
    Test.expect(withdrawRes, Test.beSucceeded())

    let withdrawEvents = Test.eventsOfType(Type<ProtectionVault.TreasuryWithdrawn>())
    assert(withdrawEvents.length > 0, message: "expected a TreasuryWithdrawn event")
    let withdrawEvent = withdrawEvents[withdrawEvents.length - 1] as! ProtectionVault.TreasuryWithdrawn
    assert(withdrawEvent.amount == 2.0, message: "expected withdrawn amount to be 2.0")

    let statsAfterWithdraw = ProtectionVault.getStats(tokenId: tokenId)
    assert(
        statsAfterWithdraw.totalDeposits == depositsAfter,
        message: "totalDeposits should be unchanged"
    )
}
