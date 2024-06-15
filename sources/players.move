module playermarket::players{
    use sui::package;
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::transfer_policy::{Self, TransferPolicy, TransferPolicyCap};
    use std::string::String;
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

    #[allow(lint(share_owned))]
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


    public fun send_mint_cap(_cap: &AdminCap, recipient: address, ctx: &mut TxContext) {
        transfer::transfer(MintCap{
            id: object::new(ctx)
        }, recipient)
    }

    public fun mint_player(_cap: &MintCap, name: String, url: String, ctx: &mut TxContext): Player {
        Player {
            id: object::new(ctx),
            name,
            url
        }
    }

    public fun place_and_list_to_kiosk(
        _cap: &MintCap,
        central_policy: &CentralPolicy,
        kiosk: &mut Kiosk,
        player: Player,
        price: u64
    ) {
        kiosk::place_and_list<Player>(kiosk, &central_policy.kiosk_owner_cap, player, price);
    }


}