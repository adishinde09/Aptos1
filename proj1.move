module MyModule::LabBooking {

    use std::string::String;
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Each booking is stored as a resource.
    struct Booking has key {
        equipment: String,              // Equipment name
        slot: u64,                      // Time-slot (e.g., hour ID)
        deposit: coin::Coin<AptosCoin>, // Locked deposit stored inside resource
    }

    /// Book lab equipment with a deposit.
    public entry fun book_equipment(user: &signer, equipment: String, slot: u64, amount: u64) {
        let addr = signer::address_of(user);
        assert!(!exists<Booking>(addr), 1);

        // Withdraw deposit from user
        let deposit = coin::withdraw<AptosCoin>(user, amount);

        // Store booking with deposit inside
        let booking = Booking { equipment, slot, deposit };
        move_to(user, booking);
    }

    /// Cancel booking and auto-refund deposit.
    public entry fun cancel_booking(user: &signer) acquires Booking {
        let addr = signer::address_of(user);

        // Destructure the Booking to fully consume it
        let Booking { equipment: _, slot: _, deposit } = move_from<Booking>(addr);

        // Refund deposit back to user
        coin::deposit<AptosCoin>(addr, deposit);
    }
}
