script {
  use 0xcafe::hello;
  use std::string;
  use std::debug;

  fun run() {
    let v = hello::hello();
    debug::print(&string::utf8(v));
  }
}
