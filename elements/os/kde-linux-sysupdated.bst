# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

build-depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:components/go.bst

depends:
- kde-linux-packages.bst:kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

environment:
  GOTOOLCHAIN: local
  GOPROXY: 'off'
  GOSUMDB: 'off'

config:
  build-commands:
  - go build -buildmode=pie -trimpath -mod=vendor -buildvcs=false -o kde-linux-sysupdated .
  - go build -buildmode=pie -trimpath -mod=vendor -buildvcs=false -o kde-linux-sysupdated-redirector ./redirector
  - go test -mod=vendor ./...
  install-commands:
  - install -Dm755 -t '%{install-root}/usr/lib' kde-linux-sysupdated kde-linux-sysupdated-redirector
  - install -Dm644 -t '%{install-root}/usr/lib/systemd/system' kde-linux-sysupdated.service kde-linux-sysupdated.socket

sources:
- kind: git_repo
  url: invent:kde-linux/kde-linux-sysupdated.git
  track: master
  ref: ef8cec99758b4914ed2fc6f299fb258a9bfd27b6
- kind: go_mod_vendor
  ref:
  - module: cloud.google.com/go
    version: v0.110.0
    sha256sum: 8bdce0d7bfc07e71cebbbd7df2d93d1418a35eed09211bb21e3c1ee8d2fabf7c
  - module: cloud.google.com/go/compute/metadata
    version: v0.3.0
    sha256sum: c0ab79c30870c1aa9912fb0fdcb043e0044782825988e40f59401d227976b677
  - module: cloud.google.com/go/iam
    version: v0.13.0
    sha256sum: a8236c53eb06cc21c5c972fcfc4153fbce5a44eb7a1b7c88cadc307b8768328a
  - module: cloud.google.com/go/longrunning
    version: v0.4.1
    sha256sum: 6cb4e4a6b80435cb12ab0192ca281893e750f20903cdf5f2432a6d61db190361
  - module: cloud.google.com/go/storage
    version: v1.30.1
    sha256sum: d3702216afe89ee6a768eb302695d8ec64395c30a13fd0dc855acc9e30d4aad8
  - module: github.com/DataDog/zstd
    version: v1.5.2
    sha256sum: 2976a67d8069173797d2d05fb8404d4b99e9efcd6abd9bd469e828e44c49b188
  - module: github.com/acobaugh/osrelease
    version: v0.1.0
    sha256sum: c4bb4828ee72ae6c423a5a1dfb2054307533795228cddc49393e9775a288b129
  - module: github.com/aws/aws-sdk-go
    version: v1.42.4
    sha256sum: 032638f127510e49c9dfc5f25bbc991f33b41cf662039ea095c73b618a66b2d8
  - module: github.com/boljen/go-bitmap
    version: v0.0.0-20151001105940-23cd2fb0ce7d
    sha256sum: ee65d6ec255c8b36649f4fe49c35bd99ceffb4478a6f582fe7334ad47a9e9fbf
  - module: github.com/bytedance/sonic
    version: v1.11.6
    sha256sum: 3b95a18f500ab8ddc5730d162aaaa803a3895242959c6c4c89464516e3efc250
  - module: github.com/bytedance/sonic/loader
    version: v0.1.1
    sha256sum: 71d603db4cb343f03e27f46ab3fbd8e5b59646f6836b31b881ca725c257e0d40
  - module: github.com/cloudwego/base64x
    version: v0.1.4
    sha256sum: de83c0e0db75c0bc8743d02aed3db8f38685dd4481654148e81836f9f5bd2fc1
  - module: github.com/cloudwego/iasm
    version: v0.2.0
    sha256sum: 20f0604b57fd75a6aefe5ac8e807d9ab1fcc8eea0b94c3a69aa5b83f57380b19
  - module: github.com/cobaugh/osrelease
    version: v0.0.0-20211111170140-20e410975bc3
    sha256sum: a98147250d428df6d067c63bb6f30bd047f79735404dffaf792f020f1139c044
  - module: github.com/coreos/go-systemd
    version: v0.0.0-20191104093116-d3cd4ed1dbcf
    sha256sum: ab82b8ae5957cb572d53d1c55fdf2b3349d6049a165ecf7a9a8b34a656c8f888
  - module: github.com/davecgh/go-spew
    version: v1.1.1
    sha256sum: 6b44a843951f371b7010c754ecc3cabefe815d5ced1c5b9409fb2d697e8a890d
  - module: github.com/dchest/siphash
    version: v1.2.3
    sha256sum: 291faeb3d0f046d82357675347523408e456d2a53b11036163d08120f8127566
  - module: github.com/fatih/color
    version: v1.15.0
    sha256sum: 5aa7c7c5e0f12febbeb3f4f57fbca13eabf16caa1cd5a89315e7b8e187652ad9
  - module: github.com/folbricht/desync
    version: v0.9.6
    sha256sum: 2f66819c8cf22965a024893c46b99065d7b92dddd4f21eaeaab1702394c5465c
  - module: github.com/folbricht/tempfile
    version: v0.0.1
    sha256sum: e14036d326c39268700a6b613ff35fa4a9db1791bbf4c542a91c37b7fc259b26
  - module: github.com/fsnotify/fsnotify
    version: v1.9.0
    sha256sum: 94e64824b23591b7aa504e3321d5ec3f57de88f4d49882eaefbbf6820dab746e
  - module: github.com/gabriel-vasile/mimetype
    version: v1.4.3
    sha256sum: cbad487d3bd410db294fe9b95dff68dd9e1e59beb0d4850ca416e13b1cd70faf
  - module: github.com/getsentry/sentry-go
    version: v0.35.0
    sha256sum: 082720bf4effc654745f6f1066741531faffaf1342d519115af8e0d7a4cb8212
  - module: github.com/gin-contrib/sse
    version: v0.1.0
    sha256sum: 512c8672f26405172077e764c4817ed8f66edc632d1bed205b5e1b8d282816ab
  - module: github.com/gin-gonic/gin
    version: v1.10.1
    sha256sum: 9dacb88b9d0f4b9e92b24344bcbb4e8646acaaa13182cbad491063e33061d11b
  - module: github.com/go-errors/errors
    version: v1.4.2
    sha256sum: a5c72ce072cb9532bb8652ed55508ba839e24cda1b49e1ad30187bca852272df
  - module: github.com/go-playground/assert/v2
    version: v2.2.0
    sha256sum: 1d77d82cc5dcdbb7789e93276b37e437b0182be698a1a6558a17d80cb01b859a
  - module: github.com/go-playground/locales
    version: v0.14.1
    sha256sum: f33b53f2eef290d8b43b1011285f1f9cfcb1295c690defcb452598773baace7b
  - module: github.com/go-playground/universal-translator
    version: v0.18.1
    sha256sum: 77fc966f2d045c208ddeaa8343924f83688841b6f4c2ae005dc9ea5550c7d171
  - module: github.com/go-playground/validator/v10
    version: v10.20.0
    sha256sum: dce6b136e5a21f32082a75a083a0e17cafeb8fdbc5457a3c5b965835e8a1f8b1
  - module: github.com/goccy/go-json
    version: v0.10.2
    sha256sum: ed9043ee01cc46557c74bcecc625db37ffe3a5c7af219f390a287f44a40c2520
  - module: github.com/golang/groupcache
    version: v0.0.0-20210331224755-41bb18bfe9da
    sha256sum: b27034e8fc013627543e1ad098cfc65329f2896df3da5cf3266cc9166f93f3a5
  - module: github.com/golang/protobuf
    version: v1.5.3
    sha256sum: 93bda6e88d4a0a493a98b481de67a10000a755d15f16a800b49a6b96d1bd6f81
  - module: github.com/google/go-cmp
    version: v0.6.0
    sha256sum: 4b4e9bf6c48211080651b491dfb48d68b736c66a305bcf94605606e1ba2eaa4a
  - module: github.com/google/martian/v3
    version: v3.3.2
    sha256sum: aa691c18a36d986d0505aab68925985faba03d72e15729ee1b97f919af8e628c
  - module: github.com/google/uuid
    version: v1.3.0
    sha256sum: 0a5fcc05ea492afeaca984a012485f6a15e2259b32f1206d6f36a88c88afc607
  - module: github.com/googleapis/enterprise-certificate-proxy
    version: v0.2.3
    sha256sum: e3a5b32ca7fc4f8bc36274d87c3547975a2b0603b2a1e4b1129530504d9ddeb7
  - module: github.com/googleapis/gax-go/v2
    version: v2.8.0
    sha256sum: 832a15612e71adea2a7ee119ed1295bed08b46618fd68b214e53445fd3e03069
  - module: github.com/hanwen/go-fuse/v2
    version: v2.2.0
    sha256sum: 7379fc5b90850af5f6ab67474c5f62dbff47eeae15f0066b17370a3672678ecc
  - module: github.com/json-iterator/go
    version: v1.1.12
    sha256sum: d001ea57081afd0e378467c8f4a9b6a51259996bb8bb763f78107eaf12f99501
  - module: github.com/klauspost/compress
    version: v1.16.4
    sha256sum: 89f6d7e01111ef97fdfacde82a0f7e69e0e5b34f93148a9a11f75c68fd869a1b
  - module: github.com/klauspost/cpuid/v2
    version: v2.2.7
    sha256sum: 415f9c5ed79ee9b123cf13923a9ab86a34d1f7d417c02b2e00db0d8e34fda037
  - module: github.com/kr/fs
    version: v0.1.0
    sha256sum: d376bd98e81aea34585fc3b04bab76363e9e87cde69383964e57e9779f2af81e
  - module: github.com/kr/pretty
    version: v0.3.0
    sha256sum: 3ac65e185f956d889d77485173fadcc30e959b6bcfdaa8acafaec5f4dac5cd48
  - module: github.com/kr/text
    version: v0.2.0
    sha256sum: 368eb318f91a5b67be905c47032ab5c31a1d49a97848b1011a0d0a2122b30ba4
  - module: github.com/kylelemons/godebug
    version: v0.0.0-20170820004349-d65d576e9348
    sha256sum: f2c96f2332e9d1cb6064bb9d775cddcff450e7f85fe77ec466c72863b25db9ec
  - module: github.com/leodido/go-urn
    version: v1.4.0
    sha256sum: 948fe5f705b9eab6c3bc7e34a3ad2549ead87a8f5f73e5a85a8c66f347612ab2
  - module: github.com/mattn/go-colorable
    version: v0.1.13
    sha256sum: 08be322dcc584a9fcfde5caf0cf878b4e11cd98f252e32bc704e92c5a4ba9d15
  - module: github.com/mattn/go-isatty
    version: v0.0.20
    sha256sum: f2d5f89ca451577e17464b9bb596dc0d0ecececb5eaa63622c41b57cd0b7b8cc
  - module: github.com/mattn/go-runewidth
    version: v0.0.14
    sha256sum: 364ef5ed31f6571dad56730305b5c2288a53da06d9832680ade5e21d97a748e7
  - module: github.com/minio/md5-simd
    version: v1.1.2
    sha256sum: f829d35a6e6897db415af8888c4b074d1a253aee0e8fb7054b4d95477a81c3d6
  - module: github.com/minio/minio-go/v6
    version: v6.0.57
    sha256sum: 590cc247e028de52b92fc54878df7a708704bd29fec20d667dca53134818d02d
  - module: github.com/minio/sha256-simd
    version: v1.0.0
    sha256sum: 62edc1481390c3421ff5a54b80c49acab85331348124d560a5e410074d19c3e5
  - module: github.com/mitchellh/go-homedir
    version: v1.1.0
    sha256sum: fffec361fc7e776bb71433560c285ee2982d2c140b8f5bfba0db6033c0ade184
  - module: github.com/modern-go/concurrent
    version: v0.0.0-20180306012644-bacd9c7ef1dd
    sha256sum: 91ef49599bec459869d94ff3dec128871ab66bd2dfa61041f1e1169f9b4a8073
  - module: github.com/modern-go/reflect2
    version: v1.0.2
    sha256sum: f46f41409c2e74293f82cfe6c70b5d582bff8ada0106a7d3ff5706520c50c21c
  - module: github.com/pelletier/go-toml/v2
    version: v2.2.2
    sha256sum: 8d724e35b485503810f866bca278d518e731713441e380634f6b33c27aefdf3e
  - module: github.com/pingcap/errors
    version: v0.11.4
    sha256sum: df62e548162429501a88d936a3e8330f2379ddfcd4d23c22b78bc1b157e05b97
  - module: github.com/pkg/errors
    version: v0.9.1
    sha256sum: d4c36b8bcd0616290a3913215e0f53b931bd6e00670596f2960df1b44af2bd07
  - module: github.com/pkg/sftp
    version: v1.13.5
    sha256sum: 16dd30372f347f270d4afa26e34cdd666c584247c683659e6e54709027d9c28a
  - module: github.com/pkg/xattr
    version: v0.4.9
    sha256sum: 03aa1ce578e02548201e7099bd53bd18a56d8cd7ae44bb7d8ab9457a5fb34b06
  - module: github.com/pmezard/go-difflib
    version: v1.0.0
    sha256sum: de04cecc1a4b8d53e4357051026794bcbc54f2e6a260cfac508ce69d5d6457a0
  - module: github.com/rivo/uniseg
    version: v0.2.0
    sha256sum: 3199d94be50284142220662ca3b00e19ddd1debe4e80ddc745ff4203ecb601c0
  - module: github.com/rogpeppe/go-internal
    version: v1.8.0
    sha256sum: 23748dd2311c9a8601ee1c33161519c7a025e06987d164cef7377785c7bb00c9
  - module: github.com/sirupsen/logrus
    version: v1.9.0
    sha256sum: bf01c93f49912b88ee2e95dc99cab91a503ec3b526d1c756145391d555b98d14
  - module: github.com/spatialcurrent/go-lazy
    version: v0.0.0-20211115014721-47315cc003d1
    sha256sum: 7a5b3f5e7b97e090f1318b973ac63adb2abe939de1ae4c1505db7deeddb6f287
  - module: github.com/stretchr/testify
    version: v1.12.1
    sha256sum: 6874ed1c4b0b7e9feb27989b16c179b36590020633436ae260cefc5f5565589f
  - module: github.com/twitchyliquid64/golang-asm
    version: v0.15.1
    sha256sum: 448f87fb680adda839b60bbaa0b371c28f99f3928dea7a069f42800e5100018d
  - module: github.com/ugorji/go/codec
    version: v1.2.12
    sha256sum: ca38b5b9f58e33de24f88ac2505e2c67f2b454d09d929228a10b938bddda848d
  - module: go.opencensus.io
    version: v0.24.0
    sha256sum: 203a767d7f8e7c1ebe5588220ad168d1e15b14ae70a636de7ca9a4a88a7e0d0c
  - module: go.uber.org/goleak
    version: v1.3.0
    sha256sum: 70edef0ce7d830d992f024e527fd3452069b884f94a27787a718bd68dd620702
  - module: go.yaml.in/yaml/v3
    version: v3.0.5
    sha256sum: f2d70caa35f66283aec58b889af8c5f07c374c5934be27a738c1215263e19205
  - module: golang.org/x/arch
    version: v0.8.0
    sha256sum: 59a1c7d2d9ab004ae45afeb5b0443c7b5e22c0b73f2b00dc625140b0a2e8306d
  - module: golang.org/x/crypto
    version: v0.41.0
    sha256sum: 7da981b09d79d021f79ea2953637a85e3c72e43fc88b6a3230e7976fbbeec2de
  - module: golang.org/x/net
    version: v0.43.0
    sha256sum: 24d4f49b7e781763942533d5a5acc49ebd054e05c50bf4402b264695ef8d10c5
  - module: golang.org/x/oauth2
    version: v0.27.0
    sha256sum: 3d90c61cc10984c81b5d605c0ebd3be61b34b62c4aeba92c11fc86d1fade635a
  - module: golang.org/x/sync
    version: v0.16.0
    sha256sum: ca43984183eb14f7f50d33da350312fed1c42e106dceac2437bfd5084b497dcd
  - module: golang.org/x/sys
    version: v0.35.0
    sha256sum: dc3c20611168aaa8fda0d71999be1a5222a0ba57bc767c978a590e41ff2ede35
  - module: golang.org/x/term
    version: v0.34.0
    sha256sum: 22281cbf30560433d57de8d72c1151f9cac2917795dc6e9f694f7a525bb5309c
  - module: golang.org/x/text
    version: v0.28.0
    sha256sum: 46259e1416ae7ec6adf1867c5f9fab32af0476a148e3c95f1dfbb134f4acf48d
  - module: golang.org/x/xerrors
    version: v0.0.0-20220907171357-04be3eba64a2
    sha256sum: b9c481db33c4b682ba8ba348018ddbd2155bd227cc38ff9f6b4cb2b74bbc3c14
  - module: google.golang.org/api
    version: v0.116.0
    sha256sum: 14fceb8918d474d1d1cae9ae4fd5be99636aae6bb90557e34bb019f63f9b9e2b
  - module: google.golang.org/appengine
    version: v1.6.7
    sha256sum: 79f80dfac18681788f1414e21a4a7734eff4cdf992070be9163103eb8d9f92cd
  - module: google.golang.org/genproto
    version: v0.0.0-20230410155749-daa745c078e1
    sha256sum: 28f0317e6948788a33c07698109005675062f0203ed06bc866350a575bc974bf
  - module: google.golang.org/grpc
    version: v1.56.3
    sha256sum: 7f9b83cd9dbe99783061160583dae09dd8f64187d890c51be52cc8e3bd0dcb56
  - module: google.golang.org/protobuf
    version: v1.34.1
    sha256sum: b5987adbf21a6cbe6463ea795c320b700537d5dbb6f3e2aa3ffaf226cedf476b
  - module: gopkg.in/check.v1
    version: v1.0.0-20201130134442-10cb98267c6c
    sha256sum: f555684e5c5dacc2850dddb345fef1b8f93f546b72685589789da6d2b062710e
  - module: gopkg.in/cheggaaa/pb.v1
    version: v1.0.28
    sha256sum: 39725f9f37aac44dd55bdc9ade65a2d066953a090456298d34203257fc7e8ee9
  - module: gopkg.in/ini.v1
    version: v1.67.0
    sha256sum: bd845dfc762a87a56e5a32a07770dc83e86976db7705d7f89c5dbafdc60b06c6
  - module: gopkg.in/yaml.v3
    version: v3.0.1
    sha256sum: aab8fbc4e6300ea08e6afe1caea18a21c90c79f489f52c53e2f20431f1a9a015
