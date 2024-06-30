module playermarket::royalty_policy {
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::tx_context::{sender};
    use sui::transfer_policy::{
        Self as policy,
        TransferPolicy,
        TransferPolicyCap,
        TransferRequest,
    };
    use sui::package::Publisher;

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
        (((paid as u128) * (amount_bp as u128) / 10_000) as u64)
    }

    public fun set<Player>(
        policy: &mut TransferPolicy<Player>,
        cap: &TransferPolicyCap<Player>,
        amount_bp: u16,
        beneficiary: address
    ){
        assert!(amount_bp < MAX_BPS, EIncorrectArgument);
        policy::add_rule(Rule {}, policy, cap, Config {
            amount_bp,
            beneficiary
        });
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

    #[allow(lint(self_transfer, share_owned))]
    public fun new_royalty_policy<Player>(
        publisher: &Publisher,
        amount_bp: u16,
        beneficiary: address,
        ctx: &mut TxContext
    ) {
        let (mut policy, cap) = policy::new<Player>(publisher, ctx);
        set<Player>(&mut policy, &cap, amount_bp, beneficiary);
        transfer::public_share_object(policy);
        transfer::public_transfer(cap, sender(ctx));
    }
}