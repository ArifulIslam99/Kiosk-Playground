module playermarket::admin{

    public struct AdminCap has key, store {
        id: UID
    }

    fun init(ctx: &mut TxContext) {
        transfer::public_transfer(AdminCap{
            id: object::new(ctx)
        }, tx_context::sender(ctx))
    }

    public fun delete_admin_cap(cap: AdminCap) {
        let AdminCap{id} = cap;
        object::delete(id);
    }
}