# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

# Inspired by ArchLinux's PKGBUILD: https://gitlab.archlinux.org/archlinux/packaging/packages/udev-hid-bpf/-/raw/main/PKGBUILD?ref_type=heads
kind: meson

description: An automatic HID-BPF loader based on udev events written in rust

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:bootstrap/linux-headers.bst
- freedesktop-sdk.bst:components/systemd-libs.bst
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:components/_private/bpf.bst # for bpftool

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libbpf.bst
- freedesktop-sdk.bst:components/systemd-libs.bst

environment:
  PATH: '%{build-root}/.packaging-bin:/usr/bin:/bin'

config:
  configure-commands:
    (<):
    - |
      mkdir -p "%{build-root}/.packaging-bin"
      cat > "%{build-root}/.packaging-bin/gcc" <<EOF
      #!/bin/sh
      if [ "\$#" -eq 1 ] && [ "\$1" = "-dumpmachine" ]; then
        echo "%{gcc_triplet}"
        exit 0
      fi
      exec /usr/bin/gcc "\$@"
      EOF
      chmod +x "%{build-root}/.packaging-bin/gcc"

sources:
- kind: tar
  url: fdo:libevdev/udev-hid-bpf/-/archive/2.2.0-20251121/udev-hid-bpf-2.2.0-20251121.tar.gz
  ref: fbf21cbbcc81746fdeefa15259d46abcb28f8daaf70ec2af920b68cca8b44a95
