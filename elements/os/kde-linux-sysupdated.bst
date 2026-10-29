# SPDX-FileCopyrightText: 2026 Aleix Pol Gonzalez <aleixpol@kde.org>
# SPDX-License-Identifier: BSD-2-Clause

kind: manual

build-depends:
- kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- kde-buildstream.bst:freedesktop-sdk.bst:components/go.bst

depends:
- kde-buildstream.bst:freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

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
- kind: go_module
  url: https://github.com/cobaugh/osrelease.git
  module: github.com/cobaugh/osrelease
  ref:
    go-version: v0.0.0-20211111170140-20e410975bc3
    git-ref: 20e410975bc31e17b690ec326405b8ef0087a55c
- kind: go_module
  url: https://github.com/coreos/go-systemd.git
  module: github.com/coreos/go-systemd
  ref:
    go-version: v0.0.0-20191104093116-d3cd4ed1dbcf
    git-ref: d3cd4ed1dbcf5835feba465b180436db54f20228
- kind: go_module
  url: https://github.com/folbricht/desync.git
  module: github.com/folbricht/desync
  ref:
    go-version: v0.9.6
    git-ref: v0.9.6-0-g0aef76def97e1aa148d58b8a831f7c89b41ba9c4
- kind: go_module
  url: https://github.com/getsentry/sentry-go.git
  module: github.com/getsentry/sentry-go
  ref:
    go-version: v0.35.0
    git-ref: v0.35.0-0-ga3e3405def544188c1fb81f2d55a2537438b7a8e
- kind: go_module
  url: https://github.com/gin-gonic/gin.git
  module: github.com/gin-gonic/gin
  ref:
    go-version: v1.10.1
    git-ref: v1.10.1-0-gb5af7796535d97d9c7af42539af01d787fcb3b4d
- kind: go_module
  url: https://github.com/sirupsen/logrus.git
  module: github.com/sirupsen/logrus
  ref:
    go-version: v1.9.0
    git-ref: v1.9.0-0-gf8bf7650dccb756cea26edaf9217aab85500fe07
- kind: go_module
  url: https://github.com/spatialcurrent/go-lazy.git
  module: github.com/spatialcurrent/go-lazy
  ref:
    go-version: v0.0.0-20211115014721-47315cc003d1
    git-ref: 47315cc003d10616c654c75aafa660c705aa8aa5
- kind: go_module
  url: https://go.googlesource.com/sync.git
  module: golang.org/x/sync
  ref:
    go-version: v0.16.0
    git-ref: v0.16.0-0-g7fad2c9213e0821bd78435a9c106806f2fc383f1
- kind: go_module
  url: https://gopkg.in/yaml.v3.git
  module: gopkg.in/yaml.v3
  ref:
    go-version: v3.0.1
    git-ref: v3.0.1-0-gf6f7691b1fdeb513f56608cd2c32c51f8194bf51
- kind: go_module
  url: https://github.com/googleapis/google-cloud-go.git
  module: cloud.google.com/go
  ref:
    go-version: v0.110.0
    git-ref: v0.110.0-0-gb4d0ff0e4e7be0f8048416f13db56d1c7bb6bec0
- kind: go_module
  url: https://github.com/googleapis/google-cloud-go.git
  module: cloud.google.com/go/compute/metadata
  ref:
    go-version: v0.3.0
    git-ref: compute/metadata/v0.3.0-0-gb952f41fc832fbe5ed74f47ae0e6d6f2e93448e0
    subdirectory: compute/metadata
- kind: go_module
  url: https://github.com/googleapis/google-cloud-go.git
  module: cloud.google.com/go/iam
  ref:
    go-version: v0.13.0
    git-ref: iam/v0.13.0-0-gc2bf628da9b4f30df75608ffa77c2fb8d6a6cf8d
    subdirectory: iam
- kind: go_module
  url: https://github.com/googleapis/google-cloud-go.git
  module: cloud.google.com/go/storage
  ref:
    go-version: v1.30.1
    git-ref: storage/v1.30.1-0-gc537b5101cb92da8df95f2d34334b3db54731d5c
    subdirectory: storage
