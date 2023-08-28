#[test_only]
module 0xcafe::first_app_tests {
  use 0xcafe::first_app;
  use std::debug::print;
  use std::string::utf8;

  #[test]
  public entry fun test_returns_one() {
    let v = first_app::hello();
    print(&utf8(v));
    assert!(v == b"Hello, World!", 1);
  }
}
