# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/ripgrep/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: A search tool that combines the usability of ag with the raw speed of grep

build-depends:
- freedesktop-sdk.bst:components/rust.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: github:BurntSushi/ripgrep/archive/15.1.0/ripgrep-15.1.0.tar.gz
  ref: 046fa01a216793b8bd2750f9d68d4ad43986eb9c0d6122600f993906012972e8
- kind: cargo2
  cargo-lock: Cargo.lock
  ref:
  - kind: registry
    name: aho-corasick
    version: 1.1.3
    sha: 8e60d3430d3a69478ad0993f19238d2df97c507009a52b3c10addcd7f6bcb916
  - kind: registry
    name: anyhow
    version: 1.0.100
    sha: a23eb6b1614318a8071c9b2521f36b424b2c83db5eb3a0fead4a6c0809af6e61
  - kind: registry
    name: arbitrary
    version: 1.4.2
    sha: c3d036a3c4ab069c7b410a2ce876bd74808d2d0888a82667669f8e783a898bf1
  - kind: registry
    name: bstr
    version: 1.12.0
    sha: 234113d19d0d7d613b40e86fb654acf958910802bcceab913a4f9e7cda03b1a4
  - kind: registry
    name: cc
    version: 1.2.41
    sha: ac9fe6cdbb24b6ade63616c0a0688e45bb56732262c158df3c0c4bea4ca47cb7
  - kind: registry
    name: cfg-if
    version: 1.0.4
    sha: 9330f8b2ff13f34540b44e946ef35111825727b38d33286ef986142615121801
  - kind: registry
    name: crossbeam-channel
    version: 0.5.15
    sha: 82b8f8f868b36967f9606790d1903570de9ceaf870a7bf9fbbd3016d636a2cb2
  - kind: registry
    name: crossbeam-deque
    version: 0.8.6
    sha: 9dd111b7b7f7d55b72c0a6ae361660ee5853c9af73f70c3c2ef6858b950e2e51
  - kind: registry
    name: crossbeam-epoch
    version: 0.9.18
    sha: 5b82ac4a3c2ca9c3460964f020e1402edd5753411d7737aa39c3714ad1b5420e
  - kind: registry
    name: crossbeam-utils
    version: 0.8.21
    sha: d0a5c400df2834b80a4c3327b3aad3a4c4cd4de0629063962b03235697506a28
  - kind: registry
    name: derive_arbitrary
    version: 1.4.2
    sha: 1e567bd82dcff979e4b03460c307b3cdc9e96fde3d73bed1496d2bc75d9dd62a
  - kind: registry
    name: encoding_rs
    version: 0.8.35
    sha: 75030f3c4f45dafd7586dd6780965a8c7e8e285a5ecb86713e63a79c5b2766f3
  - kind: registry
    name: encoding_rs_io
    version: 0.1.7
    sha: 1cc3c5651fb62ab8aa3103998dade57efdd028544bd300516baa31840c252a83
  - kind: registry
    name: find-msvc-tools
    version: 0.1.4
    sha: 52051878f80a721bb68ebfbc930e07b65ba72f2da88968ea5c06fd6ca3d3a127
  - kind: registry
    name: getrandom
    version: 0.3.4
    sha: 899def5c37c4fd7b2664648c28120ecec138e4d395b459e5ca34f9cce2dd77fd
  - kind: registry
    name: glob
    version: 0.3.3
    sha: 0cc23270f6e1808e30a928bdc84dea0b9b4136a8bc82338574f23baf47bbd280
  - kind: registry
    name: itoa
    version: 1.0.15
    sha: 4a5f13b858c8d314ee3e8f639011f7ccefe71f97f96e50151fb991f267928e2c
  - kind: registry
    name: jobserver
    version: 0.1.34
    sha: 9afb3de4395d6b3e67a780b6de64b51c978ecf11cb9a462c66be7d4ca9039d33
  - kind: registry
    name: lexopt
    version: 0.3.1
    sha: 9fa0e2a1fcbe2f6be6c42e342259976206b383122fc152e872795338b5a3f3a7
  - kind: registry
    name: libc
    version: 0.2.177
    sha: 2874a2af47a2325c2001a6e6fad9b16a53b802102b528163885171cf92b15976
  - kind: registry
    name: log
    version: 0.4.28
    sha: 34080505efa8e45a4b816c349525ebe327ceaa8559756f0356cba97ef3bf7432
  - kind: registry
    name: memchr
    version: 2.7.6
    sha: f52b00d39961fc5b2736ea853c9cc86238e165017a493d1d5c8eac6bdc4cc273
  - kind: registry
    name: memmap2
    version: 0.9.9
    sha: 744133e4a0e0a658e1374cf3bf8e415c4052a15a111acd372764c55b4177d490
  - kind: registry
    name: pcre2
    version: 0.2.11
    sha: 9e970b0fcce0c7ee6ef662744ff711f21ccd6f11b7cf03cd187a80e89797fc67
  - kind: registry
    name: pcre2-sys
    version: 0.2.10
    sha: 18b9073c1a2549bd409bf4a32c94d903bb1a09bf845bc306ae148897fa0760a4
  - kind: registry
    name: pkg-config
    version: 0.3.32
    sha: 7edddbd0b52d732b21ad9a5fab5c704c14cd949e5e9a1ec5929a24fded1b904c
  - kind: registry
    name: proc-macro2
    version: 1.0.101
    sha: 89ae43fd86e4158d6db51ad8e2b80f313af9cc74f5c0e03ccb87de09998732de
  - kind: registry
    name: quote
    version: 1.0.41
    sha: ce25767e7b499d1b604768e7cde645d14cc8584231ea6b295e9c9eb22c02e1d1
  - kind: registry
    name: r-efi
    version: 5.3.0
    sha: 69cdb34c158ceb288df11e18b4bd39de994f6657d83847bdffdbd7f346754b0f
  - kind: registry
    name: regex
    version: 1.12.2
    sha: 843bc0191f75f3e22651ae5f1e72939ab2f72a4bc30fa80a066bd66edefc24d4
  - kind: registry
    name: regex-automata
    version: 0.4.13
    sha: 5276caf25ac86c8d810222b3dbb938e512c55c6831a10f3e6ed1c93b84041f1c
  - kind: registry
    name: regex-syntax
    version: 0.8.8
    sha: 7a2d987857b319362043e95f5353c0535c1f58eec5336fdfcf626430af7def58
  - kind: registry
    name: ryu
    version: 1.0.20
    sha: 28d3b2b1366ec20994f1fd18c3c594f05c5dd4bc44d8bb0c1c632c8d6829481f
  - kind: registry
    name: same-file
    version: 1.0.6
    sha: 93fc1dc3aaa9bfed95e02e6eadabb4baf7e3078b0bd1b4d7b6b0b68378900502
  - kind: registry
    name: serde
    version: 1.0.228
    sha: 9a8e94ea7f378bd32cbbd37198a4a91436180c5bb472411e48b5ec2e2124ae9e
  - kind: registry
    name: serde_core
    version: 1.0.228
    sha: 41d385c7d4ca58e59fc732af25c3983b67ac852c1a25000afe1175de458b67ad
  - kind: registry
    name: serde_derive
    version: 1.0.228
    sha: d540f220d3187173da220f885ab66608367b6574e925011a9353e4badda91d79
  - kind: registry
    name: serde_json
    version: 1.0.145
    sha: 402a6f66d8c709116cf22f558eab210f5a50187f702eb4d7e5ef38d9a7f1c79c
  - kind: registry
    name: shlex
    version: 1.3.0
    sha: 0fda2ff0d084019ba4d7c6f371c95d8fd75ce3524c3cb8fb653a3023f6323e64
  - kind: registry
    name: syn
    version: 2.0.107
    sha: 2a26dbd934e5451d21ef060c018dae56fc073894c5a7896f882928a76e6d081b
  - kind: registry
    name: termcolor
    version: 1.4.1
    sha: 06794f8f6c5c898b3275aebefa6b8a1cb24cd2c6c79397ab15774837a0bc5755
  - kind: registry
    name: textwrap
    version: 0.16.2
    sha: c13547615a44dc9c452a8a534638acdf07120d4b6847c8178705da06306a3057
  - kind: registry
    name: tikv-jemalloc-sys
    version: 0.6.1+5.3.0-1-ge13ca993e8ccb9ba9847cc330696e02839f328f7
    sha: cd8aa5b2ab86a2cefa406d889139c162cbb230092f7d1d7cbc1716405d852a3b
  - kind: registry
    name: tikv-jemallocator
    version: 0.6.1
    sha: 0359b4327f954e0567e69fb191cf1436617748813819c94b8cd4a431422d053a
  - kind: registry
    name: unicode-ident
    version: 1.0.20
    sha: 462eeb75aeb73aea900253ce739c8e18a67423fadf006037cd3ff27e82748a06
  - kind: registry
    name: walkdir
    version: 2.5.0
    sha: 29790946404f91d9c5d06f9874efddea1dc06c5efe94541a7d6863108e3a5e4b
  - kind: registry
    name: wasip2
    version: 1.0.1+wasi-0.2.4
    sha: 0562428422c63773dad2c345a1882263bbf4d65cf3f42e90921f787ef5ad58e7
  - kind: registry
    name: winapi-util
    version: 0.1.11
    sha: c2a7b1c03c876122aa43f3020e6c3c3ee5c05081c9a00739faf7503aeba10d22
  - kind: registry
    name: windows-link
    version: 0.2.1
    sha: f0805222e57f7521d6a62e36fa9163bc891acd422f971defe97d64e70d0a4fe5
  - kind: registry
    name: windows-sys
    version: 0.61.2
    sha: ae137229bcbd6cdf0f7b80a31df61766145077ddf49416a728b02cb3921ff3fc
  - kind: registry
    name: wit-bindgen
    version: 0.46.0
    sha: f17a85883d4e6d00e8a97c586de764dabcc06133f7f1d55dce5cdc070ad7fe59
