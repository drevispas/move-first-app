script {
  use 0xcafe::first_app;
  use std::string;
  use std::debug;

  fun main() {
    let v = first_app::hello();
    debug::print(&string::utf8(v));
  }
}
