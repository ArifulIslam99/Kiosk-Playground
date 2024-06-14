module playermarket::players{
    use sui::package;
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::transfer_policy::{Self, TransferPolicy, TransferPolicyCap};
    use std::string::String;
    use std::vector;
    use playermarket::admin::AdminCap;
    
    public struct PLAYERS has drop {}

    public struct Player has key, store {
        id: UID,
        name: String,
        url: String
    }

    public struct CentralPolicy has key {
        id: UID,
        kiosk_owner_cap: KioskOwnerCap,
        transfer_policy: TransferPolicy<Player>,
        transfer_policy_cap: TransferPolicyCap<Player>
    }

    public struct MintCap has key {
        id: UID
    }


    fun init(witness: PLAYERS, ctx: &mut TxContext) {
        let publisher = package::claim(witness, ctx);
        let (kiosk, kiosk_owner_cap) = kiosk::new(ctx);
        let (transfer_policy, transfer_policy_cap) = transfer_policy::new<Player>(&publisher, ctx);
        let central_policy = CentralPolicy {
            id: object::new(ctx),
            kiosk_owner_cap,
            transfer_policy,
            transfer_policy_cap
        };
        transfer::share_object(central_policy);
        transfer::public_share_object(kiosk);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
    }


}