#[test_only]
module 0xcafe::hello_tests {
  // use std::debug::print;
  use std::string::{String, utf8};

  struct Box<T: drop> has drop {
    coin: Coin<T>
  }

  struct Coin<T> has drop {
    name: String,
    value: T
  }

  fun take_coin<T:drop>(box: &mut Box<T>): &mut Coin<T> {
    &mut box.coin
  }

  #[test]
  public entry fun test() {
    let coin = Coin { name: utf8(b"XXX"), value: 32 };
    let box = Box { coin };
    let coin_mut_ref = take_coin(&mut box);
    coin_mut_ref.value = 33;
    // print(coin_mut_ref);
  }
}
