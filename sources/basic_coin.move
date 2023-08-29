module addr::basic_coin {
  use std::signer;

  const MODULE_OWNER: address = @addr;
  const E_NOT_MODULE_OWNER: u64 = 1;
  const E_INSUFFICIENT_BALANCE: u64 = 2;
  const E_ALREAD_HAS_BALANCE: u64 = 3;

  struct Coin<phantom T> has store {
    value: u64
  }

  struct Balance<phantom T> has key {
    coin: Coin<T>
  }

  struct MyCoin {}

  // Create balance with 0 coin
  public fun publish_balance<T>(account: &signer) {
    assert!(!exists<Balance<T>>(signer::address_of(account)), E_ALREAD_HAS_BALANCE);
    move_to(account, Balance<T> { coin: Coin { value: 0 } })
  }

  // Add coins to another account (mint_addr)
  public fun mint<T>(module_owner: &signer, mint_addr: address, amount: u64) acquires Balance {
    assert!(signer::address_of(module_owner) == MODULE_OWNER, E_NOT_MODULE_OWNER);
    deposit(mint_addr, Coin<T> { value: amount });
  }

  public fun balance_of<T>(owner: address): u64 acquires Balance {
    borrow_global<Balance<T>>(owner).coin.value
  }

  public fun transfer<T>(from: &signer, to: address, amount: u64) acquires Balance {
    deposit(to, withdraw<T>(signer::address_of(from), amount));
  }

  fun deposit<T>(addr: address, check: Coin<T>) acquires Balance {
    let balance = balance_of<T>(addr);
    let balance_ref = borrow_global_mut<Balance<T>>(addr);
    let val_ref = &mut balance_ref.coin.value;
    let Coin { value } = check;
    *val_ref = balance + value;
  }

  fun withdraw<T>(addr: address, amount: u64): Coin<T> acquires Balance {
    let balance = balance_of<T>(addr);
    assert!(balance >= amount, E_INSUFFICIENT_BALANCE);
    let val_ref = &mut borrow_global_mut<Balance<T>>(addr).coin.value;
    *val_ref = balance - amount;
    Coin { value: amount }
  }

  #[test]
  #[expected_failure]
  fun withdraw_dne() acquires Balance {
    Coin { value: _ } = withdraw<MyCoin>(@0x1, 0);
  }

  #[test(account = @addr)]
  #[expected_failure(abort_code = E_INSUFFICIENT_BALANCE)]
  fun withdraw_too_much(account: &signer) acquires Balance {
    publish_balance<MyCoin>(account);
    mint<MyCoin>(account, @addr, 10);
    Coin { value: _ } = withdraw<MyCoin>(@addr, 20);
  }

  #[test(account = @addr)]
  fun can_withdraw_amount(account: &signer) acquires Balance {
    publish_balance<MyCoin>(account);
    let amount = 8;
    mint<MyCoin>(account, @addr, amount);
    let Coin { value } = withdraw<MyCoin>(@addr, amount);
    assert!(value == amount, 1);
    assert!(balance_of<MyCoin>(@addr) == 0, 2);
  }
}
