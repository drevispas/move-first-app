#[test_only]
module addr::basic_coin_tests {
  use std::debug::print;
  use std::signer;

  use addr::basic_coin::{Self, balance_of, mint, publish_balance};

  #[test(account = @addr)]
  fun check_signer_address(account: &signer) {
    print(&@addr);
    print(&signer::address_of(account));
    assert!(@addr == signer::address_of(account), 1);
  }

  #[test(account = @addr)]
  fun publish_balance_has_zero(account: &signer) {
    publish_balance(account);
    assert!(balance_of(@addr) == 0, 1);
  }

  #[test(account = @0x1)]
  #[expected_failure(abort_code = basic_coin::E_NOT_MODULE_OWNER, location = addr::basic_coin)]
  fun mint_non_owner(account: &signer) {
    publish_balance(account);
    assert!(signer::address_of(account) != @addr, 1);
    mint(account, @0x1, 10);
  }

  #[test(account = @addr)]
  fun mint_check_balance(account: &signer) {
    publish_balance(account);
    mint(account, @addr, 10);
    assert!(balance_of(@addr) == 10, 1);
  }

  #[test(account = @addr)]
  #[expected_failure(abort_code = basic_coin::E_ALREAD_HAS_BALANCE)]
  fun publish_balance_already_exists(account: &signer) {
    publish_balance(account);
    publish_balance(account);
  }

  #[test(account = @addr)]
  #[expected_failure]
  fun balance_of_dne(account: &signer) {
    publish_balance(account);
    balance_of(@0x01);
  }
}