- kind: cargo2
  cargo-lock: Cargo.lock
  ref:
  - kind: registry
    name: aho-corasick
    version: 1.1.3
    sha: 8e60d3430d3a69478ad0993f19238d2df97c507009a52b3c10addcd7f6bcb916
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
    version: 1.0.13
    sha: 5192cca8006f1fd4f7237516f40fa183bb07f8fbdfedaa0036de5ea9b0b45e78
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
    version: 1.0.100
    sha: a23eb6b1614318a8071c9b2521f36b424b2c83db5eb3a0fead4a6c0809af6e61
  - kind: registry
    name: atty
    version: 0.2.14
    sha: d9b39be18770d11421cdb1b9947a45dd3f37e93092cbf377614828a319d5fee8
  - kind: registry
    name: autocfg
    version: 1.5.0
    sha: c08606f8c3cbf4ce6ec8e28fb0014a2c086708fe954eaa885384a6165172e7e8
  - kind: registry
    name: bitflags
    version: 2.9.4
    sha: 2261d10cca569e4643e526d8dc2e62e433cc8aba21ab764233731f8d369bf394
  - kind: registry
    name: bumpalo
    version: 3.19.0
    sha: 46c5e41b57b8bba42a04676d81cb89e9ee8e859a1a66f80a5a72e1cb76b34d43
  - kind: registry
    name: camino
    version: 1.2.1
    sha: 276a59bf2b2c967788139340c9f0c5b12d7fd6630315c15c217e559de85d2609
  - kind: registry
    name: cargo-platform
    version: 0.1.9
    sha: e35af189006b9c0f00a064685c727031e3ed2d8020f7ba284d78cc2671bd36ea
  - kind: registry
    name: cargo_metadata
    version: 0.15.4
    sha: eee4243f1f26fc7a42710e7439c149e2b10b05472f88090acce52632f231a73a
  - kind: registry
    name: cc
    version: 1.2.39
    sha: e1354349954c6fc9cb0deab020f27f783cf0b604e8bb754dc4658ecf0d29c35f
  - kind: registry
    name: cfg-if
    version: 1.0.3
    sha: 2fd1289c04a9ea8cb22300a459a72a385d7c73d3259e2ed7dcb2af674838cfa9
  - kind: registry
    name: cfg_aliases
    version: 0.2.1
    sha: 613afe47fcd5fac7ccf1db93babcb082c5994d996f20b8b159f2ad1658eb5724
  - kind: registry
    name: chrono
    version: 0.4.42
    sha: 145052bdd345b87320e369255277e3fb5152762ad123a901ef5c262dd38fe8d2
  - kind: registry
    name: clap
    version: 4.5.48
    sha: e2134bb3ea021b78629caa971416385309e0131b351b25e01dc16fb54e1b5fae
  - kind: registry
    name: clap_builder
    version: 4.5.48
    sha: c2ba64afa3c0a6df7fa517765e31314e983f51dda798ffba27b988194fb65dc9
  - kind: registry
    name: clap_derive
    version: 4.5.47
    sha: bbfd7eae0b0f1a6e63d4b13c9c478de77c2eb546fba158ad50b4203dc24b9f9c
  - kind: registry
    name: clap_lex
    version: 0.7.5
    sha: b94f61472cee1439c0b966b47e3aca9ae07e45d070759512cd390ea2bebc6675
  - kind: registry
    name: colorchoice
    version: 1.0.4
    sha: b05b61dc5112cbb17e4b6cd61790d9845d13888356391624cbe7e41efeac1e75
  - kind: registry
    name: core-foundation-sys
    version: 0.8.7
    sha: 773648b94d0e5d620f64f280777445740e61fe701025087ec8b57f45c791888b
  - kind: registry
    name: errno
    version: 0.3.14
    sha: 39cab71617ae0d63f51a36d69f866391735b51691dbda63cf6f96d042b63efeb
  - kind: registry
    name: fastrand
    version: 2.3.0
    sha: 37909eebbb50d72f9059c3b6d82c0463f2ff062c9e95845c43a6c9c0355411be
  - kind: registry
    name: find-msvc-tools
    version: 0.1.2
    sha: 1ced73b1dacfc750a6db6c0a0c3a3853c8b41997e2e2c563dc90804ae6867959
  - kind: registry
    name: getrandom
    version: 0.3.3
    sha: 26145e563e54f2cadc477553f1ec5ee650b00862f0a58bcd12cbdc5f0ea2d2f4
  - kind: registry
    name: heck
    version: 0.5.0
    sha: 2304e00983f87ffb38b55b444b5e3b60a884b5d30c0fca7d82fe33449bbe55ea
  - kind: registry
    name: hermit-abi
    version: 0.1.19
    sha: 62b467343b94ba476dcb2500d242dadbb39557df889310ac77c5d99100aaac33
  - kind: registry
    name: iana-time-zone
    version: 0.1.64
    sha: 33e57f83510bb73707521ebaffa789ec8caf86f9657cad665b092b581d40e9fb
  - kind: registry
    name: iana-time-zone-haiku
    version: 0.1.2
    sha: f31827a206f56af32e590ba56d5d2d085f558508192593743f16b2306495269f
  - kind: registry
    name: is_terminal_polyfill
    version: 1.70.1
    sha: 7943c866cc5cd64cbc25b2e01621d07fa8eb2a1a23160ee81ce38704e97b8ecf
  - kind: registry
    name: itoa
    version: 1.0.15
    sha: 4a5f13b858c8d314ee3e8f639011f7ccefe71f97f96e50151fb991f267928e2c
  - kind: registry
    name: js-sys
    version: 0.3.81
    sha: ec48937a97411dcb524a265206ccd4c90bb711fca92b2792c407f268825b9305
  - kind: registry
    name: libbpf-cargo
    version: 0.24.8
    sha: 704727a07f185a76c58faa7b8ed08fba3194661c212183aea1174fe2970ee185
  - kind: registry
    name: libbpf-rs
    version: 0.24.8
    sha: 93edd9cd673087fa7518fd63ad6c87be2cd9b4e35034b1873f3e3258c018275b
  - kind: registry
    name: libbpf-rs
    version: 0.25.0
    sha: e23d252d93e246c8787198369f06806c99c5077b5295be29505295f4e5426dc4
  - kind: registry
    name: libbpf-sys
    version: 1.6.1+v1.6.1
    sha: e351855cbd724ac341b2a1c163568808e72acd930c491a921331c2e5347390d3
  - kind: registry
    name: libc
    version: 0.2.176
    sha: 58f929b4d672ea937a23a1ab494143d968337a5f47e56d0815df1e0890ddf174
  - kind: registry
    name: libudev-sys
    version: 0.1.4
    sha: 3c8469b4a23b962c1396b9b451dda50ef5b283e8dd309d69033475fa9b334324
  - kind: registry
    name: linux-raw-sys
    version: 0.11.0
    sha: df1d3c3b53da64cf5760482273a98e575c651a67eec7f77df96b5b642de8f039
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
    version: 0.5.10
    sha: 83faa42c0a078c393f6b29d5db232d8be22776a891f8f56e5284faee4a20b327
  - kind: registry
    name: mio
    version: 0.8.11
    sha: a4a650543ca06a924e8b371db273b2756685faae30f8487da1b56505a8f78b0c
  - kind: registry
    name: nix
    version: 0.30.1
    sha: 74523f3a35e05aba87a1d978330aef40f67b0304ac79c1c00b294c9830543db6
  - kind: registry
    name: num-traits
    version: 0.2.19
    sha: 071dfc062690e90b734c0b2273ce72ad0ffa95f0c74596bc250dcfd960262841
  - kind: registry
    name: once_cell
    version: 1.21.3
    sha: 42f5e15c9953c5e4ccceeb2e7382a716482c34515315f7b03532b8b4e8393d2d
  - kind: registry
    name: once_cell_polyfill
    version: 1.70.1
    sha: a4895175b425cb1f87721b59f0f286c2092bd4af812243672510e1ac53e2e0ad
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
    version: 1.11.3
    sha: 8b5288124840bee7b386bc413c487869b360b2b4ec421ea56425128692f2a82c
  - kind: registry
    name: regex-automata
    version: 0.4.11
    sha: 833eb9ce86d40ef33cb1306d8accf7bc8ec2bfea4355cbdebb3df68b40925cad
  - kind: registry
    name: regex-syntax
    version: 0.8.6
    sha: caf4aa5b0f434c91fe5c7f1ecb6a5ece2130b02ad2a590589dda5146df959001
  - kind: registry
    name: rustix
    version: 1.1.2
    sha: cd15f8a2c5551a84d56efdc1cd049089e409ac19a3072d5037a17fd70719ff3e
  - kind: registry
    name: rustversion
    version: 1.0.22
    sha: b39cdef0fa800fc44525c84ccb54a029961a8215f9619753635a9c0d2538d46d
  - kind: registry
    name: ryu
    version: 1.0.20
    sha: 28d3b2b1366ec20994f1fd18c3c594f05c5dd4bc44d8bb0c1c632c8d6829481f
  - kind: registry
    name: semver
    version: 1.0.27
    sha: d767eb0aabc880b29956c35734170f26ed551a859dbd361d140cdbeca61ab1e2
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
    name: stderrlog
    version: 0.5.4
    sha: 69a26bbf6de627d389164afa9783739b56746c6c72c4ed16539f4ff54170327b
  - kind: registry
    name: strsim
    version: 0.11.1
    sha: 7da8b5736845d9f2fcb837ea5d9e2628564b3b043a70948a3f0b778838c5fb4f
  - kind: registry
    name: syn
    version: 2.0.106
    sha: ede7c438028d4436d71104916910f5bb611972c5cfd7f89b8300a8186e6fada6
  - kind: registry
    name: tempfile
    version: 3.23.0
    sha: 2d31c77bdf42a745371d260a26ca7163f1e0924b64afa0b688e61b5a9fa02f16
  - kind: registry
    name: termcolor
    version: 1.1.3
    sha: bab24d30b911b2376f3a13cc2cd443142f0c81dda04c118693e35b3835757755
  - kind: registry
    name: thiserror
    version: 1.0.69
    sha: b6aaf5339b578ea85b50e080feb250a3e8ae8cfcdff9a461c9ec2904bc923f52
  - kind: registry
    name: thiserror-impl
    version: 1.0.69
    sha: 4fee6c4efc90059e10f81e6d42c60a18f76588c3d74cb83a0b242a2b6c7504c1
  - kind: registry
    name: thread_local
    version: 1.1.9
    sha: f60246a4944f24f6e018aa17cdeffb7818b76356965d03b07d6a9886e8962185
  - kind: registry
    name: udev
    version: 0.7.0
    sha: 4ebdbbd670373442a12fe9ef7aeb53aec4147a5a27a00bbc3ab639f08f48191a
  - kind: registry
    name: unicode-ident
    version: 1.0.19
    sha: f63a545481291138910575129486daeaf8ac54aee4387fe7906919f7830c7d9d
  - kind: registry
    name: utf8parse
    version: 0.2.2
    sha: 06abde3611657adf66d383f00b093d7faecc7fa57071cce2578660c9f1010821
  - kind: registry
    name: vsprintf
    version: 2.0.0
    sha: aec2f81b75ca063294776b4f7e8da71d1d5ae81c2b1b149c8d89969230265d63
  - kind: registry
    name: wasi
    version: 0.11.1+wasi-snapshot-preview1
    sha: ccf3ec651a847eb01de73ccad15eb7d99f80485de043efb2f370cd654f4ea44b
  - kind: registry
    name: wasi
    version: 0.14.7+wasi-0.2.4
    sha: 883478de20367e224c0090af9cf5f9fa85bed63a95c1abf3afc5c083ebc06e8c
  - kind: registry
    name: wasip2
    version: 1.0.1+wasi-0.2.4
    sha: 0562428422c63773dad2c345a1882263bbf4d65cf3f42e90921f787ef5ad58e7
  - kind: registry
    name: wasm-bindgen
    version: 0.2.104
    sha: c1da10c01ae9f1ae40cbfac0bac3b1e724b320abfcf52229f80b547c0d250e2d
  - kind: registry
    name: wasm-bindgen-backend
    version: 0.2.104
    sha: 671c9a5a66f49d8a47345ab942e2cb93c7d1d0339065d4f8139c486121b43b19
  - kind: registry
    name: wasm-bindgen-macro
    version: 0.2.104
    sha: 7ca60477e4c59f5f2986c50191cd972e3a50d8a95603bc9434501cf156a9a119
  - kind: registry
    name: wasm-bindgen-macro-support
    version: 0.2.104
    sha: 9f07d2f20d4da7b26400c9f4a0511e6e0345b040694e8a75bd41d578fa4421d7
  - kind: registry
    name: wasm-bindgen-shared
    version: 0.2.104
    sha: bad67dc8b2a1a6e5448428adec4c3e84c43e561d8c9ee8a9e5aabeb193ec41d1
  - kind: registry
    name: winapi
    version: 0.3.9
    sha: 5c839a674fcd7a98952e593242ea400abe93992746761e38641405d28b00f419
  - kind: registry
    name: winapi-i686-pc-windows-gnu
    version: 0.4.0
    sha: ac3b87c63620426dd9b991e5ce0329eff545bccbbb34f3be09ff6fb6ab51b7b6
  - kind: registry
    name: winapi-util
    version: 0.1.11
    sha: c2a7b1c03c876122aa43f3020e6c3c3ee5c05081c9a00739faf7503aeba10d22
  - kind: registry
    name: winapi-x86_64-pc-windows-gnu
    version: 0.4.0
    sha: 712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f
  - kind: registry
    name: windows-core
    version: 0.62.1
    sha: 6844ee5416b285084d3d3fffd743b925a6c9385455f64f6d4fa3031c4c2749a9
  - kind: registry
    name: windows-implement
    version: 0.60.1
    sha: edb307e42a74fb6de9bf3a02d9712678b22399c87e6fa869d6dfcd8c1b7754e0
  - kind: registry
    name: windows-interface
    version: 0.59.2
    sha: c0abd1ddbc6964ac14db11c7213d6532ef34bd9aa042c2e5935f59d7908b46a5
  - kind: registry
    name: windows-link
    version: 0.2.0
    sha: 45e46c0661abb7180e7b9c281db115305d49ca1709ab8242adf09666d2173c65
  - kind: registry
    name: windows-result
    version: 0.4.0
    sha: 7084dcc306f89883455a206237404d3eaf961e5bd7e0f312f7c91f57eb44167f
  - kind: registry
    name: windows-strings
    version: 0.5.0
    sha: 7218c655a553b0bed4426cf54b20d7ba363ef543b52d515b3e48d7fd55318dda
  - kind: registry
    name: windows-sys
    version: 0.48.0
    sha: 677d2418bec65e3338edb076e806bc1ec15693c5d0104683f2efe857f61056a9
  - kind: registry
    name: windows-sys
    version: 0.60.2
    sha: f2f500e4d28234f72040990ec9d39e3a6b950f9f22d3dba18416c35882612bcb
  - kind: registry
    name: windows-sys
    version: 0.61.1
    sha: 6f109e41dd4a3c848907eb83d5a42ea98b3769495597450cf6d153507b166f0f
  - kind: registry
    name: windows-targets
    version: 0.48.5
    sha: 9a2fa6e2155d7247be68c096456083145c183cbbbc2764150dda45a87197940c
  - kind: registry
    name: windows-targets
    version: 0.53.4
    sha: 2d42b7b7f66d2a06854650af09cfdf8713e427a439c97ad65a6375318033ac4b
  - kind: registry
    name: windows_aarch64_gnullvm
    version: 0.48.5
    sha: 2b38e32f0abccf9987a4e3079dfb67dcd799fb61361e53e2882c3cbaf0d905d8
  - kind: registry
    name: windows_aarch64_gnullvm
    version: 0.53.0
    sha: 86b8d5f90ddd19cb4a147a5fa63ca848db3df085e25fee3cc10b39b6eebae764
  - kind: registry
    name: windows_aarch64_msvc
    version: 0.48.5
    sha: dc35310971f3b2dbbf3f0690a219f40e2d9afcf64f9ab7cc1be722937c26b4bc
  - kind: registry
    name: windows_aarch64_msvc
    version: 0.53.0
    sha: c7651a1f62a11b8cbd5e0d42526e55f2c99886c77e007179efff86c2b137e66c
  - kind: registry
    name: windows_i686_gnu
    version: 0.48.5
    sha: a75915e7def60c94dcef72200b9a8e58e5091744960da64ec734a6c6e9b3743e
  - kind: registry
    name: windows_i686_gnu
    version: 0.53.0
    sha: c1dc67659d35f387f5f6c479dc4e28f1d4bb90ddd1a5d3da2e5d97b42d6272c3
  - kind: registry
    name: windows_i686_gnullvm
    version: 0.53.0
    sha: 9ce6ccbdedbf6d6354471319e781c0dfef054c81fbc7cf83f338a4296c0cae11
  - kind: registry
    name: windows_i686_msvc
    version: 0.48.5
    sha: 8f55c233f70c4b27f66c523580f78f1004e8b5a8b659e05a4eb49d4166cca406
  - kind: registry
    name: windows_i686_msvc
    version: 0.53.0
    sha: 581fee95406bb13382d2f65cd4a908ca7b1e4c2f1917f143ba16efe98a589b5d
  - kind: registry
    name: windows_x86_64_gnu
    version: 0.48.5
    sha: 53d40abd2583d23e4718fddf1ebec84dbff8381c07cae67ff7768bbf19c6718e
  - kind: registry
    name: windows_x86_64_gnu
    version: 0.53.0
    sha: 2e55b5ac9ea33f2fc1716d1742db15574fd6fc8dadc51caab1c16a3d3b4190ba
  - kind: registry
    name: windows_x86_64_gnullvm
    version: 0.48.5
    sha: 0b7b52767868a23d5bab768e390dc5f5c55825b6d30b86c844ff2dc7414044cc
  - kind: registry
    name: windows_x86_64_gnullvm
    version: 0.53.0
    sha: 0a6e035dd0599267ce1ee132e51c27dd29437f63325753051e71dd9e42406c57
  - kind: registry
    name: windows_x86_64_msvc
    version: 0.48.5
    sha: ed94fce61571a4006852b7389a063ab983c02eb1bb37b47f8272ce92d06d9538
  - kind: registry
    name: windows_x86_64_msvc
    version: 0.53.0
    sha: 271414315aff87387382ec3d271b52d7ae78726f5d44ac98b4f4030c91880486
  - kind: registry
    name: wit-bindgen
    version: 0.46.0
    sha: f17a85883d4e6d00e8a97c586de764dabcc06133f7f1d55dce5cdc070ad7fe59
