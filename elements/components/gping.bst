# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/gping/-/raw/main/PKGBUILD?ref_type=heads
kind: manual

description: Ping, but with a graph

build-depends:
- freedesktop-sdk.bst:bootstrap/stripper.bst
- freedesktop-sdk.bst:components/rust.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: github:orf/gping/archive/gping-v1.20.1.tar.gz
  ref: 0df965111429d5fcef832a4ff23b452a1ec8f683d51ed31ce9b10902c0a18a9c
- kind: cargo2
  cargo-lock: Cargo.lock
  ref:
  - kind: registry
    name: aho-corasick
    version: 1.1.3
    sha: 8e60d3430d3a69478ad0993f19238d2df97c507009a52b3c10addcd7f6bcb916
  - kind: registry
    name: allocator-api2
    version: 0.2.21
    sha: 683d7910e743518b0e34f1186f92494becacb047c7b6bf616c96772180fef923
  - kind: registry
    name: android-tzdata
    version: 0.1.1
    sha: e999941b234f3131b00bc13c22d06e8c5ff726d1b6318ac7eb276997bbb4fef0
  - kind: registry
    name: android_system_properties
    version: 0.1.5
    sha: 819e7219dbd41043ac279b19830f2efc897156490d7fd6ea916720117ee66311
  - kind: registry
    name: anstream
    version: 0.6.20
    sha: 3ae563653d1938f79b1ab1b5e668c87c76a9930414574a6583a7b7e11a8e6192
  - kind: registry
    name: anstyle
    version: 1.0.11
    sha: 862ed96ca487e809f1c8e5a8447f6ee2cf102f846893800b20cebdf541fc6bbd
  - kind: registry
    name: anstyle-parse
    version: 0.2.7
    sha: 4e7644824f0aa2c7b9384579234ef10eb7efb6a0deb83f9630a49594dd9c15c2
  - kind: registry
    name: anstyle-query
    version: 1.1.4
    sha: 9e231f6134f61b71076a3eab506c379d4f36122f2af15a9ff04415ea4c3339e2
  - kind: registry
    name: anstyle-wincon
    version: 3.0.10
    sha: 3e0633414522a32ffaac8ac6cc8f748e090c5717661fddeea04219e2344f5f2a
  - kind: registry
    name: anyhow
    version: 1.0.99
    sha: b0674a1ddeecb70197781e945de4b3b8ffb61fa939a5597bcf48503737663100
  - kind: registry
    name: autocfg
    version: 1.5.0
    sha: c08606f8c3cbf4ce6ec8e28fb0014a2c086708fe954eaa885384a6165172e7e8
  - kind: registry
    name: base64
    version: 0.22.1
    sha: 72b3254f16251a8381aa12e40e3c4d2f0199f8c6508fbecb9d91f575e0fbb8c6
  - kind: registry
    name: bitflags
    version: 2.9.1
    sha: 1b8e56985ec62d17e9c1001dc89c88ecd7dc08e47eba5ec7c29c7b5eeecde967
  - kind: registry
    name: bumpalo
    version: 3.19.0
    sha: 46c5e41b57b8bba42a04676d81cb89e9ee8e859a1a66f80a5a72e1cb76b34d43
  - kind: registry
    name: cassowary
    version: 0.3.0
    sha: df8670b8c7b9dae1793364eafadf7239c40d669904660c5960d74cfd80b46a53
  - kind: registry
    name: castaway
    version: 0.2.4
    sha: dec551ab6e7578819132c713a93c022a05d60159dc86e7a7050223577484c55a
  - kind: registry
    name: cc
    version: 1.2.32
    sha: 2352e5597e9c544d5e6d9c95190d5d27738ade584fa8db0a16e130e5c2b5296e
  - kind: registry
    name: cfg-if
    version: 1.0.1
    sha: 9555578bc9e57714c812a1f84e4fc5b4d21fcb063490c624de019f7464c91268
  - kind: registry
    name: chrono
    version: 0.4.41
    sha: c469d952047f47f91b68d1cba3f10d63c11d73e4636f24f08daf0278abf01c4d
  - kind: registry
    name: clap
    version: 4.5.45
    sha: 1fc0e74a703892159f5ae7d3aac52c8e6c392f5ae5f359c70b5881d60aaac318
  - kind: registry
    name: clap_builder
    version: 4.5.44
    sha: b3e7f4214277f3c7aa526a59dd3fbe306a370daee1f8b7b8c987069cd8e888a8
  - kind: registry
    name: clap_derive
    version: 4.5.45
    sha: 14cb31bb0a7d536caef2639baa7fad459e15c3144efefa6dbd1c84562c4739f6
  - kind: registry
    name: clap_lex
    version: 0.7.5
    sha: b94f61472cee1439c0b966b47e3aca9ae07e45d070759512cd390ea2bebc6675
  - kind: registry
    name: clap_mangen
    version: 0.2.29
    sha: 27b4c3c54b30f0d9adcb47f25f61fcce35c4dd8916638c6b82fbd5f4fb4179e2
  - kind: registry
    name: colorchoice
    version: 1.0.4
    sha: b05b61dc5112cbb17e4b6cd61790d9845d13888356391624cbe7e41efeac1e75
  - kind: registry
    name: compact_str
    version: 0.8.1
    sha: 3b79c4069c6cad78e2e0cdfcbd26275770669fb39fd308a752dc110e83b9af32
  - kind: registry
    name: const_format
    version: 0.2.34
    sha: 126f97965c8ad46d6d9163268ff28432e8f6a1196a55578867832e3049df63dd
  - kind: registry
    name: const_format_proc_macros
    version: 0.2.34
    sha: 1d57c2eccfb16dbac1f4e61e206105db5820c9d26c3c472bc17c774259ef7744
  - kind: registry
    name: convert_case
    version: 0.7.1
    sha: bb402b8d4c85569410425650ce3eddc7d698ed96d39a73f941b08fb63082f1e7
  - kind: registry
    name: core-foundation-sys
    version: 0.8.7
    sha: 773648b94d0e5d620f64f280777445740e61fe701025087ec8b57f45c791888b
  - kind: registry
    name: crossterm
    version: 0.28.1
    sha: 829d955a0bb380ef178a640b91779e3987da38c9aea133b20614cfed8cdea9c6
  - kind: registry
    name: crossterm
    version: 0.29.0
    sha: d8b9f2e4c67f833b660cdb0a3523065869fb35570177239812ed4c905aeff87b
  - kind: registry
    name: crossterm_winapi
    version: 0.9.1
    sha: acdd7c62a3665c7f6830a51635d9ac9b23ed385797f70a83bb8bafe9c572ab2b
  - kind: registry
    name: darling
    version: 0.20.11
    sha: fc7f46116c46ff9ab3eb1597a45688b6715c6e628b5c133e288e709a29bcb4ee
  - kind: registry
    name: darling_core
    version: 0.20.11
    sha: 0d00b9596d185e565c2207a0b01f8bd1a135483d02d9b7b0a54b11da8d53412e
  - kind: registry
    name: darling_macro
    version: 0.20.11
    sha: fc34b93ccb385b40dc71c6fceac4b2ad23662c7eeb248cf10d529b7e055b6ead
  - kind: registry
    name: deranged
    version: 0.4.0
    sha: 9c9e6a11ca8224451684bc0d7d5a7adbf8f2fd6887261a1cfc3c0432f9d4068e
  - kind: registry
    name: derive_more
    version: 2.0.1
    sha: 093242cf7570c207c83073cf82f79706fe7b8317e98620a47d5be7c3d8497678
  - kind: registry
    name: derive_more-impl
    version: 2.0.1
    sha: bda628edc44c4bb645fbe0f758797143e4e07926f7ebf4e9bdfbd3d2ce621df3
  - kind: registry
    name: displaydoc
    version: 0.2.5
    sha: 97369cbbc041bc366949bc74d34658d6cda5621039731c6310521892a3a20ae0
  - kind: registry
    name: document-features
    version: 0.2.11
    sha: 95249b50c6c185bee49034bcb378a49dc2b5dff0be90ff6616d31d64febab05d
  - kind: registry
    name: either
    version: 1.15.0
    sha: 48c757948c5ede0e46177b7add2e67155f70e33c07fea8284df6576da70b3719
  - kind: registry
    name: equivalent
    version: 1.0.2
    sha: 877a4ace8713b0bcf2a4e7eec82529c029f1d0619886d18145fea96c3ffe5c0f
  - kind: registry
    name: errno
    version: 0.3.13
    sha: 778e2ac28f6c47af28e4907f13ffd1e1ddbd400980a9abd7c8df189bf578a5ad
  - kind: registry
    name: fnv
    version: 1.0.7
    sha: 3f9eec918d3f24069decb9af1554cad7c880e2da24a9afd88aca000531ab82c1
  - kind: registry
    name: foldhash
    version: 0.1.5
    sha: d9c4f5dac5e15c24eb999c26181a6ca40b39fe946cbe4c263c7209467bc83af2
  - kind: registry
    name: form_urlencoded
    version: 1.2.1
    sha: e13624c2627564efccf4934284bdd98cbaa14e79b0b5a141218e507b3a823456
  - kind: registry
    name: getrandom
    version: 0.3.3
    sha: 26145e563e54f2cadc477553f1ec5ee650b00862f0a58bcd12cbdc5f0ea2d2f4
  - kind: registry
    name: git2
    version: 0.20.2
    sha: 2deb07a133b1520dc1a5690e9bd08950108873d7ed5de38dcc74d3b5ebffa110
  - kind: registry
    name: hashbrown
    version: 0.15.5
    sha: 9229cfe53dfd69f0609a49f65461bd93001ea1ef889cd5529dd176593f5338a1
  - kind: registry
    name: heck
    version: 0.5.0
    sha: 2304e00983f87ffb38b55b444b5e3b60a884b5d30c0fca7d82fe33449bbe55ea
  - kind: registry
    name: iana-time-zone
    version: 0.1.63
    sha: b0c919e5debc312ad217002b8048a17b7d83f80703865bbfcfebb0458b0b27d8
  - kind: registry
    name: iana-time-zone-haiku
    version: 0.1.2
    sha: f31827a206f56af32e590ba56d5d2d085f558508192593743f16b2306495269f
  - kind: registry
    name: icu_collections
    version: 2.0.0
    sha: 200072f5d0e3614556f94a9930d5dc3e0662a652823904c3a75dc3b0af7fee47
  - kind: registry
    name: icu_locale_core
    version: 2.0.0
    sha: 0cde2700ccaed3872079a65fb1a78f6c0a36c91570f28755dda67bc8f7d9f00a
  - kind: registry
    name: icu_normalizer
    version: 2.0.0
    sha: 436880e8e18df4d7bbc06d58432329d6458cc84531f7ac5f024e93deadb37979
  - kind: registry
    name: icu_normalizer_data
    version: 2.0.0
    sha: 00210d6893afc98edb752b664b8890f0ef174c8adbb8d0be9710fa66fbbf72d3
  - kind: registry
    name: icu_properties
    version: 2.0.1
    sha: 016c619c1eeb94efb86809b015c58f479963de65bdb6253345c1a1276f22e32b
  - kind: registry
    name: icu_properties_data
    version: 2.0.1
    sha: 298459143998310acd25ffe6810ed544932242d3f07083eee1084d83a71bd632
  - kind: registry
    name: icu_provider
    version: 2.0.0
    sha: 03c80da27b5f4187909049ee2d72f276f0d9f99a42c306bd0131ecfe04d8e5af
  - kind: registry
    name: ident_case
    version: 1.0.1
    sha: b9e0384b61958566e926dc50660321d12159025e767c18e043daf26b70104c39
  - kind: registry
    name: idna
    version: 1.0.3
    sha: 686f825264d630750a544639377bae737628043f20d38bbc029e8f29ea968a7e
  - kind: registry
    name: idna_adapter
    version: 1.2.1
    sha: 3acae9609540aa318d1bc588455225fb2085b9ed0c4f6bd0d9d5bcd86f1a0344
  - kind: registry
    name: indexmap
    version: 2.10.0
    sha: fe4cd85333e22411419a0bcae1297d25e58c9443848b11dc6a86fefe8c78a661
  - kind: registry
    name: indoc
    version: 2.0.6
    sha: f4c7245a08504955605670dbf141fceab975f15ca21570696aebe9d2e71576bd
  - kind: registry
    name: instability
    version: 0.3.9
    sha: 435d80800b936787d62688c927b6490e887c7ef5ff9ce922c6c6050fca75eb9a
  - kind: registry
    name: is_debug
    version: 1.1.0
    sha: 1fe266d2e243c931d8190177f20bf7f24eed45e96f39e87dc49a27b32d12d407
  - kind: registry
    name: is_terminal_polyfill
    version: 1.70.1
    sha: 7943c866cc5cd64cbc25b2e01621d07fa8eb2a1a23160ee81ce38704e97b8ecf
  - kind: registry
    name: itertools
    version: 0.13.0
    sha: 413ee7dfc52ee1a4949ceeb7dbc8a33f2d6c088194d9f922fb8318faf1f01186
  - kind: registry
    name: itertools
    version: 0.14.0
    sha: 2b192c782037fadd9cfa75548310488aabdbf3d2da73885b31bd0abd03351285
  - kind: registry
    name: itoa
    version: 1.0.15
    sha: 4a5f13b858c8d314ee3e8f639011f7ccefe71f97f96e50151fb991f267928e2c
  - kind: registry
    name: jobserver
    version: 0.1.33
    sha: 38f262f097c174adebe41eb73d66ae9c06b2844fb0da69969647bbddd9b0538a
  - kind: registry
    name: js-sys
    version: 0.3.77
    sha: 1cfaf33c695fc6e08064efbc1f72ec937429614f25eef83af942d0e227c3a28f
  - kind: registry
    name: lazy-regex
    version: 3.4.1
    sha: 60c7310b93682b36b98fa7ea4de998d3463ccbebd94d935d6b48ba5b6ffa7126
  - kind: registry
    name: lazy-regex-proc_macros
    version: 3.4.1
    sha: 4ba01db5ef81e17eb10a5e0f2109d1b3a3e29bac3070fdbd7d156bf7dbd206a1
  - kind: registry
    name: lazy_static
    version: 1.5.0
    sha: bbd2bcb4c963f2ddae06a2efc7e9f3591312473c50c6685e1f298068316e66fe
  - kind: registry
    name: libc
    version: 0.2.175
    sha: 6a82ae493e598baaea5209805c49bbf2ea7de956d50d7da0da1164f9c6d28543
  - kind: registry
    name: libgit2-sys
    version: 0.18.2+1.9.1
    sha: 1c42fe03df2bd3c53a3a9c7317ad91d80c81cd1fb0caec8d7cc4cd2bfa10c222
  - kind: registry
    name: libz-sys
    version: 1.1.22
    sha: 8b70e7a7df205e92a1a4cd9aaae7898dac0aa555503cc0a649494d0d60e7651d
  - kind: registry
    name: linux-raw-sys
    version: 0.4.15
    sha: d26c52dbd32dccf2d10cac7725f8eae5296885fb5703b261f7d0a0739ec807ab
  - kind: registry
    name: linux-raw-sys
    version: 0.9.4
    sha: cd945864f07fe9f5371a27ad7b52a172b4b499999f1d97574c9fa68373937e12
  - kind: registry
    name: litemap
    version: 0.8.0
    sha: 241eaef5fd12c88705a01fc1066c48c4b36e0dd4377dcdc7ec3942cea7a69956
  - kind: registry
    name: litrs
    version: 0.4.2
    sha: f5e54036fe321fd421e10d732f155734c4e4afd610dd556d9a82833ab3ee0bed
  - kind: registry
    name: lock_api
    version: 0.4.13
    sha: 96936507f153605bddfcda068dd804796c84324ed2510809e5b2a624c81da765
  - kind: registry
    name: log
    version: 0.4.27
    sha: 13dc2df351e3202783a1fe0d44375f7295ffb4049267b0f3018346dc122a1d94
  - kind: registry
    name: lru
    version: 0.12.5
    sha: 234cf4f4a04dc1f57e24b96cc0cd600cf2af460d4161ac5ecdd0af8e1f3b2a38
  - kind: registry
    name: memchr
    version: 2.7.5
    sha: 32a282da65faaf38286cf3be983213fcf1d2e2a58700e808f83f4ea9a4804bc0
  - kind: registry
    name: mio
    version: 1.0.4
    sha: 78bed444cc8a2160f01cbcf811ef18cac863ad68ae8ca62092e8db51d51c761c
  - kind: registry
    name: ntest
    version: 0.9.3
    sha: fb183f0a1da7a937f672e5ee7b7edb727bf52b8a52d531374ba8ebb9345c0330
  - kind: registry
    name: ntest_test_cases
    version: 0.9.3
    sha: 16d0d3f2a488592e5368ebbe996e7f1d44aa13156efad201f5b4d84e150eaa93
  - kind: registry
    name: ntest_timeout
    version: 0.9.3
    sha: fcc7c92f190c97f79b4a332f5e81dcf68c8420af2045c936c9be0bc9de6f63b5
  - kind: registry
    name: num-conv
    version: 0.1.0
    sha: 51d515d32fb182ee37cda2ccdcb92950d6a3c2893aa280e540671c2cd0f3b1d9
  - kind: registry
    name: num-traits
    version: 0.2.19
    sha: 071dfc062690e90b734c0b2273ce72ad0ffa95f0c74596bc250dcfd960262841
  - kind: registry
    name: num_threads
    version: 0.1.7
    sha: 5c7398b9c8b70908f6371f47ed36737907c87c52af34c268fed0bf0ceb92ead9
  - kind: registry
    name: once_cell
    version: 1.21.3
    sha: 42f5e15c9953c5e4ccceeb2e7382a716482c34515315f7b03532b8b4e8393d2d
  - kind: registry
    name: once_cell_polyfill
    version: 1.70.1
    sha: a4895175b425cb1f87721b59f0f286c2092bd4af812243672510e1ac53e2e0ad
  - kind: registry
    name: os_info
    version: 3.12.0
    sha: d0e1ac5fde8d43c34139135df8ea9ee9465394b2d8d20f032d38998f64afffc3
  - kind: registry
    name: parking_lot
    version: 0.12.4
    sha: 70d58bf43669b5795d1576d0641cfb6fbb2057bf629506267a92807158584a13
  - kind: registry
    name: parking_lot_core
    version: 0.9.11
    sha: bc838d2a56b5b1a6c25f55575dfc605fabb63bb2365f6c2353ef9159aa69e4a5
  - kind: registry
    name: paste
    version: 1.0.15
    sha: 57c0d7b74b563b49d38dae00a0c37d4d6de9b432382b2892f0574ddcae73fd0a
  - kind: registry
    name: percent-encoding
    version: 2.3.1
    sha: e3148f5046208a5d56bcfc03053e3ca6334e51da8dfb19b6cdc8b306fae3283e
  - kind: registry
    name: pkg-config
    version: 0.3.32
    sha: 7edddbd0b52d732b21ad9a5fab5c704c14cd949e5e9a1ec5929a24fded1b904c
  - kind: registry
    name: plist
    version: 1.7.4
    sha: 3af6b589e163c5a788fab00ce0c0366f6efbb9959c2f9874b224936af7fce7e1
  - kind: registry
    name: potential_utf
    version: 0.1.2
    sha: e5a7c30837279ca13e7c867e9e40053bc68740f988cb07f7ca6df43cc734b585
  - kind: registry
    name: powerfmt
    version: 0.2.0
    sha: 439ee305def115ba05938db6eb1644ff94165c5ab5e9420d1c1bcedbba909391
  - kind: registry
    name: ppv-lite86
    version: 0.2.21
    sha: 85eae3c4ed2f50dcfe72643da4befc30deadb458a9b590d720cde2f2b1e97da9
  - kind: registry
    name: proc-macro-crate
    version: 3.3.0
    sha: edce586971a4dfaa28950c6f18ed55e0406c1ab88bbce2c6f6293a7aaba73d35
  - kind: registry
    name: proc-macro2
    version: 1.0.97
    sha: d61789d7719defeb74ea5fe81f2fdfdbd28a803847077cecce2ff14e1472f6f1
  - kind: registry
    name: quick-xml
    version: 0.38.1
    sha: 9845d9dccf565065824e69f9f235fafba1587031eda353c1f1561cd6a6be78f4
  - kind: registry
    name: quote
    version: 1.0.40
    sha: 1885c039570dc00dcb4ff087a89e185fd56bae234ddc7f056a945bf36467248d
  - kind: registry
    name: r-efi
    version: 5.3.0
    sha: 69cdb34c158ceb288df11e18b4bd39de994f6657d83847bdffdbd7f346754b0f
  - kind: registry
    name: rand
    version: 0.9.2
    sha: 6db2770f06117d490610c7488547d543617b21bfa07796d7a12f6f1bd53850d1
  - kind: registry
    name: rand_chacha
    version: 0.9.0
    sha: d3022b5f1df60f26e1ffddd6c66e8aa15de382ae63b3a0c1bfc0e4d3e3f325cb
  - kind: registry
    name: rand_core
    version: 0.9.3
    sha: 99d9a13982dcf210057a8a78572b2217b667c3beacbf3a0d8b454f6f82837d38
  - kind: registry
    name: ratatui
    version: 0.29.0
    sha: eabd94c2f37801c20583fc49dd5cd6b0ba68c716787c2dd6ed18571e1e63117b
  - kind: registry
    name: redox_syscall
    version: 0.5.17
    sha: 5407465600fb0548f1442edf71dd20683c6ed326200ace4b1ef0763521bb3b77
  - kind: registry
    name: regex
    version: 1.11.1
    sha: b544ef1b4eac5dc2db33ea63606ae9ffcfac26c1416a2806ae0bf5f56b201191
  - kind: registry
    name: regex-automata
    version: 0.4.9
    sha: 809e8dc61f6de73b46c85f4c96486310fe304c434cfa43669d7b40f711150908
  - kind: registry
    name: regex-syntax
    version: 0.8.5
    sha: 2b15c43186be67a4fd63bee50d0303afffcef381492ebe2c5d87f324e1b8815c
  - kind: registry
    name: roff
    version: 0.2.2
    sha: 88f8660c1ff60292143c98d08fc6e2f654d722db50410e3f3797d40baaf9d8f3
  - kind: registry
    name: rustix
    version: 0.38.44
    sha: fdb5bc1ae2baa591800df16c9ca78619bf65c0488b41b96ccec5d11220d8c154
  - kind: registry
    name: rustix
    version: 1.0.8
    sha: 11181fbabf243db407ef8df94a6ce0b2f9a733bd8be4ad02b4eda9602296cac8
  - kind: registry
    name: rustversion
    version: 1.0.22
    sha: b39cdef0fa800fc44525c84ccb54a029961a8215f9619753635a9c0d2538d46d
  - kind: registry
    name: ryu
    version: 1.0.20
    sha: 28d3b2b1366ec20994f1fd18c3c594f05c5dd4bc44d8bb0c1c632c8d6829481f
  - kind: registry
    name: scopeguard
    version: 1.2.0
    sha: 94143f37725109f92c262ed2cf5e59bce7498c01bcc1502d7b9afe439a4e9f49
  - kind: registry
    name: serde
    version: 1.0.219
    sha: 5f0e2c6ed6606019b4e29e69dbaba95b11854410e5347d525002456dbbb786b6
  - kind: registry
    name: serde_derive
    version: 1.0.219
    sha: 5b0276cf7f2c73365f7157c8123c21cd9a50fbbd844757af28ca1f5925fc2a00
  - kind: registry
    name: shadow-rs
    version: 1.2.1
    sha: 5f0b6af233ae5461c3c6b30db79190ec5fbbef048ebbd5f2cbb3043464168e00
  - kind: registry
    name: shlex
    version: 1.3.0
    sha: 0fda2ff0d084019ba4d7c6f371c95d8fd75ce3524c3cb8fb653a3023f6323e64
  - kind: registry
    name: signal-hook
    version: 0.3.18
    sha: d881a16cf4426aa584979d30bd82cb33429027e42122b169753d6ef1085ed6e2
  - kind: registry
    name: signal-hook-mio
    version: 0.2.4
    sha: 34db1a06d485c9142248b7a054f034b349b212551f3dfd19c94d45a754a217cd
  - kind: registry
    name: signal-hook-registry
    version: 1.4.6
    sha: b2a4719bff48cee6b39d12c020eeb490953ad2443b7055bd0b21fca26bd8c28b
  - kind: registry
    name: smallvec
    version: 1.15.1
    sha: 67b1b7a3b5fe4f1376887184045fcf45c69e92af734b7aaddc05fb777b6fbd03
  - kind: registry
    name: stable_deref_trait
    version: 1.2.0
    sha: a8f112729512f8e442d81f95a8a7ddf2b7c6b8a1a6f509a95864142b30cab2d3
  - kind: registry
    name: static_assertions
    version: 1.1.0
    sha: a2eb9349b6444b326872e140eb1cf5e7c522154d69e7a0ffb0fb81c06b37543f
  - kind: registry
    name: strsim
    version: 0.11.1
    sha: 7da8b5736845d9f2fcb837ea5d9e2628564b3b043a70948a3f0b778838c5fb4f
  - kind: registry
    name: strum
    version: 0.26.3
    sha: 8fec0f0aef304996cf250b31b5a10dee7980c85da9d759361292b8bca5a18f06
  - kind: registry
    name: strum_macros
    version: 0.26.4
    sha: 4c6bee85a5a24955dc440386795aa378cd9cf82acd5f764469152d2270e581be
  - kind: registry
    name: syn
    version: 1.0.109
    sha: 72b64191b275b66ffe2469e8af2c1cfe3bafa67b529ead792a6d0160888b4237
  - kind: registry
    name: syn
    version: 2.0.105
    sha: 7bc3fcb250e53458e712715cf74285c1f889686520d79294a9ef3bd7aa1fc619
  - kind: registry
    name: synstructure
    version: 0.13.2
    sha: 728a70f3dbaf5bab7f0c4b1ac8d7ae5ea60a4b5549c8a5914361c99147a709d2
  - kind: registry
    name: thiserror
    version: 2.0.14
    sha: 0b0949c3a6c842cbde3f1686d6eea5a010516deb7085f79db747562d4102f41e
  - kind: registry
    name: thiserror-impl
    version: 2.0.14
    sha: cc5b44b4ab9c2fdd0e0512e6bece8388e214c0749f5862b114cc5b7a25daf227
  - kind: registry
    name: time
    version: 0.3.41
    sha: 8a7619e19bc266e0f9c5e6686659d394bc57973859340060a69221e57dbc0c40
  - kind: registry
    name: time-core
    version: 0.1.4
    sha: c9e9a38711f559d9e3ce1cdb06dd7c5b8ea546bc90052da6d06bb76da74bb07c
  - kind: registry
    name: time-macros
    version: 0.2.22
    sha: 3526739392ec93fd8b359c8e98514cb3e8e021beb4e5f597b00a0221f8ed8a49
  - kind: registry
    name: tinystr
    version: 0.8.1
    sha: 5d4f6d1145dcb577acf783d4e601bc1d76a13337bb54e6233add580b07344c8b
  - kind: registry
    name: toml_datetime
    version: 0.6.11
    sha: 22cddaf88f4fbc13c51aebbf5f8eceb5c7c5a9da2ac40a13519eb5b0a0e8f11c
  - kind: registry
    name: toml_edit
    version: 0.22.27
    sha: 41fe8c660ae4257887cf66394862d21dbca4a6ddd26f04a3560410406a2f819a
  - kind: registry
    name: tz-rs
    version: 0.7.0
    sha: e1450bf2b99397e72070e7935c89facaa80092ac812502200375f1f7d33c71a1
  - kind: registry
    name: tzdb
    version: 0.7.2
    sha: 0be2ea5956f295449f47c0b825c5e109022ff1a6a53bb4f77682a87c2341fbf5
  - kind: registry
    name: tzdb_data
    version: 0.2.2
    sha: 9c4c81d75033770e40fbd3643ce7472a1a9fd301f90b7139038228daf8af03ec
  - kind: registry
    name: unicode-ident
    version: 1.0.18
    sha: 5a5f39404a5da50712a4c1eecf25e90dd62b613502b7e925fd4e4d19b5c96512
  - kind: registry
    name: unicode-segmentation
    version: 1.12.0
    sha: f6ccf251212114b54433ec949fd6a7841275f9ada20dddd2f29e9ceea4501493
  - kind: registry
    name: unicode-truncate
    version: 1.1.0
    sha: b3644627a5af5fa321c95b9b235a72fd24cd29c648c2c379431e6628655627bf
  - kind: registry
    name: unicode-width
    version: 0.1.14
    sha: 7dd6e30e90baa6f72411720665d41d89b9a3d039dc45b8faea1ddd07f617f6af
  - kind: registry
    name: unicode-width
    version: 0.2.0
    sha: 1fc81956842c57dac11422a97c3b8195a1ff727f06e85c84ed2e8aa277c9a0fd
  - kind: registry
    name: unicode-xid
    version: 0.2.6
    sha: ebc1c04c71510c7f702b52b7c350734c9ff1295c464a03335b00bb84fc54f853
  - kind: registry
    name: url
    version: 2.5.4
    sha: 32f8b686cadd1473f4bd0117a5d28d36b1ade384ea9b5069a1c40aefed7fda60
  - kind: registry
    name: utf8_iter
    version: 1.0.4
    sha: b6c140620e7ffbb22c2dee59cafe6084a59b5ffc27a8859a5f0d494b5d52b6be
  - kind: registry
    name: utf8parse
    version: 0.2.2
    sha: 06abde3611657adf66d383f00b093d7faecc7fa57071cce2578660c9f1010821
  - kind: registry
    name: vcpkg
    version: 0.2.15
    sha: accd4ea62f7bb7a82fe23066fb0957d48ef677f6eeb8215f372f52e48bb32426
  - kind: registry
    name: wasi
    version: 0.11.1+wasi-snapshot-preview1
    sha: ccf3ec651a847eb01de73ccad15eb7d99f80485de043efb2f370cd654f4ea44b
  - kind: registry
    name: wasi
    version: 0.14.2+wasi-0.2.4
    sha: 9683f9a5a998d873c0d21fcbe3c083009670149a8fab228644b8bd36b2c48cb3
  - kind: registry
    name: wasm-bindgen
    version: 0.2.100
    sha: 1edc8929d7499fc4e8f0be2262a241556cfc54a0bea223790e71446f2aab1ef5
  - kind: registry
    name: wasm-bindgen-backend
    version: 0.2.100
    sha: 2f0a0651a5c2bc21487bde11ee802ccaf4c51935d0d3d42a6101f98161700bc6
  - kind: registry
    name: wasm-bindgen-macro
    version: 0.2.100
    sha: 7fe63fc6d09ed3792bd0897b314f53de8e16568c2b3f7982f468c0bf9bd0b407
  - kind: registry
    name: wasm-bindgen-macro-support
    version: 0.2.100
    sha: 8ae87ea40c9f689fc23f209965b6fb8a99ad69aeeb0231408be24920604395de
  - kind: registry
    name: wasm-bindgen-shared
    version: 0.2.100
    sha: 1a05d73b933a847d6cccdda8f838a22ff101ad9bf93e33684f39c1f5f0eece3d
  - kind: registry
    name: winapi
    version: 0.3.9
    sha: 5c839a674fcd7a98952e593242ea400abe93992746761e38641405d28b00f419
  - kind: registry
    name: winapi-i686-pc-windows-gnu
    version: 0.4.0
    sha: ac3b87c63620426dd9b991e5ce0329eff545bccbbb34f3be09ff6fb6ab51b7b6
  - kind: registry
    name: winapi-x86_64-pc-windows-gnu
    version: 0.4.0
    sha: 712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f
  - kind: registry
    name: winapi_forked_icmpapi
    version: 0.3.7
    sha: 42aecb895d6340af9ccc8dab9aeabfeab6d5d7266c5fd172c8be7e07db71c1e3
  - kind: registry
    name: windows-core
    version: 0.61.2
    sha: c0fdd3ddb90610c7638aa2b3a3ab2904fb9e5cdbecc643ddb3647212781c4ae3
  - kind: registry
    name: windows-implement
    version: 0.60.0
    sha: a47fddd13af08290e67f4acabf4b459f647552718f683a7b415d290ac744a836
  - kind: registry
    name: windows-interface
    version: 0.59.1
    sha: bd9211b69f8dcdfa817bfd14bf1c97c9188afa36f4750130fcdf3f400eca9fa8
  - kind: registry
    name: windows-link
    version: 0.1.3
    sha: 5e6ad25900d524eaabdbbb96d20b4311e1e7ae1699af4fb28c17ae66c80d798a
  - kind: registry
    name: windows-result
    version: 0.3.4
    sha: 56f42bd332cc6c8eac5af113fc0c1fd6a8fd2aa08a0119358686e5160d0586c6
  - kind: registry
    name: windows-strings
    version: 0.4.2
    sha: 56e6c93f3a0c3b36176cb1327a4958a0353d5d166c2a35cb268ace15e91d3b57
  - kind: registry
    name: windows-sys
    version: 0.52.0
    sha: 282be5f36a8ce781fad8c8ae18fa3f9beff57ec1b52cb3de0789201425d9a33d
  - kind: registry
    name: windows-sys
    version: 0.59.0
    sha: 1e38bc4d79ed67fd075bcc251a1c39b32a1776bbe92e5bef1f0bf1f8c531853b
  - kind: registry
    name: windows-sys
    version: 0.60.2
    sha: f2f500e4d28234f72040990ec9d39e3a6b950f9f22d3dba18416c35882612bcb
  - kind: registry
    name: windows-targets
    version: 0.52.6
    sha: 9b724f72796e036ab90c1021d4780d4d3d648aca59e491e6b98e725b84e99973
  - kind: registry
    name: windows-targets
    version: 0.53.3
    sha: d5fe6031c4041849d7c496a8ded650796e7b6ecc19df1a431c1a363342e5dc91
  - kind: registry
    name: windows_aarch64_gnullvm
    version: 0.52.6
    sha: 32a4622180e7a0ec044bb555404c800bc9fd9ec262ec147edd5989ccd0c02cd3
  - kind: registry
    name: windows_aarch64_gnullvm
    version: 0.53.0
    sha: 86b8d5f90ddd19cb4a147a5fa63ca848db3df085e25fee3cc10b39b6eebae764
  - kind: registry
    name: windows_aarch64_msvc
    version: 0.52.6
    sha: 09ec2a7bb152e2252b53fa7803150007879548bc709c039df7627cabbd05d469
  - kind: registry
    name: windows_aarch64_msvc
    version: 0.53.0
    sha: c7651a1f62a11b8cbd5e0d42526e55f2c99886c77e007179efff86c2b137e66c
  - kind: registry
    name: windows_i686_gnu
    version: 0.52.6
    sha: 8e9b5ad5ab802e97eb8e295ac6720e509ee4c243f69d781394014ebfe8bbfa0b
  - kind: registry
    name: windows_i686_gnu
    version: 0.53.0
    sha: c1dc67659d35f387f5f6c479dc4e28f1d4bb90ddd1a5d3da2e5d97b42d6272c3
  - kind: registry
    name: windows_i686_gnullvm
    version: 0.52.6
    sha: 0eee52d38c090b3caa76c563b86c3a4bd71ef1a819287c19d586d7334ae8ed66
  - kind: registry
    name: windows_i686_gnullvm
    version: 0.53.0
    sha: 9ce6ccbdedbf6d6354471319e781c0dfef054c81fbc7cf83f338a4296c0cae11
  - kind: registry
    name: windows_i686_msvc
    version: 0.52.6
    sha: 240948bc05c5e7c6dabba28bf89d89ffce3e303022809e73deaefe4f6ec56c66
  - kind: registry
    name: windows_i686_msvc
    version: 0.53.0
    sha: 581fee95406bb13382d2f65cd4a908ca7b1e4c2f1917f143ba16efe98a589b5d
  - kind: registry
    name: windows_x86_64_gnu
    version: 0.52.6
    sha: 147a5c80aabfbf0c7d901cb5895d1de30ef2907eb21fbbab29ca94c5b08b1a78
  - kind: registry
    name: windows_x86_64_gnu
    version: 0.53.0
    sha: 2e55b5ac9ea33f2fc1716d1742db15574fd6fc8dadc51caab1c16a3d3b4190ba
  - kind: registry
    name: windows_x86_64_gnullvm
    version: 0.52.6
    sha: 24d5b23dc417412679681396f2b49f3de8c1473deb516bd34410872eff51ed0d
  - kind: registry
    name: windows_x86_64_gnullvm
    version: 0.53.0
    sha: 0a6e035dd0599267ce1ee132e51c27dd29437f63325753051e71dd9e42406c57
  - kind: registry
    name: windows_x86_64_msvc
    version: 0.52.6
    sha: 589f6da84c646204747d1270a2a5661ea66ed1cced2631d546fdfb155959f9ec
  - kind: registry
    name: windows_x86_64_msvc
    version: 0.53.0
    sha: 271414315aff87387382ec3d271b52d7ae78726f5d44ac98b4f4030c91880486
  - kind: registry
    name: winnow
    version: 0.7.12
    sha: f3edebf492c8125044983378ecb5766203ad3b4c2f7a922bd7dd207f6d443e95
  - kind: registry
    name: winping
    version: 0.10.1
    sha: 79ed0e3a789beb896b3de9fb7e93c76340f6f4adfab7770d6222b4b8625ef0aa
  - kind: registry
    name: wit-bindgen-rt
    version: 0.39.0
    sha: 6f42320e61fe2cfd34354ecb597f86f413484a798ba44a8ca1165c58d42da6c1
  - kind: registry
    name: writeable
    version: 0.6.1
    sha: ea2f10b9bb0928dfb1b42b65e1f9e36f7f54dbdf08457afefb38afcdec4fa2bb
  - kind: registry
    name: yoke
    version: 0.8.0
    sha: 5f41bb01b8226ef4bfd589436a297c53d118f65921786300e427be8d487695cc
  - kind: registry
    name: yoke-derive
    version: 0.8.0
    sha: 38da3c9736e16c5d3c8c597a9aaa5d1fa565d0532ae05e27c24aa62fb32c0ab6
  - kind: registry
    name: zerocopy
    version: 0.8.26
    sha: 1039dd0d3c310cf05de012d8a39ff557cb0d23087fd44cad61df08fc31907a2f
  - kind: registry
    name: zerocopy-derive
    version: 0.8.26
    sha: 9ecf5b4cc5364572d7f4c329661bcc82724222973f2cab6f050a4e5c22f75181
  - kind: registry
    name: zerofrom
    version: 0.1.6
    sha: 50cc42e0333e05660c3587f3bf9d0478688e15d870fab3346451ce7f8c9fbea5
  - kind: registry
    name: zerofrom-derive
    version: 0.1.6
    sha: d71e5d6e06ab090c67b5e44993ec16b72dcbaabc526db883a360057678b48502
  - kind: registry
    name: zerotrie
    version: 0.2.2
    sha: 36f0bbd478583f79edad978b407914f61b2972f5af6fa089686016be8f9af595
  - kind: registry
    name: zerovec
    version: 0.11.4
    sha: e7aa2bd55086f1ab526693ecbe444205da57e25f4489879da80635a46d90e73b
  - kind: registry
    name: zerovec-derive
    version: 0.11.1
    sha: 5b96237efa0c878c64bd89c436f661be4e46b2f3eff1ebb976f7ef2321d2f58f