- kind: go_module
  url: https://github.com/DataDog/zstd.git
  module: github.com/DataDog/zstd
  ref:
    go-version: v1.5.2
    git-ref: v1.5.2-0-ge5990c1bf80e6c9121baeae77d75de291fc008b9
- kind: go_module
  url: https://github.com/acobaugh/osrelease.git
  module: github.com/acobaugh/osrelease
  ref:
    go-version: v0.1.0
    git-ref: v0.1.0-0-g8646ae955f5c3dc0fdd6be86cfb44ce61fb73bc0
- kind: go_module
  url: https://github.com/boljen/go-bitmap.git
  module: github.com/boljen/go-bitmap
  ref:
    go-version: v0.0.0-20151001105940-23cd2fb0ce7d
    git-ref: 23cd2fb0ce7db94d088d840df05fa0d274bbb2ec
- kind: go_module
  url: https://github.com/bytedance/sonic.git
  module: github.com/bytedance/sonic
  ref:
    go-version: v1.11.6
    git-ref: v1.11.6-0-g2b66aefcd60d189cff2669213f682557216b686f
- kind: go_module
  url: https://github.com/bytedance/sonic.git
  module: github.com/bytedance/sonic/loader
  ref:
    go-version: v0.1.1
    git-ref: loader/v0.1.1-0-g51ea135322cab599c287fe6418df4c2e3c32b65e
    subdirectory: loader
- kind: go_module
  url: https://github.com/cloudwego/base64x.git
  module: github.com/cloudwego/base64x
  ref:
    go-version: v0.1.4
    git-ref: v0.1.4-0-gaa02bf235e2a286ef3a99bacefb460195fc5a16b
- kind: go_module
  url: https://github.com/cloudwego/iasm.git
  module: github.com/cloudwego/iasm
  ref:
    go-version: v0.2.0
    git-ref: v0.2.0-0-gdb7298c17e362736a9954240db007c2432bf1fa1
- kind: go_module
  url: https://github.com/dchest/siphash.git
  module: github.com/dchest/siphash
  ref:
    go-version: v1.2.3
    git-ref: v1.2.3-0-gff76266fe39867071f4d33fb03aa101a83ba6706
- kind: go_module
  url: https://github.com/folbricht/tempfile.git
  module: github.com/folbricht/tempfile
  ref:
    go-version: v0.0.1
    git-ref: v0.0.1-0-gee190cb5934293f187a9d43ee34de7d5cf9ceb83
- kind: go_module
  url: https://github.com/fsnotify/fsnotify.git
  module: github.com/fsnotify/fsnotify
  ref:
    go-version: v1.9.0
    git-ref: v1.9.0-0-gae0e7923765f64fb8061396db7edebb558cf6093
- kind: go_module
  url: https://github.com/gabriel-vasile/mimetype.git
  module: github.com/gabriel-vasile/mimetype
  ref:
    go-version: v1.4.3
    git-ref: v1.4.3-0-ge64d6bdb3607578757d31380818651a9fc95ca8b
- kind: go_module
  url: https://github.com/gin-contrib/sse.git
  module: github.com/gin-contrib/sse
  ref:
    go-version: v0.1.0
    git-ref: v0.1.0-0-g54d8467d122d380a14768b6b4e5cd7ca4755938f
- kind: go_module
  url: https://github.com/go-playground/locales.git
  module: github.com/go-playground/locales
  ref:
    go-version: v0.14.1
    git-ref: v0.14.1-0-gce315c8672599942003599943a1e64288f55b03f
- kind: go_module
  url: https://github.com/go-playground/universal-translator.git
  module: github.com/go-playground/universal-translator
  ref:
    go-version: v0.18.1
    git-ref: v0.18.1-0-gf83cd526536e253181a13835b00cd107f627c505
- kind: go_module
  url: https://github.com/go-playground/validator.git
  module: github.com/go-playground/validator/v10
  ref:
    go-version: v10.20.0
    git-ref: v10.20.0-0-ge20b94842ab102ba94e73eaf66f5c0466e405882
