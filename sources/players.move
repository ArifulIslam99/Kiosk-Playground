module playermarket::players{
    use sui::package;
    use sui::display; 
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::transfer_policy::{Self, TransferPolicy, TransferPolicyCap};
    use std::string::{String, utf8};
    use playermarket::admin::AdminCap;
    use sui::coin;
    use sui::sui::SUI;
    public struct PLAYERS has drop {}
    use playermarket::royalty_policy::new_royalty_policy;
    const BENEFICIARY: address = @0x8f6ff638438081e30f3c823e83778118947e617f9d8ab08eca8613d724d77335;
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

    public struct CollectionInfo has store, key {
        id: UID,
        publisher: package::Publisher,
        display: display::Display<Player>
        }

    public struct MintCap has key {
        id: UID
    }

    #[allow(lint(share_owned))]
    fun init(witness: PLAYERS, ctx: &mut TxContext) {
        let publisher = package::claim(witness, ctx);
        let mut display = display::new<Player>(&publisher, ctx);
        display::add<Player>(&mut display, utf8(b"name"), utf8(b"Euro2024"));
        display::add<Player>(&mut display, utf8(b"image_url"), utf8(b"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRJXfhrKW_PFiWcsgu5J1oKzYYHLD1Nf9AX9g&s"));
        display::add<Player>(&mut display, utf8(b"description"), utf8(b"Top European Player Animate Nft to trade and Supply!"));
        display::update_version<Player>(&mut display);
        let (kiosk, kiosk_owner_cap) = kiosk::new(ctx);
        let (transfer_policy, transfer_policy_cap) = transfer_policy::new<Player>(&publisher, ctx);

        //Set 5% royalty
        new_royalty_policy<Player>(&publisher, 500, BENEFICIARY, ctx);

        let central_policy = CentralPolicy {
            id: object::new(ctx),
            kiosk_owner_cap,
            transfer_policy,
            transfer_policy_cap
        };

        let collection_info = CollectionInfo {
            id: object::new(ctx),
            publisher,
            display,
        };
        transfer::public_transfer(collection_info, tx_context::sender(ctx));
        transfer::share_object(central_policy);
        transfer::public_share_object(kiosk);
        // transfer::public_transfer(publisher, tx_context::sender(ctx));
    }


    public entry fun send_mint_cap(_cap: &AdminCap, recipient: address, ctx: &mut TxContext) {
        transfer::transfer(MintCap{
            id: object::new(ctx)
        }, recipient)
    }

    public entry fun mint_player(_cap: &MintCap, name: String, url: String, ctx: &mut TxContext) {
        let player = Player {
            id: object::new(ctx),
            name,
            url
        };

        transfer::public_transfer(player, tx_context::sender(ctx));
    }

    public entry fun place_and_list_to_kiosk(
        _cap: &MintCap,
        central_policy: &CentralPolicy,
        kiosk: &mut Kiosk,
        player: Player,
        price: u64
    ) { 
        let mist = 1000000000;
        kiosk::place_and_list<Player>(kiosk, &central_policy.kiosk_owner_cap, player, price * mist);
    }


    public entry fun remove_from_kiosk_list(
        kiosk: &mut Kiosk,
        central_policy: &CentralPolicy,
        player_id: address,
    ){
        kiosk::delist<Player>(kiosk, &central_policy.kiosk_owner_cap, object::id_from_address(player_id));
    }


    public entry fun buy_from_kiosk(
        central_policy: &CentralPolicy,
        kiosk: &mut Kiosk,
        player_id: address,
        payment: coin::Coin<SUI>,
        ctx: &mut TxContext
    ){
        let (player, transfer_req) = kiosk::purchase<Player>(kiosk,  object::id_from_address(player_id),  payment);
        transfer_policy::confirm_request<Player>(&central_policy.transfer_policy, transfer_req);
        transfer::public_transfer(player, tx_context::sender(ctx));
    }

    public entry fun get_profit_from_sell(
        central_policy: &CentralPolicy,
        kiosk: &mut Kiosk,
        amount: Option<u64>,
        ctx: &mut TxContext
    ){
        let (profit) = kiosk::withdraw(kiosk, &central_policy.kiosk_owner_cap, amount, ctx);
        transfer::public_transfer(profit, tx_context::sender(ctx));
    }

}