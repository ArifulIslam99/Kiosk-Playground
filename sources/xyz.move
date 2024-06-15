// module playermarket::unbound_nft {
//     use sui::object::{Self, UID};
//     use sui::kiosk;
//     use sui::transfer_policy;
//     use sui::tx_context::{Self, TxContext};
//     use std::string::{utf8, String};
//     use sui::transfer;
//     use sui::package;
//     use sui::display;  
//     use playermarket::royalty_rule;
//     // Structs with various capabilities
//     struct UNBOUND_NFT has drop { }
    
//     struct Witness has drop {}
    
//     struct UnboundNFT has store, key {
//         id: UID,
//         name: 0x1::string::String,
//         description: 0x1::string::String,
//         url: 0x1::string::String,
//     }
    
//     struct CollectionInfo has store, key {
//         id: UID,
//         publisher: package::Publisher,
//         display: display::Display<UnboundNFT>,
//         policy_cap: transfer_policy::TransferPolicyCap<UnboundNFT>,
//     }
    
//     struct MintCap<phantom T0> has store, key {
//         id: UID,
//     }
    
//     // struct MintEvent has copy, drop {
//     //     nft: ID,
//     // }
    
//     // Public function to add base64 string to the URL of an UnboundNFT
//     public fun add_base64(_arg0: &MintCap<UnboundNFT>, arg1: UnboundNFT, arg2: 0x1::string::String, _arg3: &mut tx_context::TxContext) : UnboundNFT {
//         0x1::string::append(&mut arg1.url, arg2);
//         arg1
//     }
    
//     #[allow(lint(self_transfer))]
//     // Public function to finalize an UnboundNFT and transfer it to the sender
//     public fun finalize_nft(_arg0: &MintCap<UnboundNFT>, arg1: UnboundNFT, arg2: &mut tx_context::TxContext) {
//         transfer::public_transfer<UnboundNFT>(arg1, tx_context::sender(arg2));
//     }
    

//     #[allow(lint(share_owned))]
//     // Initialization function to set up display and transfer policy for the collection
//     fun init(arg0: UNBOUND_NFT, arg1: &mut TxContext) {
//         let v0 = package::claim<UNBOUND_NFT>(arg0, arg1);
//         let v1 = display::new<UnboundNFT>(&v0, arg1);
//         display::add<UnboundNFT>(&mut v1, 0x1::string::utf8(b"name"), 0x1::string::utf8(b"{name}"));
//         display::add<UnboundNFT>(&mut v1, 0x1::string::utf8(b"image_url"), 0x1::string::utf8(b"{url}"));
//         display::add<UnboundNFT>(&mut v1, 0x1::string::utf8(b"description"), 0x1::string::utf8(b"{description}"));
//         display::update_version<UnboundNFT>(&mut v1);
//         let (v2, v3) = transfer_policy::new<UnboundNFT>(&v0, arg1);
//         let v4 = v3;
//         let v5 = v2;
//         royalty_rule::add<UnboundNFT>(&mut v5, &v4, 500, 100);
//         transfer::public_share_object<transfer_policy::TransferPolicy<UnboundNFT>>(v5);
//         let v6 = MintCap<UnboundNFT>{id: object::new(arg1)};
//         transfer::public_transfer<MintCap<UnboundNFT>>(v6, tx_context::sender(arg1));
//         let v7 = CollectionInfo{
//             id         : object::new(arg1), 
//             publisher  : v0, 
//             display    : v1, 
//             policy_cap : v4,
//         };
//         transfer::public_transfer<CollectionInfo>(v7, @0xc333120e29ae0b59f924836c2eff13a06b9009324dee51fe8aa880107c7b08be);
//     }
    
//     // Public function to mint a new UnboundNFT
//     public entry fun mint_nft(_arg0: &MintCap<UnboundNFT>, arg1: String, arg2: String, arg3: String, arg4: &mut tx_context::TxContext) {
//         let v0 = UnboundNFT{
//             id          : object::new(arg4), 
//             name        : arg1, 
//             description : arg2, 
//             url         : arg3,
//         };
//        transfer::public_transfer(v0, tx_context::sender(arg4));
//     }
    
//     #[allow(lint(share_owned))]
//     // Public function to put all NFTs into a kiosk
//     public entry fun put_all_nfts_into_kiosk(_arg0: &MintCap<UnboundNFT>, arg1: UnboundNFT, arg2: &mut tx_context::TxContext) {
//         let (v0, v1) = kiosk::new(arg2);
//         let v2 = v1;
//         let v3 = v0;
  
//             kiosk::place<UnboundNFT>(&mut v3, &v2, arg1);

//         transfer::public_transfer<kiosk::KioskOwnerCap>(v2, tx_context::sender(arg2));
//         transfer::public_share_object<kiosk::Kiosk>(v3);
//     }
    
//     // Decompiled from Move bytecode v6
// }