- kind: go_module
  url: https://github.com/goccy/go-json.git
  module: github.com/goccy/go-json
  ref:
    go-version: v0.10.2
    git-ref: v0.10.2-0-g8e8cdeacf2f2faef082f32848138f0f9af7cfb66
- kind: go_module
  url: https://github.com/golang/groupcache.git
  module: github.com/golang/groupcache
  ref:
    go-version: v0.0.0-20210331224755-41bb18bfe9da
    git-ref: 41bb18bfe9da5321badc438f91158cd790a33aa3
- kind: go_module
  url: https://github.com/golang/protobuf.git
  module: github.com/golang/protobuf
  ref:
    go-version: v1.5.3
    git-ref: v1.5.3-0-g5d5e8c018a13017f9d5b8bf4fad64aaa42a87308
- kind: go_module
  url: https://github.com/google/go-cmp.git
  module: github.com/google/go-cmp
  ref:
    go-version: v0.6.0
    git-ref: v0.6.0-0-gc3ad8435e7bef96af35732bc0789e5a2278c6d5f
- kind: go_module
  url: https://github.com/google/uuid.git
  module: github.com/google/uuid
  ref:
    go-version: v1.3.0
    git-ref: v1.3.0-0-g44b5fee7c49cf3bcdf723f106b36d56ef13ccc88
- kind: go_module
  url: https://github.com/googleapis/enterprise-certificate-proxy.git
  module: github.com/googleapis/enterprise-certificate-proxy
  ref:
    go-version: v0.2.3
    git-ref: v0.2.3-0-gd0957a96ce28f68cd21ce2742c06237f3fa93fbe
- kind: go_module
  url: https://github.com/googleapis/gax-go.git
  module: github.com/googleapis/gax-go/v2
  ref:
    go-version: v2.8.0
    git-ref: v2.8.0-0-g77e4c0b8fc7be000a67e353e2d89cf71ca167cac
- kind: go_module
  url: https://github.com/hanwen/go-fuse.git
  module: github.com/hanwen/go-fuse/v2
  ref:
    go-version: v2.2.0
    git-ref: v2.2.0-0-g915cf5413cdef5370ae3f953f8eb4cd9ac176d5c
- kind: go_module
  url: https://github.com/json-iterator/go.git
  module: github.com/json-iterator/go
  ref:
    go-version: v1.1.12
    git-ref: v1.1.12-0-g024077e996b048517130b21ea6bf12aa23055d3d
- kind: go_module
  url: https://github.com/klauspost/compress.git
  module: github.com/klauspost/compress
  ref:
    go-version: v1.16.4
    git-ref: v1.16.4-0-g3c61d32490eb09e17e229559c73d2ab048cd0a8f
- kind: go_module
  url: https://github.com/klauspost/cpuid.git
  module: github.com/klauspost/cpuid/v2
  ref:
    go-version: v2.2.7
    git-ref: v2.2.7-0-g486f6ae65fec6bbb15e6f6bff15036f7bc50d4c4
- kind: go_module
  url: https://github.com/kr/fs.git
  module: github.com/kr/fs
  ref:
    go-version: v0.1.0
    git-ref: v0.1.0-0-g1455def202f6e05b95cc7bfc7e8ae67ae5141eba
- kind: go_module
  url: https://github.com/kr/text.git
  module: github.com/kr/text
  ref:
    go-version: v0.2.0
    git-ref: v0.2.0-0-g702c74938df48b97370179f33ce2107bd7ff3b3e
- kind: go_module
  url: https://github.com/leodido/go-urn.git
  module: github.com/leodido/go-urn
  ref:
    go-version: v1.4.0
    git-ref: v1.4.0-0-gd725923fe33ce69c89b9e2033d069099b498224f
- kind: go_module
  url: https://github.com/mattn/go-isatty.git
  module: github.com/mattn/go-isatty
  ref:
    go-version: v0.0.20
    git-ref: v0.0.20-0-ga7c02353c47bc4ec6b30dc9628154ae4fe760c11
- kind: go_module
  url: https://github.com/mattn/go-runewidth.git
  module: github.com/mattn/go-runewidth
  ref:
    go-version: v0.0.14
    git-ref: v0.0.14-0-g2c6a438f68cfe01255a90824599da41fdf76d1e2
