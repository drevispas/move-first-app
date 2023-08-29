module addr::basic_coin {
  use std::signer;

  const MODULE_OWNER: address = @addr;
  const E_NOT_MODULE_OWNER: u64 = 1;
  const E_INSUFFICIENT_BALANCE: u64 = 2;
  const E_ALREAD_HAS_BALANCE: u64 = 3;

  struct Coin has store {
    value: u64
  }

  struct Balance has key {
    coin: Coin
  }

  // Create balance with 0 coin
  public fun publish_balance(account: &signer) {
    assert!(!exists<Balance>(signer::address_of(account)), E_ALREAD_HAS_BALANCE);
    move_to(account, Balance { coin: Coin { value: 0 } })
  }

  // Add coins to another account (mint_addr)
  public fun mint(module_owner: &signer, mint_addr: address, amount: u64) acquires Balance {
    assert!(signer::address_of(module_owner) == MODULE_OWNER, E_NOT_MODULE_OWNER);
    deposit(mint_addr, Coin { value: amount });
  }

  public fun balance_of(owner: address): u64 acquires Balance {
    borrow_global<Balance>(owner).coin.value
  }

  public fun transfer(from: &signer, to: address, amount: u64) acquires Balance {
    deposit(to, withdraw(signer::address_of(from), amount));
  }

  fun deposit(addr: address, check: Coin) acquires Balance {
    let balance = balance_of(addr);
    let balance_ref = borrow_global_mut<Balance>(addr);
    let val_ref = &mut balance_ref.coin.value;
    let Coin { value } = check;
    *val_ref = balance + value;
  }

  fun withdraw(addr: address, amount: u64): Coin acquires Balance {
    let balance = balance_of(addr);
    assert!(balance >= amount, E_INSUFFICIENT_BALANCE);
    let val_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
    *val_ref = balance - amount;
    Coin { value: amount }
  }

  #[test]
  #[expected_failure]
  fun withdraw_dne() acquires Balance {
    Coin { value: _ } = withdraw(@0x1, 0);
  }

  #[test(account = @addr)]
  #[expected_failure(abort_code = E_INSUFFICIENT_BALANCE)]
  fun withdraw_too_much(account: &signer) acquires Balance {
    publish_balance(account);
    mint(account, @addr, 10);
    Coin { value: _ } = withdraw(@addr, 20);
  }

  #[test(account = @addr)]
  fun can_withdraw_amount(account: &signer) acquires Balance {
    publish_balance(account);
    let amount = 8;
    mint(account, @addr, amount);
    let Coin { value } = withdraw(@addr, amount);
    assert!(value == amount, 1);
    assert!(balance_of(@addr) == 0, 2);
  }
}
