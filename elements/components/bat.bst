# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

description: Cat clone with syntax highlighting and git integration

build-depends:
- freedesktop-sdk.bst:bootstrap/stripper.bst
- freedesktop-sdk.bst:components/rust.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: github:sharkdp/bat.git
  track: 'v*'
  ref: v0.26.1-0-g979ba22628bc9d8171f2cffca2bd5c90c9fc0a9e
- kind: cargo2
  cargo-lock: Cargo.lock
  ref:
  - kind: registry
    name: adler2
    version: 2.0.0
    sha: 512761e0bb2578dd7380c6baaa0f4ce03e84f95e960231d1dec8bf4d7d6e2627
  - kind: registry
    name: aho-corasick
    version: 1.1.3
    sha: 8e60d3430d3a69478ad0993f19238d2df97c507009a52b3c10addcd7f6bcb916
  - kind: registry
    name: ansi_colours
    version: 1.2.3
    sha: 14eec43e0298190790f41679fe69ef7a829d2a2ddd78c8c00339e84710e435fe
  - kind: registry
    name: anstream
    version: 0.6.18
    sha: 8acc5369981196006228e28809f761875c0327210a891e941f4c683b3a99529b
  - kind: registry
    name: anstyle
    version: 1.0.10
    sha: 55cc3b69f167a1ef2e161439aa98aed94e6028e5f9a59be9a6ffb47aef1651f9
  - kind: registry
    name: anstyle-parse
    version: 0.2.6
    sha: 3b2d16507662817a6a20a9ea92df6652ee4f94f914589377d69f3b21bc5798a9
  - kind: registry
    name: anstyle-query
    version: 1.1.2
    sha: 79947af37f4177cfead1110013d678905c37501914fba0efea834c3fe9a8d60c
  - kind: registry
    name: anstyle-wincon
    version: 3.0.6
    sha: 2109dbce0e72be3ec00bed26e6a7479ca384ad226efdd66db8fa2e3a38c83125
  - kind: registry
    name: anyhow
    version: 1.0.97
    sha: dcfed56ad506cb2c684a14971b8861fdc3baaaae314b9e5f9bb532cbe3ba7a4f
  - kind: registry
    name: assert_cmd
    version: 2.0.16
    sha: dc1835b7f27878de8525dc71410b5a31cdcc5f230aed5ba5df968e09c201b23d
  - kind: registry
    name: autocfg
    version: 1.4.0
    sha: ace50bade8e6234aa140d9a2f552bbee1db4d353f69b8217bc503490fc1a9f26
  - kind: registry
    name: base64
    version: 0.22.1
    sha: 72b3254f16251a8381aa12e40e3c4d2f0199f8c6508fbecb9d91f575e0fbb8c6
  - kind: registry
    name: bincode
    version: 1.3.3
    sha: b1f45e9417d87227c7a56d22e471c6206462cba514c7590c09aff4cf6d1ddcad
  - kind: registry
    name: bit-set
    version: 0.8.0
    sha: 08807e080ed7f9d5433fa9b275196cfc35414f66a0c79d864dc51a0d825231a3
  - kind: registry
    name: bit-vec
    version: 0.8.0
    sha: 5e764a1d40d510daf35e07be9eb06e75770908c27d411ee6c92109c9840eaaf7
  - kind: registry
    name: bitflags
    version: 2.6.0
    sha: b048fb63fd8b5923fc5aa7b340d8e156aec7ec02f0c78fa8a6ddc2613f6f71de
  - kind: registry
    name: bstr
    version: 1.11.3
    sha: 531a9155a481e2ee699d4f98f43c0ca4ff8ee1bfd55c31e9e98fb29d2b176fe0
  - kind: registry
    name: bugreport
    version: 0.5.1
    sha: f280f65ce85b880919349bbfcb204930291251eedcb2e5f84ce2f51df969c162
  - kind: registry
    name: bytemuck
    version: 1.21.0
    sha: ef657dfab802224e671f5818e9a4935f9b1957ed18e58292690cc39e7a4092a3
  - kind: registry
    name: bytesize
    version: 1.3.0
    sha: a3e368af43e418a04d52505cf3dbc23dda4e3407ae2fa99fd0e4f308ce546acc
  - kind: registry
    name: cc
    version: 1.2.7
    sha: a012a0df96dd6d06ba9a1b29d6402d1a5d77c6befd2566afdc26e10603dc93d7
  - kind: registry
    name: cfg-if
    version: 1.0.0
    sha: baf1de4339761588bc0619e3cbc0120ee582ebb74b53b4efbf79117bd2da40fd
  - kind: registry
    name: cfg_aliases
    version: 0.2.1
    sha: 613afe47fcd5fac7ccf1db93babcb082c5994d996f20b8b159f2ad1658eb5724
  - kind: registry
    name: clap
    version: 4.5.46
    sha: 2c5e4fcf9c21d2e544ca1ee9d8552de13019a42aa7dbf32747fa7aaf1df76e57
  - kind: registry
    name: clap_builder
    version: 4.5.46
    sha: fecb53a0e6fcfb055f686001bc2e2592fa527efaf38dbe81a6a9563562e57d41
  - kind: registry
    name: clap_lex
    version: 0.7.4
    sha: f46ad14479a25103f283c0f10005961cf086d8dc42205bb44c46ac563475dca6
  - kind: registry
    name: clircle
    version: 0.6.1
    sha: 7d9334f725b46fb9bed8580b9b47a932587e044fadb344ed7fa98774b067ac1a
  - kind: registry
    name: colorchoice
    version: 1.0.3
    sha: 5b63caa9aa9397e2d9480a9b13673856c78d8ac123288526c37d7839f2a86990
  - kind: registry
    name: console
    version: 0.16.0
    sha: 2e09ced7ebbccb63b4c65413d821f2e00ce54c5ca4514ddc6b3c892fdbcbc69d
  - kind: registry
    name: content_inspector
    version: 0.2.4
    sha: b7bda66e858c683005a53a9a60c69a4aca7eeaa45d124526e389f7aec8e62f38
  - kind: registry
    name: core-foundation-sys
    version: 0.8.7
    sha: 773648b94d0e5d620f64f280777445740e61fe701025087ec8b57f45c791888b
  - kind: registry
    name: crc32fast
    version: 1.4.2
    sha: a97769d94ddab943e4510d138150169a2758b5ef3eb191a9ee688de3e23ef7b3
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
    name: crossterm
    version: 0.27.0
    sha: f476fe445d41c9e991fd07515a6f463074b782242ccf4a5b7b1d1012e70824df
  - kind: registry
    name: crossterm_winapi
    version: 0.9.1
    sha: acdd7c62a3665c7f6830a51635d9ac9b23ed385797f70a83bb8bafe9c572ab2b
  - kind: registry
    name: darling
    version: 0.21.3
    sha: 9cdf337090841a411e2a7f3deb9187445851f91b309c0c0a29e05f74a00a48c0
  - kind: registry
    name: darling_core
    version: 0.21.3
    sha: 1247195ecd7e3c85f83c8d2a366e4210d588e802133e1e355180a9870b517ea4
  - kind: registry
    name: darling_macro
    version: 0.21.3
    sha: d38308df82d1080de0afee5d069fa14b0326a88c14f15c5ccda35b4a6c414c81
  - kind: registry
    name: dashmap
    version: 5.5.3
    sha: 978747c1d849a7d2ee5e8adc0159961c48fb7e5db2f06af6723b80123bb53856
  - kind: registry
    name: deranged
    version: 0.3.11
    sha: b42b6fa04a440b495c8b04d0e71b707c585f83cb9cb28cf8cd0d976c315e31b4
  - kind: registry
    name: difflib
    version: 0.4.0
    sha: 6184e33543162437515c2e2b48714794e37845ec9851711914eec9d308f6ebe8
  - kind: registry
    name: displaydoc
    version: 0.2.5
    sha: 97369cbbc041bc366949bc74d34658d6cda5621039731c6310521892a3a20ae0
  - kind: registry
    name: dissimilar
    version: 1.0.9
    sha: 59f8e79d1fbf76bdfbde321e902714bf6c49df88a7dda6fc682fc2979226962d
  - kind: registry
    name: doc-comment
    version: 0.3.3
    sha: fea41bba32d969b513997752735605054bc0dfa92b4c56bf1189f2e174be7a10
  - kind: registry
    name: either
    version: 1.13.0
    sha: 60b1af1c220855b6ceac025d3f6ecdd2b7c4894bfe9cd9bda4fbb4bc7c0d4cf0
  - kind: registry
    name: encode_unicode
    version: 1.0.0
    sha: 34aa73646ffb006b8f5147f3dc182bd4bcb190227ce861fc4a4844bf8e3cb2c0
  - kind: registry
    name: encoding_rs
    version: 0.8.35
    sha: 75030f3c4f45dafd7586dd6780965a8c7e8e285a5ecb86713e63a79c5b2766f3
  - kind: registry
    name: equivalent
    version: 1.0.1
    sha: 5443807d6dff69373d433ab9ef5378ad8df50ca6298caf15de6e52e24aaf54d5
  - kind: registry
    name: errno
    version: 0.3.10
    sha: 33d852cb9b869c2a9b3df2f71a3074817f01e1844f839a144f5fcef059a4eb5d
  - kind: registry
    name: etcetera
    version: 0.11.0
    sha: de48cc4d1c1d97a20fd819def54b890cadde72ed3ad0c614822a0a433361be96
  - kind: registry
    name: execute
    version: 0.2.13
    sha: 3a82608ee96ce76aeab659e9b8d3c2b787bffd223199af88c674923d861ada10
  - kind: registry
    name: execute-command-macro
    version: 0.1.9
    sha: 90dec53d547564e911dc4ff3ecb726a64cf41a6fa01a2370ebc0d95175dd08bd
  - kind: registry
    name: execute-command-macro-impl
    version: 0.1.10
    sha: ce8cd46a041ad005ab9c71263f9a0ff5b529eac0fe4cc9b4a20f4f0765d8cf4b
  - kind: registry
    name: execute-command-tokens
    version: 0.1.7
    sha: 69dc321eb6be977f44674620ca3aa21703cb20ffbe560e1ae97da08401ffbcad
  - kind: registry
    name: expect-test
    version: 1.5.1
    sha: 63af43ff4431e848fb47472a920f14fa71c24de13255a5692e93d4e90302acb0
  - kind: registry
    name: fancy-regex
    version: 0.16.2
    sha: 998b056554fbe42e03ae0e152895cd1a7e1002aec800fdc6635d20270260c46f
  - kind: registry
    name: fastrand
    version: 2.3.0
    sha: 37909eebbb50d72f9059c3b6d82c0463f2ff062c9e95845c43a6c9c0355411be
  - kind: registry
    name: flate2
    version: 1.1.2
    sha: 4a3d7db9596fecd151c5f638c0ee5d5bd487b6e0ea232e5dc96d5250f6f94b1d
  - kind: registry
    name: float-cmp
    version: 0.10.0
    sha: b09cf3155332e944990140d967ff5eceb70df778b34f77d8075db46e4704e6d8
  - kind: registry
    name: fnv
    version: 1.0.7
    sha: 3f9eec918d3f24069decb9af1554cad7c880e2da24a9afd88aca000531ab82c1
  - kind: registry
    name: form_urlencoded
    version: 1.2.1
    sha: e13624c2627564efccf4934284bdd98cbaa14e79b0b5a141218e507b3a823456
  - kind: registry
    name: generic-array
    version: 1.1.1
    sha: 2cb8bc4c28d15ade99c7e90b219f30da4be5c88e586277e8cbe886beeb868ab2
  - kind: registry
    name: getrandom
    version: 0.3.1
    sha: 43a49c392881ce6d5c3b8cb70f98717b7c07aabbdff06687b9030dbfbe2725f8
  - kind: registry
    name: git-version
    version: 0.3.9
    sha: 1ad568aa3db0fcbc81f2f116137f263d7304f512a1209b35b85150d3ef88ad19
  - kind: registry
    name: git-version-macro
    version: 0.3.9
    sha: 53010ccb100b96a67bc32c0175f0ed1426b31b655d562898e57325f81c023ac0
  - kind: registry
    name: git2
    version: 0.20.2
    sha: 2deb07a133b1520dc1a5690e9bd08950108873d7ed5de38dcc74d3b5ebffa110
  - kind: registry
    name: glob
    version: 0.3.2
    sha: a8d1add55171497b4705a648c6b583acafb01d58050a51727785f0b2c8e0a2b2
  - kind: registry
    name: globset
    version: 0.4.16
    sha: 54a1028dfc5f5df5da8a56a73e6c153c9a9708ec57232470703592a3f18e49f5
  - kind: registry
    name: grep-cli
    version: 0.1.11
    sha: 47f1288f0e06f279f84926fa4c17e3fcd2a22b357927a82f2777f7be26e4cec0
  - kind: registry
    name: hashbrown
    version: 0.14.5
    sha: e5274423e17b7c9fc20b6e7e208532f9b19825d82dfd615708b70edd83df41f1
  - kind: registry
    name: hashbrown
    version: 0.15.2
    sha: bf151400ff0baff5465007dd2f3e717f3fe502074ca563069ce3a6629d07b289
  - kind: registry
    name: icu_collections
    version: 1.5.0
    sha: db2fa452206ebee18c4b5c2274dbf1de17008e874b4dc4f0aea9d01ca79e4526
  - kind: registry
    name: icu_locid
    version: 1.5.0
    sha: 13acbb8371917fc971be86fc8057c41a64b521c184808a698c02acc242dbf637
  - kind: registry
    name: icu_locid_transform
    version: 1.5.0
    sha: 01d11ac35de8e40fdeda00d9e1e9d92525f3f9d887cdd7aa81d727596788b54e
  - kind: registry
    name: icu_locid_transform_data
    version: 1.5.0
    sha: fdc8ff3388f852bede6b579ad4e978ab004f139284d7b28715f773507b946f6e
  - kind: registry
    name: icu_normalizer
    version: 1.5.0
    sha: 19ce3e0da2ec68599d193c93d088142efd7f9c5d6fc9b803774855747dc6a84f
  - kind: registry
    name: icu_normalizer_data
    version: 1.5.0
    sha: f8cafbf7aa791e9b22bec55a167906f9e1215fd475cd22adfcf660e03e989516
  - kind: registry
    name: icu_properties
    version: 1.5.1
    sha: 93d6020766cfc6302c15dbbc9c8778c37e62c14427cb7f6e601d849e092aeef5
  - kind: registry
    name: icu_properties_data
    version: 1.5.0
    sha: 67a8effbc3dd3e4ba1afa8ad918d5684b8868b3b26500753effea8d2eed19569
  - kind: registry
    name: icu_provider
    version: 1.5.0
    sha: 6ed421c8a8ef78d3e2dbc98a973be2f3770cb42b606e3ab18d6237c4dfde68d9
  - kind: registry
    name: icu_provider_macros
    version: 1.5.0
    sha: 1ec89e9337638ecdc08744df490b221a7399bf8d164eb52a665454e60e075ad6
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
    version: 1.2.0
    sha: daca1df1c957320b2cf139ac61e7bd64fed304c5040df000a745aa1de3b4ef71
  - kind: registry
    name: indexmap
    version: 2.8.0
    sha: 3954d50fe15b02142bf25d3b8bdadb634ec3948f103d04ffe3031bc8fe9d7058
  - kind: registry
    name: is_terminal_polyfill
    version: 1.70.1
    sha: 7943c866cc5cd64cbc25b2e01621d07fa8eb2a1a23160ee81ce38704e97b8ecf
  - kind: registry
    name: itertools
    version: 0.14.0
    sha: 2b192c782037fadd9cfa75548310488aabdbf3d2da73885b31bd0abd03351285
  - kind: registry
    name: itoa
    version: 1.0.14
    sha: d75a2a4b1b190afb6f5425f10f6a8f959d2ea0b9c2b1d79553551850539e4674
  - kind: registry
    name: jobserver
    version: 0.1.32
    sha: 48d1dbcbbeb6a7fec7e059840aa538bd62aaccf972c7346c4d9d2059312853d0
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
    version: 1.1.21
    sha: df9b68e50e6e0b26f672573834882eb57759f6db9b3be2ea3c35c91188bb4eaa
  - kind: registry
    name: linked-hash-map
    version: 0.5.6
    sha: 0717cef1bc8b636c6e1c1bbdefc09e6322da8a9321966e8928ef80d20f7f770f
  - kind: registry
    name: linux-raw-sys
    version: 0.4.15
    sha: d26c52dbd32dccf2d10cac7725f8eae5296885fb5703b261f7d0a0739ec807ab
  - kind: registry
    name: litemap
    version: 0.7.4
    sha: 4ee93343901ab17bd981295f2cf0026d4ad018c7c31ba84549a4ddbb47a45104
  - kind: registry
    name: lock_api
    version: 0.4.12
    sha: 07af8b9cdd281b7915f413fa73f29ebd5d55d0d3f0155584dade1ff18cea1b17
  - kind: registry
    name: log
    version: 0.4.22
    sha: a7a70ba024b9dc04c27ea2f0c0548feb474ec5c54bba33a7f72f873a39d07b24
  - kind: registry
    name: memchr
    version: 2.7.4
    sha: 78ca9ab1a0babb1e7d5695e3530886289c18cf2f87ec19a575a0abdce112e3a3
  - kind: registry
    name: miniz_oxide
    version: 0.8.9
    sha: 1fa76a2c86f704bdb222d66965fb3d63269ce38518b83cb0575fca855ebb6316
  - kind: registry
    name: minus
    version: 5.6.1
    sha: 093bd0520d2a37943566a73750e6d44094dac75d66a978d1f0d97ffc78686832
  - kind: registry
    name: mio
    version: 0.8.11
    sha: a4a650543ca06a924e8b371db273b2756685faae30f8487da1b56505a8f78b0c
  - kind: registry
    name: mio
    version: 1.1.0
    sha: 69d83b0086dc8ecf3ce9ae2874b2d1290252e2a30720bea58a5c6639b0092873
  - kind: registry
    name: nix
    version: 0.30.1
    sha: 74523f3a35e05aba87a1d978330aef40f67b0304ac79c1c00b294c9830543db6
  - kind: registry
    name: normalize-line-endings
    version: 0.3.0
    sha: 61807f77802ff30975e01f4f071c8ba10c022052f98b3294119f3e615d13e5be
  - kind: registry
    name: ntapi
    version: 0.4.1
    sha: e8a3895c6391c39d7fe7ebc444a87eb2991b2a0bc718fdabd071eec617fc68e4
  - kind: registry
    name: nu-ansi-term
    version: 0.50.1
    sha: d4a28e057d01f97e61255210fcff094d74ed0466038633e95017f5beb68e4399
  - kind: registry
    name: num-conv
    version: 0.1.0
    sha: 51d515d32fb182ee37cda2ccdcb92950d6a3c2893aa280e540671c2cd0f3b1d9
  - kind: registry
    name: num-traits
    version: 0.2.19
    sha: 071dfc062690e90b734c0b2273ce72ad0ffa95f0c74596bc250dcfd960262841
  - kind: registry
    name: once_cell
    version: 1.20.2
    sha: 1261fe7e33c73b354eab43b1273a57c8f967d0391e80353e51f764ac02cf6775
  - kind: registry
    name: onig
    version: 6.5.1
    sha: 336b9c63443aceef14bea841b899035ae3abe89b7c486aaf4c5bd8aafedac3f0
  - kind: registry
    name: onig_sys
    version: 69.9.1
    sha: c7f86c6eef3d6df15f23bcfb6af487cbd2fed4e5581d58d5bf1f5f8b7f6727dc
  - kind: registry
    name: parking_lot
    version: 0.12.3
    sha: f1bf18183cf54e8d6059647fc3063646a1801cf30896933ec2311622cc4b9a27
  - kind: registry
    name: parking_lot_core
    version: 0.9.10
    sha: 1e401f977ab385c9e4e3ab30627d6f26d00e2c73eef317493c4ec6d468726cf8
  - kind: registry
    name: path_abs
    version: 0.5.1
    sha: 05ef02f6342ac01d8a93b65f96db53fe68a92a15f41144f97fb00a9e669633c3
  - kind: registry
    name: percent-encoding
    version: 2.3.1
    sha: e3148f5046208a5d56bcfc03053e3ca6334e51da8dfb19b6cdc8b306fae3283e
  - kind: registry
    name: pkg-config
    version: 0.3.31
    sha: 953ec861398dccce10c670dfeaf3ec4911ca479e9c02154b3a215178c5f566f2
  - kind: registry
    name: plist
    version: 1.7.0
    sha: 42cf17e9a1800f5f396bc67d193dc9411b59012a5876445ef450d449881e1016
  - kind: registry
    name: powerfmt
    version: 0.2.0
    sha: 439ee305def115ba05938db6eb1644ff94165c5ab5e9420d1c1bcedbba909391
  - kind: registry
    name: predicates
    version: 3.1.3
    sha: a5d19ee57562043d37e82899fade9a22ebab7be9cef5026b07fda9cdd4293573
  - kind: registry
    name: predicates-core
    version: 1.0.9
    sha: 727e462b119fe9c93fd0eb1429a5f7647394014cf3c04ab2c0350eeb09095ffa
  - kind: registry
    name: predicates-tree
    version: 1.0.12
    sha: 72dd2d6d381dfb73a193c7fca536518d7caee39fc8503f74e7dc0be0531b425c
  - kind: registry
    name: prettyplease
    version: 0.2.37
    sha: 479ca8adacdd7ce8f1fb39ce9ecccbfe93a3f1344b3d0d97f20bc0196208f62b
  - kind: registry
    name: proc-macro2
    version: 1.0.95
    sha: 02b3e5e68a3a1a02aad3ec490a98007cbc13c37cbe84a3cd7b8e406d76e7f778
  - kind: registry
    name: quick-xml
    version: 0.32.0
    sha: 1d3a6e5838b60e0e8fa7a43f22ade549a37d61f8bdbe636d0d7816191de969c2
  - kind: registry
    name: quote
    version: 1.0.40
    sha: 1885c039570dc00dcb4ff087a89e185fd56bae234ddc7f056a945bf36467248d
  - kind: registry
    name: rayon
    version: 1.10.0
    sha: b418a60154510ca1a002a752ca9714984e21e4241e804d32555251faf8b78ffa
  - kind: registry
    name: rayon-core
    version: 1.12.1
    sha: 1465873a3dfdaa8ae7cb14b4383657caab0b3e8a0aa9ae8e04b044854c8dfce2
  - kind: registry
    name: redox_syscall
    version: 0.5.8
    sha: 03a862b389f93e68874fbf580b9de08dd02facb9a788ebadaf4a3fd33cf58834
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
    version: 0.8.5
    sha: 2b15c43186be67a4fd63bee50d0303afffcef381492ebe2c5d87f324e1b8815c
  - kind: registry
    name: rgb
    version: 0.8.50
    sha: 57397d16646700483b67d2dd6511d79318f9d057fdbd21a4066aeac8b41d310a
  - kind: registry
    name: rustix
    version: 0.38.43
    sha: a78891ee6bf2340288408954ac787aa063d8e8817e9f53abb37c695c6d834ef6
  - kind: registry
    name: ryu
    version: 1.0.18
    sha: f3cb5ba0dc43242ce17de99c180e96db90b235b8a9fdc9543c96d2209116bd9f
  - kind: registry
    name: same-file
    version: 1.0.6
    sha: 93fc1dc3aaa9bfed95e02e6eadabb4baf7e3078b0bd1b4d7b6b0b68378900502
  - kind: registry
    name: scopeguard
    version: 1.2.0
    sha: 94143f37725109f92c262ed2cf5e59bce7498c01bcc1502d7b9afe439a4e9f49
  - kind: registry
    name: semver
    version: 1.0.25
    sha: f79dfe2d285b0488816f30e700a7438c5a73d816b5b7d3ac72fbc48b0d185e03
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
    version: 1.0.135
    sha: 2b0d7ba2887406110130a978386c4e1befb98c674b4fba677954e4db976630d9
  - kind: registry
    name: serde_spanned
    version: 1.0.0
    sha: 40734c41988f7306bb04f0ecf60ec0f3f1caa34290e4e8ea471dcd3346483b83
  - kind: registry
    name: serde_with
    version: 3.15.1
    sha: aa66c845eee442168b2c8134fec70ac50dc20e760769c8ba0ad1319ca1959b04
  - kind: registry
    name: serde_with_macros
    version: 3.15.1
    sha: b91a903660542fced4e99881aa481bdbaec1634568ee02e0b8bd57c64cb38955
  - kind: registry
    name: serde_yaml
    version: 0.9.34+deprecated
    sha: 6a8b1a1a2ebf674015cc02edccce75287f1a0130d394307b36743c2f5d504b47
  - kind: registry
    name: serial_test
    version: 2.0.0
    sha: 0e56dd856803e253c8f298af3f4d7eb0ae5e23a737252cd90bb4f3b435033b2d
  - kind: registry
    name: serial_test_derive
    version: 2.0.0
    sha: 91d129178576168c589c9ec973feedf7d3126c01ac2bf08795109aa35b69fb8f
  - kind: registry
    name: shell-escape
    version: 0.1.5
    sha: 45bb67a18fa91266cc7807181f62f9178a6873bfad7dc788c42e6430db40184f
  - kind: registry
    name: shell-words
    version: 1.1.0
    sha: 24188a676b6ae68c3b2cb3a01be17fbf7240ce009799bb56d5b1409051e78fde
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
    version: 1.13.2
    sha: 3c5e1a9a646d36c3599cd173a41282daf47c44583ad367b8e6837255952e5c67
  - kind: registry
    name: stable_deref_trait
    version: 1.2.0
    sha: a8f112729512f8e442d81f95a8a7ddf2b7c6b8a1a6f509a95864142b30cab2d3
  - kind: registry
    name: std_prelude
    version: 0.2.12
    sha: 8207e78455ffdf55661170876f88daf85356e4edd54e0a3dbc79586ca1e50cbe
  - kind: registry
    name: strsim
    version: 0.11.1
    sha: 7da8b5736845d9f2fcb837ea5d9e2628564b3b043a70948a3f0b778838c5fb4f
  - kind: registry
    name: syn
    version: 2.0.108
    sha: da58917d35242480a05c2897064da0a80589a2a0476c9a3f2fdc83b53502e917
  - kind: registry
    name: synstructure
    version: 0.13.1
    sha: c8af7666ab7b6390ab78131fb5b0fce11d6b7a6951602017c35fa82800708971
  - kind: registry
    name: syntect
    version: 5.3.0
    sha: 656b45c05d95a5704399aeef6bd0ddec7b2b3531b7c9e900abbf7c4d2190c925
  - kind: registry
    name: sysinfo
    version: 0.33.1
    sha: 4fc858248ea01b66f19d8e8a6d55f41deaf91e9d495246fd01368d99935c6c01
  - kind: registry
    name: tempfile
    version: 3.16.0
    sha: 38c246215d7d24f48ae091a2902398798e05d978b24315d6efbc00ede9a8bb91
  - kind: registry
    name: termcolor
    version: 1.4.1
    sha: 06794f8f6c5c898b3275aebefa6b8a1cb24cd2c6c79397ab15774837a0bc5755
  - kind: registry
    name: terminal-colorsaurus
    version: 1.0.1
    sha: 8909f33134da34b43f69145e748790de650a6abd84faf1f82e773444dd293ec8
  - kind: registry
    name: terminal-trx
    version: 0.2.5
    sha: 662a3cd5ca570df622e848ef18b50c151e65c9835257465417242243b0bce783
  - kind: registry
    name: terminal_size
    version: 0.4.1
    sha: 5352447f921fda68cf61b4101566c0bdb5104eff6804d0678e5227580ab6a4e9
  - kind: registry
    name: termtree
    version: 0.5.1
    sha: 8f50febec83f5ee1df3015341d8bd429f2d1cc62bcba7ea2076759d315084683
  - kind: registry
    name: textwrap
    version: 0.16.2
    sha: c13547615a44dc9c452a8a534638acdf07120d4b6847c8178705da06306a3057
  - kind: registry
    name: thiserror
    version: 1.0.69
    sha: b6aaf5339b578ea85b50e080feb250a3e8ae8cfcdff9a461c9ec2904bc923f52
  - kind: registry
    name: thiserror
    version: 2.0.16
    sha: 3467d614147380f2e4e374161426ff399c91084acd2363eaf549172b3d5e60c0
  - kind: registry
    name: thiserror-impl
    version: 1.0.69
    sha: 4fee6c4efc90059e10f81e6d42c60a18f76588c3d74cb83a0b242a2b6c7504c1
  - kind: registry
    name: thiserror-impl
    version: 2.0.16
    sha: 6c5e1be1c48b9172ee610da68fd9cd2770e7a4056cb3fc98710ee6906f0c7960
  - kind: registry
    name: time
    version: 0.3.37
    sha: 35e7868883861bd0e56d9ac6efcaaca0d6d5d82a2a7ec8209ff492c07cf37b21
  - kind: registry
    name: time-core
    version: 0.1.2
    sha: ef927ca75afb808a4d64dd374f00a2adf8d0fcff8e7b184af886c3c87ec4a3f3
  - kind: registry
    name: time-macros
    version: 0.2.19
    sha: 2834e6017e3e5e4b9834939793b282bc03b37a3336245fa820e35e233e2a85de
  - kind: registry
    name: tinystr
    version: 0.7.6
    sha: 9117f5d4db391c1cf6927e7bea3db74b9a1c1add8f7eda9ffd5364f40f57b82f
  - kind: registry
    name: toml
    version: 0.9.1
    sha: 0207d6ed1852c2a124c1fbec61621acb8330d2bf969a5d0643131e9affd985a5
  - kind: registry
    name: toml_datetime
    version: 0.7.0
    sha: bade1c3e902f58d73d3f294cd7f20391c1cb2fbcb643b73566bc773971df91e3
  - kind: registry
    name: toml_parser
    version: 1.0.0
    sha: b5c1c469eda89749d2230d8156a5969a69ffe0d6d01200581cdc6110674d293e
  - kind: registry
    name: toml_writer
    version: 1.0.0
    sha: b679217f2848de74cabd3e8fc5e6d66f40b7da40f8e1954d92054d9010690fd5
  - kind: registry
    name: typenum
    version: 1.17.0
    sha: 42ff0bf0c66b8238c6f3b578df37d0b7848e55df8577b3f74f92a69acceeb825
  - kind: registry
    name: unicode-ident
    version: 1.0.14
    sha: adb9e6ca4f869e1180728b7950e35922a7fc6397f7b641499e8f3ef06e50dc83
  - kind: registry
    name: unicode-segmentation
    version: 1.12.0
    sha: f6ccf251212114b54433ec949fd6a7841275f9ada20dddd2f29e9ceea4501493
  - kind: registry
    name: unicode-width
    version: 0.2.1
    sha: 4a1a07cc7db3810833284e8d372ccdc6da29741639ecc70c9ec107df0fa6154c
  - kind: registry
    name: unsafe-libyaml
    version: 0.2.11
    sha: 673aac59facbab8a9007c7f6108d11f63b603f7cabff99fabf650fea5c32b861
  - kind: registry
    name: url
    version: 2.5.4
    sha: 32f8b686cadd1473f4bd0117a5d28d36b1ade384ea9b5069a1c40aefed7fda60
  - kind: registry
    name: utf16_iter
    version: 1.0.5
    sha: c8232dd3cdaed5356e0f716d285e4b40b932ac434100fe9b7e0e8e935b9e6246
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
    name: wait-timeout
    version: 0.2.1
    sha: 09ac3b126d3914f9849036f826e054cbabdc8519970b8998ddaf3b5bd3c65f11
  - kind: registry
    name: walkdir
    version: 2.5.0
    sha: 29790946404f91d9c5d06f9874efddea1dc06c5efe94541a7d6863108e3a5e4b
  - kind: registry
    name: wasi
    version: 0.11.0+wasi-snapshot-preview1
    sha: 9c8d87e72b64a3b4db28d11ce29237c246188f4f51057d65a7eab63b7987e423
  - kind: registry
    name: wasi
    version: 0.13.3+wasi-0.2.2
    sha: 26816d2e1a4a36a2940b96c5296ce403917633dff8f3440e9b236ed6f6bacad2
  - kind: registry
    name: wild
    version: 2.2.1
    sha: a3131afc8c575281e1e80f36ed6a092aa502c08b18ed7524e86fbbb12bb410e1
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
    version: 0.1.9
    sha: cf221c93e13a30d793f7645a0e7762c55d169dbb0a49671918a2319d289b10bb
  - kind: registry
    name: winapi-x86_64-pc-windows-gnu
    version: 0.4.0
    sha: 712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f
  - kind: registry
    name: windows
    version: 0.56.0
    sha: 1de69df01bdf1ead2f4ac895dc77c9351aefff65b2f3db429a343f9cbf05e132
  - kind: registry
    name: windows
    version: 0.57.0
    sha: 12342cb4d8e3b046f3d80effd474a7a02447231330ef77d71daa6fbc40681143
  - kind: registry
    name: windows-core
    version: 0.56.0
    sha: 4698e52ed2d08f8658ab0c39512a7c00ee5fe2688c65f8c0a4f06750d729f2a6
  - kind: registry
    name: windows-core
    version: 0.57.0
    sha: d2ed2439a290666cd67ecce2b0ffaad89c2a56b976b736e6ece670297897832d
  - kind: registry
    name: windows-implement
    version: 0.56.0
    sha: f6fc35f58ecd95a9b71c4f2329b911016e6bec66b3f2e6a4aad86bd2e99e2f9b
  - kind: registry
    name: windows-implement
    version: 0.57.0
    sha: 9107ddc059d5b6fbfbffdfa7a7fe3e22a226def0b2608f72e9d552763d3e1ad7
  - kind: registry
    name: windows-interface
    version: 0.56.0
    sha: 08990546bf4edef8f431fa6326e032865f27138718c587dc21bc0265bbcb57cc
  - kind: registry
    name: windows-interface
    version: 0.57.0
    sha: 29bee4b38ea3cde66011baa44dba677c432a78593e202392d1e9070cf2a7fca7
  - kind: registry
    name: windows-link
    version: 0.2.1
    sha: f0805222e57f7521d6a62e36fa9163bc891acd422f971defe97d64e70d0a4fe5
  - kind: registry
    name: windows-result
    version: 0.1.2
    sha: 5e383302e8ec8515204254685643de10811af0ed97ea37210dc26fb0032647f8
  - kind: registry
    name: windows-sys
    version: 0.48.0
    sha: 677d2418bec65e3338edb076e806bc1ec15693c5d0104683f2efe857f61056a9
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
    name: windows-sys
    version: 0.61.2
    sha: ae137229bcbd6cdf0f7b80a31df61766145077ddf49416a728b02cb3921ff3fc
  - kind: registry
    name: windows-targets
    version: 0.48.5
    sha: 9a2fa6e2155d7247be68c096456083145c183cbbbc2764150dda45a87197940c
  - kind: registry
    name: windows-targets
    version: 0.52.6
    sha: 9b724f72796e036ab90c1021d4780d4d3d648aca59e491e6b98e725b84e99973
  - kind: registry
    name: windows-targets
    version: 0.53.2
    sha: c66f69fcc9ce11da9966ddb31a40968cad001c5bedeb5c2b82ede4253ab48aef
  - kind: registry
    name: windows_aarch64_gnullvm
    version: 0.48.5
    sha: 2b38e32f0abccf9987a4e3079dfb67dcd799fb61361e53e2882c3cbaf0d905d8
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
    version: 0.48.5
    sha: dc35310971f3b2dbbf3f0690a219f40e2d9afcf64f9ab7cc1be722937c26b4bc
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
    version: 0.48.5
    sha: a75915e7def60c94dcef72200b9a8e58e5091744960da64ec734a6c6e9b3743e
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
    version: 0.48.5
    sha: 8f55c233f70c4b27f66c523580f78f1004e8b5a8b659e05a4eb49d4166cca406
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
    version: 0.48.5
    sha: 53d40abd2583d23e4718fddf1ebec84dbff8381c07cae67ff7768bbf19c6718e
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
    version: 0.48.5
    sha: 0b7b52767868a23d5bab768e390dc5f5c55825b6d30b86c844ff2dc7414044cc
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
    version: 0.48.5
    sha: ed94fce61571a4006852b7389a063ab983c02eb1bb37b47f8272ce92d06d9538
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
    version: 0.7.11
    sha: 74c7b26e3480b707944fc872477815d29a8e429d2f93a1ce000f5fa84a15cbcd
  - kind: registry
    name: wit-bindgen-rt
    version: 0.33.0
    sha: 3268f3d866458b787f390cf61f4bbb563b922d091359f9608842999eaee3943c
  - kind: registry
    name: write16
    version: 1.0.0
    sha: d1890f4022759daae28ed4fe62859b1236caebfc61ede2f63ed4e695f3f6d936
  - kind: registry
    name: writeable
    version: 0.5.5
    sha: 1e9df38ee2d2c3c5948ea468a8406ff0db0b29ae1ffde1bcf20ef305bcc95c51
  - kind: registry
    name: xterm-color
    version: 1.0.1
    sha: 4de5f056fb9dc8b7908754867544e26145767187aaac5a98495e88ad7cb8a80f
  - kind: registry
    name: yaml-rust
    version: 0.4.5
    sha: 56c1936c4cc7a1c9ab21a1ebb602eb942ba868cbd44a99cb7cdc5892335e1c85
  - kind: registry
    name: yoke
    version: 0.7.5
    sha: 120e6aef9aa629e3d4f52dc8cc43a015c7724194c97dfaf45180d2daf2b77f40
  - kind: registry
    name: yoke-derive
    version: 0.7.5
    sha: 2380878cad4ac9aac1e2435f3eb4020e8374b5f13c296cb75b4620ff8e229154
  - kind: registry
    name: zerofrom
    version: 0.1.5
    sha: cff3ee08c995dee1859d998dea82f7374f2826091dd9cd47def953cae446cd2e
  - kind: registry
    name: zerofrom-derive
    version: 0.1.5
    sha: 595eed982f7d355beb85837f651fa22e90b3c044842dc7f2c2842c086f295808
  - kind: registry
    name: zerovec
    version: 0.10.4
    sha: aa2b893d79df23bfb12d5461018d408ea19dfafe76c2c7ef6d4eba614f8ff079
  - kind: registry
    name: zerovec-derive
    version: 0.10.3
    sha: 6eafa6dfb17584ea3e2bd6e76e0cc15ad7af12b09abdd1ca55961bed9b1063c6