- kind: go_module
  url: https://github.com/minio/md5-simd.git
  module: github.com/minio/md5-simd
  ref:
    go-version: v1.1.2
    git-ref: v1.1.2-0-g776275e0c9a74ceebbd50fe5c1d61b0c80c608df
- kind: go_module
  url: https://github.com/minio/minio-go.git
  module: github.com/minio/minio-go/v6
  ref:
    go-version: v6.0.57
    git-ref: v6.0.57-0-g51222d26253e90224f8b4f8ba9be9b7982e3ce53
- kind: go_module
  url: https://github.com/minio/sha256-simd.git
  module: github.com/minio/sha256-simd
  ref:
    go-version: v1.0.0
    git-ref: v1.0.0-0-g6a57409d8e0fa3ae883aee331b71aaa40d5a7dd9
- kind: go_module
  url: https://github.com/mitchellh/go-homedir.git
  module: github.com/mitchellh/go-homedir
  ref:
    go-version: v1.1.0
    git-ref: v1.1.0-0-gaf06845cf3004701891bf4fdb884bfe4920b3727
- kind: go_module
  url: https://github.com/modern-go/concurrent.git
  module: github.com/modern-go/concurrent
  ref:
    go-version: v0.0.0-20180306012644-bacd9c7ef1dd
    git-ref: bacd9c7ef1dd9b15be4a9909b8ac7a4e313eec94
- kind: go_module
  url: https://github.com/modern-go/reflect2.git
  module: github.com/modern-go/reflect2
  ref:
    go-version: v1.0.2
    git-ref: v1.0.2-0-g2b33151c9bbc5231aea69b8861c540102b087070
- kind: go_module
  url: https://github.com/pelletier/go-toml.git
  module: github.com/pelletier/go-toml/v2
  ref:
    go-version: v2.2.2
    git-ref: v2.2.2-0-ga3d5a0bb530b5206c728eed9cb57323061922bcb
- kind: go_module
  url: https://github.com/pkg/errors.git
  module: github.com/pkg/errors
  ref:
    go-version: v0.9.1
    git-ref: v0.9.1-0-g614d223910a179a466c1767a985424175c39b465
- kind: go_module
  url: https://github.com/pkg/sftp.git
  module: github.com/pkg/sftp
  ref:
    go-version: v1.13.5
    git-ref: v1.13.5-0-ga17a626ab843d522fad5e3d2e22cec5519661e55
- kind: go_module
  url: https://github.com/pkg/xattr.git
  module: github.com/pkg/xattr
  ref:
    go-version: v0.4.9
    git-ref: v0.4.9-0-g87ba458273dc4e1cfef4d6d43faffdcf7e9077be
- kind: go_module
  url: https://github.com/rivo/uniseg.git
  module: github.com/rivo/uniseg
  ref:
    go-version: v0.2.0
    git-ref: v0.2.0-0-g75711fccf6a3e85bc74c241e2dddd06a9bc9e53d
- kind: go_module
  url: https://github.com/stretchr/testify.git
  module: github.com/stretchr/testify
  ref:
    go-version: v1.12.1
    git-ref: v1.12.1-0-g959dbdacf1533e155162811ea90c90117a420463
- kind: go_module
  url: https://github.com/twitchyliquid64/golang-asm.git
  module: github.com/twitchyliquid64/golang-asm
  ref:
    go-version: v0.15.1
    git-ref: v0.15.1-0-g8d7f1f783b11f9a00f5bcdfcae17f5ac8f22512e
- kind: go_module
  url: https://github.com/ugorji/go.git
  module: github.com/ugorji/go/codec
  ref:
    go-version: v1.2.12
    git-ref: codec/v1.2.12-0-g43b79bfcab412eeb73e92181a2190e97a5520566
    subdirectory: codec
- kind: go_module
  url: https://github.com/census-instrumentation/opencensus-go.git
  module: go.opencensus.io
  ref:
    go-version: v0.24.0
    git-ref: v0.24.0-0-gb1a01ee95db0e690d91d7193d037447816fae4c5
