module playermarket::royalty_policy {
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::tx_context::{TxContext, sender};
    use sui::transfer_policy::{
        Self as policy,
        TransferPolicy,
        TransferPolicyCap,
        TransferRequest,
        remove_rule
    };
    use sui::package::Publisher;
    use sui::transfer;

    /// The `amount_bp` passed is more than 100%.
    const EIncorrectArgument: u64 = 0;
    /// The `Coin` used for payment is not enough to cover the fee.
    const EInsufficientAmount: u64 = 1;

    /// Max value for the `amount_bp`.
    const MAX_BPS: u16 = 10000;

    /// The "Rule" witness to authorize the policy.
    public struct Rule has drop {}

    /// Configuration for the Rule.
    public struct Config has store, drop {
        amount_bp: u16,
        beneficiary: address
    }

    public fun calculate_fee(amount_bp: u16, paid: u64): u64 {
        (paid * (amount_bp as u64) / 10000) as u64
    }

    public fun pay<Player>(
        policy: &mut TransferPolicy<Player>, 
        request: &mut TransferRequest<Player>,
        payment: &mut Coin<SUI>,
        ctx: &mut TxContext

    ) {
        let config: &Config = policy::get_rule(Rule {}, policy); 
        let paid = policy::paid(request);
        let amount = calculate_fee(config.amount_bp, paid);

        assert!(coin::value(payment) >= amount, EInsufficientAmount);
        if (amount > 0) {
            let fee = coin::split(payment, amount, ctx);
            transfer::public_transfer(fee, config.beneficiary);
        };
        policy::add_receipt(Rule {}, request)

    }
}