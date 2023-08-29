module addr::List {

  use std::signer;
  use std::vector;

  struct Item has store, drop {}

  struct List has key {
    items: vector<Item>
  }

  // create a new list under your account
  // only you can access to signer value
  public fun create_list(account: &signer) {
    // move resource to your account
    // only one resource type can be stored under one address
    move_to(account, List { items: vector::empty<Item>() })
  }

  // check if a resource exists under an address
  public fun resource_exists_at(at: address): bool {
    exists<List>(at)
  }

  // functions retrieving resources need to specify the list of acquiring resources
  public fun size(account: &signer): u64 acquires List {
    let owner = signer::address_of(account);
    let list = borrow_global<List>(owner);
    vector::length(&list.items)
  }

  public fun add_item(account: &signer) acquires List {
    let list = borrow_global_mut<List>(signer::address_of(account));
    vector::push_back(&mut list.items, Item {})
  }

  public fun destroy_list(account: &signer) acquires List {
    // detach a resource from an account
    let list = move_from<List>(signer::address_of(account));
    let List { items: _ } = list;
  }
}