- kind: go_module
  url: https://github.com/yaml/go-yaml.git
  module: go.yaml.in/yaml/v3
  ref:
    go-version: v3.0.5
    git-ref: v3.0.5-0-ge16c7af9361b241fa02d91582fb59ce4954d8afc
- kind: go_module
  url: https://go.googlesource.com/arch.git
  module: golang.org/x/arch
  ref:
    go-version: v0.8.0
    git-ref: v0.8.0-0-g5d0b1102bee052ce00bf47f9cfef8f73d2ac6d46
- kind: go_module
  url: https://go.googlesource.com/crypto.git
  module: golang.org/x/crypto
  ref:
    go-version: v0.41.0
    git-ref: v0.41.0-0-gef5341b70697ceb55f904384bd982587224e8b0c
- kind: go_module
  url: https://go.googlesource.com/net.git
  module: golang.org/x/net
  ref:
    go-version: v0.43.0
    git-ref: v0.43.0-0-ge74bc31d69f225b635e065a602db3fbfa9850f93
- kind: go_module
  url: https://go.googlesource.com/oauth2.git
  module: golang.org/x/oauth2
  ref:
    go-version: v0.27.0
    git-ref: v0.27.0-0-g681b4d8edca1bcfea5bce685d77ea7b82ed3e7b3
- kind: go_module
  url: https://go.googlesource.com/sys.git
  module: golang.org/x/sys
  ref:
    go-version: v0.35.0
    git-ref: v0.35.0-0-g5b936e1f126baa13682eff91c2e4d5d9e3a0b71d
- kind: go_module
  url: https://go.googlesource.com/term.git
  module: golang.org/x/term
  ref:
    go-version: v0.34.0
    git-ref: v0.34.0-0-ga35244d18d7756b12deca31a518c0fa1327d050a
- kind: go_module
  url: https://go.googlesource.com/text.git
  module: golang.org/x/text
  ref:
    go-version: v0.28.0
    git-ref: v0.28.0-0-g425d715b4a85c7698cedf621412bb53794cbda53
- kind: go_module
  url: https://go.googlesource.com/xerrors.git
  module: golang.org/x/xerrors
  ref:
    go-version: v0.0.0-20220907171357-04be3eba64a2
    git-ref: 04be3eba64a22a838cdb17b8dca15a52871c08b4
- kind: go_module
  url: https://github.com/googleapis/google-api-go-client.git
  module: google.golang.org/api
  ref:
    go-version: v0.116.0
    git-ref: v0.116.0-0-g587b9e55be0f89d513a5b72bf81e9f5e0c560027
- kind: go_module
  url: https://github.com/golang/appengine.git
  module: google.golang.org/appengine
  ref:
    go-version: v1.6.7
    git-ref: v1.6.7-0-g5d1c1d03f8703c2e81478d9a30e9afa2d3e4bd8a
- kind: go_module
  url: https://github.com/googleapis/go-genproto.git
  module: google.golang.org/genproto
  ref:
    go-version: v0.0.0-20230410155749-daa745c078e1
    git-ref: daa745c078e18def54ea6b63235554b59c97f01d
- kind: go_module
  url: https://github.com/grpc/grpc-go.git
  module: google.golang.org/grpc
  ref:
    go-version: v1.56.3
    git-ref: v1.56.3-0-g1055b481ed2204a29d233286b9b50c42b63f8825
- kind: go_module
  url: https://go.googlesource.com/protobuf.git
  module: google.golang.org/protobuf
  ref:
    go-version: v1.34.1
    git-ref: v1.34.1-0-g4a76e11653e368b9331815e1eb98e0cedc28997f
- kind: go_module
  url: https://gopkg.in/cheggaaa/pb.v1.git
  module: gopkg.in/cheggaaa/pb.v1
  ref:
    go-version: v1.0.28
    git-ref: v1.0.28-0-gf907f6f5dd81f77c2bbc1cde92e4c5a04720cb11
- kind: go_module
  url: https://gopkg.in/ini.v1.git
  module: gopkg.in/ini.v1
  ref:
    go-version: v1.67.0
    git-ref: v1.67.0-0-gb2f570e5b5b844226bbefe6fb521d891f529a951
