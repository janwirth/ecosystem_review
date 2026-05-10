# Hashing in Gleam

> [!NOTE]
> **Status:** DRAFT · **Authoring:** AI-assisted, human-reviewed.

So you want to hash something — verify a download, sign a webhook, key a hash map, content-address an IPFS blob, or just check whether two byte strings are the same — written in Gleam?

The Gleam side of hashing is **one strong canonical library plus a long tail of single-algorithm packages**. [`gleam_crypto`](#gleam_crypto) (first-party) covers MD5, SHA-1, SHA-2 and HMAC across BEAM **and** JavaScript. Every other algorithm — SHA-3, BLAKE2, BLAKE3, Murmur3, SipHash, Keccak — is a separate package, often with two or three competing implementations. Password hashing has its own article ([authentication.md](authentication.md#password-hashing)); this article covers everything else.

If you're picking a hash for a specific job, jump to **[When to use what](#when-to-use-what)**.

> [!TIP]
> **Quick recipes — copy-paste starting points for the five most common jobs.**
>
> **1. Hash a password** → use [`argus`](authentication.md#argus) (Argon2id, OWASP default). **Never** `gleam_crypto.hash` for passwords — SHA-256 is fast, which is the wrong property here.
>
> ```gleam
> import argus
>
> pub fn store(plaintext: String) -> String {
>   let assert Ok(hashed) = argus.hash(plaintext)
>   hashed  // store this string in your DB
> }
>
> pub fn check(plaintext: String, stored: String) -> Bool {
>   let assert Ok(ok) = argus.verify(plaintext, stored)
>   ok
> }
> ```
>
> **2. Hash a file / verify a download** → SHA-256 via [`gleam_crypto`](#gleam_crypto).
>
> ```gleam
> import gleam/bit_array
> import gleam/crypto
>
> pub fn checksum(contents: BitArray) -> String {
>   crypto.hash(crypto.Sha256, contents)
>   |> bit_array.base16_encode
> }
> ```
>
> **3. Sign / verify a webhook or session cookie** → HMAC-SHA256 + constant-time compare.
>
> ```gleam
> import gleam/crypto
>
> pub fn sign(secret: BitArray, message: BitArray) -> BitArray {
>   crypto.hmac(message, crypto.Sha256, secret)
> }
>
> pub fn verify(secret: BitArray, message: BitArray, tag: BitArray) -> Bool {
>   let expected = crypto.hmac(message, crypto.Sha256, secret)
>   crypto.secure_compare(expected, tag)  // NOT ==, that's a timing-attack vector
> }
> ```
>
> **4. Key a hash map / shard a load balancer** → fast non-crypto Murmur3 via [`murmur3a`](#murmur3a).
>
> ```gleam
> import murmur3a
>
> pub fn shard_id(key: String) -> Int {
>   murmur3a.hash_string(key) % 64
> }
> ```
>
> **5. Compute an IPFS / multihash content ID** → [`multiformats`](#multiformats) + [`gleam_crypto`](#gleam_crypto).
>
> ```gleam
> import gleam/crypto
> import multiformats/cid
> import multiformats/multihash
>
> pub fn content_id(payload: BitArray) -> String {
>   let digest = crypto.hash(crypto.Sha256, payload)
>   let mh = multihash.new(multihash.Sha2_256, digest)
>   cid.new(cid.V1, cid.Raw, mh) |> cid.to_string
> }
> ```
>
> Other jobs — Keccak-256, BLAKE3, BLAKE2, SipHash, Bloom filters, Merkle trees, FFI escape hatches for missing algorithms — see [When to use what](#when-to-use-what).

## Table of Contents

1. [Summary](#summary)
2. [State of the ecosystem](#state-of-the-ecosystem)
3. [Research Method](#research-method)
   - [Scoring Dimensions](#scoring-dimensions)
   - [Discovery](#discovery)
4. [Disregarded](#disregarded)
5. [When to use what](#when-to-use-what)
6. [Categories](#categories)
   - [Cryptographic hashes](#cryptographic-hashes) — [gleam_crypto](#gleam_crypto) · [glesha](#glesha) · [keccaky](#keccaky) · [keccak_gleam](#keccak_gleam) · [sha3 (poulwann)](#sha3-poulwann) · [sha3_gleam](#sha3_gleam) · [gblake2](#gblake2) · [nimiq_blake2b](#nimiq_blake2b) · [gblake3](#gblake3) · [pegasus_crypto](#pegasus_crypto)
   - [Non-cryptographic hashes](#non-cryptographic-hashes) — [murmur3a](#murmur3a) · [mumu](#mumu) · [gsiphash](#gsiphash) · [kmh](#kmh)
   - [HMAC & message signing](#hmac--message-signing) — [gleam_crypto.hmac](#gleam_crypto) · [hypersig](#hypersig) · [hashsigs](#hashsigs)
   - [Password hashing](#password-hashing) — *cross-link to [authentication.md](authentication.md#password-hashing)*
   - [Content-addressing & specialty](#content-addressing--specialty) — [multiformats](#multiformats) · [gleam-merkle](#gleam-merkle) · [bloomfilter_gleam](#bloomfilter_gleam)
   - [What's missing](#whats-missing)
7. [Leaderboard](#leaderboard)

## Summary

Snapshot: **2026-05-10**.

| Category | ☎️ BEAM | 📜 JS |
| --- | --- | --- |
| **[Cryptographic — canonical](#gleam_crypto)** | · [🥇](#leaderboard) [gleam_crypto](#gleam_crypto) ([repo](https://github.com/gleam-lang/crypto), 53★) — *MD5/SHA-1/SHA-2 + HMAC + secure compare + signed messages. First-party, dual-target.* | · [gleam_crypto](#gleam_crypto) — *same package, JS via `node:crypto`* |
| **[Cryptographic — SHA-3 / Keccak](#sha-3--keccak)** | · [sha3 (poulwann)](#sha3-poulwann) ([repo](https://github.com/poulwann/sha3-gleam)) — *real SHA-3 224/256/384/512 via Erlang `:crypto`, git-only* <br>· [keccak_gleam](#keccak_gleam) ([repo](https://github.com/gusinacio/keccak_gleam), 0★) — *Keccak-256 (Ethereum), Elixir `ex_keccak` NIF* <br>· [keccaky](#keccaky) ([repo](https://github.com/pxlvre/keccaky), 3★) — *Keccak-256, Rust NIF, git-only* <br>· [sha3_gleam](#sha3_gleam) ([repo](https://github.com/DenizBasgoren/sha3_gleam), 1★) — *pure-Gleam toy; author disclaims production use* | — |
| **[Cryptographic — BLAKE](#blake-family)** | · [gblake3](#gblake3) ([repo](https://codeberg.org/delta_g/gblake3)) — *BLAKE3, dual-target* <br>· [gblake2](#gblake2) ([repo](https://github.com/sisou/nimiq_gleam), 3★) — *BLAKE2b/2s via Elixir `blake2`* <br>· [nimiq_blake2b](#nimiq_blake2b) ([same parent](https://github.com/sisou/nimiq_gleam)) — *Nimiq-flavoured BLAKE2b* <br>· [pegasus_crypto](#pegasus_crypto) ([codeberg](https://codeberg.org/cmooon/pegasus), 1★) — *BLAKE2b via Rust NIF; claims constant-time + zero-on-drop, **v0.0.1 preview*** | · [gblake3](#gblake3) — *also targets JS via `blake3` npm package* |
| **[Non-cryptographic](#non-cryptographic-hashes)** | · [🥇](#leaderboard) [murmur3a](#murmur3a) ([codeberg](https://codeberg.org/eaon/murmur3a)) — *Murmur3 32-bit, pure-Gleam port (no FFI), dual-target* <br>· [mumu](#mumu) ([repo](https://github.com/georgesboris/mumu), 1★) — *Murmur3 32-bit via FFI: Erlang NIF on BEAM + vendored `murmurhash-js` on JS, dual-target, faster on BEAM* <br>· [gsiphash](#gsiphash) ([repo](https://github.com/BrendoCosta/gsiphash), 1★) — *SipHash family, pure Gleam* <br>· [kmh](#kmh) ([repo](https://github.com/mdarse/kmh)) — *Knuth multiplicative hashing, **LGPL*** | · [murmur3a](#murmur3a) — *same package, pure-Gleam dual-target* <br>· [mumu](#mumu) — *vendored `murmurhash3_gc.mjs` for JS* |
| **[HMAC / signing-adjacent](#hmac--message-signing)** | · [gleam_crypto.hmac](#gleam_crypto) — *the HMAC entry point* <br>· [hypersig](#hypersig) ([codeberg](https://codeberg.org/anactualemerald/hypersig)) — *HTTP signature + Digest header for ActivityPub, **GPL*** <br>· [hashsigs](#hashsigs) ([repo](https://github.com/ncitron/hashsigs), 1★) — *Lamport/Winternitz hash-based signatures, stub* | — |
| **[Content-addressing](#content-addressing--specialty)** | · [multiformats](#multiformats) ([repo](https://github.com/CrowdHailer/multiformats), 4★) — *IPFS CID: multihash + multibase + multicodec, pairs with `gleam_crypto`* <br>· [gleam-merkle](#gleam-merkle) ([repo](https://github.com/mazshakibaii/gleam-merkle)) — *simple Merkle tree, pure Gleam* <br>· [bloomfilter_gleam](#bloomfilter_gleam) ([repo](https://github.com/sravan-s/bloomfilter_gleam)) — *Bloom filter, **WIP*** | — |
| **[Password hashing](#password-hashing)** | *See [authentication.md#password-hashing](authentication.md#password-hashing)* — argus, antigone, aragorn2 (Argon2id) · beecrypt (bcrypt) · pinkdf2 (PBKDF2) | — |

> [!NOTE]
> The two Murmur3 packages on Hex are [`murmur3a`](#murmur3a) (pure-Gleam port, dual-target) and [`mumu`](#mumu) (FFI wrapper: Erlang NIF on BEAM + vendored `murmurhash-js` on JS, also dual-target). See the [explainer note](#non-cryptographic-hashes) for why both exist. A third Hex package named `murmur` is **pure Elixir, not Gleam** — installable as a dep and reachable via FFI, listed in [Disregarded](#disregarded) so searchers find the breadcrumb.

## State of the ecosystem

Hashing in Gleam is **one canonical library plus a long, fragmented tail.**

What's there:
- **[`gleam_crypto`](#gleam_crypto)** — first-party, dual-target, covers MD5/SHA-1/SHA-2 + HMAC + secure compare + signed cookies. Wraps Erlang's `:crypto` on BEAM and `node:crypto` on JS.
- **Four** independent SHA-3 / Keccak implementations (one Erlang-`:crypto` wrapper, two NIFs, one pure-Gleam toy) — none canonical, all small.
- **Three** BLAKE2b implementations (`gblake2`, `nimiq_blake2b`, `pegasus_crypto`) and one **BLAKE3** (`gblake3`, the only dual-target non-`gleam_crypto` cryptographic hash).
- **Two** Murmur3 32-bit implementations, both dual-target via opposite strategies: `murmur3a` (pure-Gleam port of the Elm `murmur3`); `mumu` (FFI: Erlang NIF on BEAM + vendored `murmurhash-js` on JS).
- One **SipHash** (`gsiphash`), one **Knuth-multiplicative** (`kmh`).
- One **content-addressing** library (`multiformats` for IPFS CIDs).
- Per-algorithm **password hashing** in [authentication.md](authentication.md#password-hashing).

What's missing entirely:
- **No xxHash** — surprising given it's the default fast non-crypto hash in many ecosystems.
- **No CRC32 / Adler-32** — needed for ZIP, gzip, PNG.
- **No FNV / CityHash / wyhash / HighwayHash / SpookyHash / FarmHash / MetroHash / t1ha**.
- **No standalone Murmur3 128-bit** (the 32-bit variant is covered by `murmur3a` and `mumu`).
- **No RIPEMD / Whirlpool / Tiger / Skein / Groestl** (legacy or niche).
- **No PASETO**, no standalone **Poly1305 MAC**, no **CMAC / KMAC**.
- **No perceptual hashing** (`phash` / `dhash` / `aHash` — image-similarity).
- **No `phash2` wrapper** for Erlang's BEAM-internal term hash. Write a one-liner FFI declaration if you need it.
- **No constant-time large-input hash** documented anywhere except `pegasus_crypto`'s preview.

Star counts are tiny — the canonical library tops out at 53★ and most others are 0–4★. Use these as **thin, replaceable layers**; for any algorithm not on this list, FFI directly to the Erlang/Elixir Hex package.

## Research Method

### Scoring Dimensions

Same rubric as [databases.md#scoring-dimensions](databases.md#scoring-dimensions). Recap:

- **Stars:** 🟩🟩 ≥200★, 🟩 ≥100★, 🟨 ≥10★, 🟥 <10★. *Hashing packages skew tiny — most land in 🟥.*
- **License:** 🟩 permissive (MIT/Apache/BSD), 🟥 viral (GPL/LGPL/AGPL) or missing.
- **Gleam compat:** `gleam_stdlib` constraint format. 🟩 range, 🟥 `~>` pin or missing.
- **Maintenance:** max(recency, responsiveness). 🟩🟩 <1 mo / clean tracker, 🟩 <6 mo, 🟨 <1 yr, 🟥 older.
- **Age:** 🟩🟩 ≥3 yrs, 🟩 ≥1 yr, 🟨 ≥3 mo, 🟥 <3 mo.
- **README maturity:** 🟩🟩 full guide + examples, 🟩 clear tagline + usage, 🟥 minimal/template.
- **Idiomaticity:** 🟩 typed/explicit, 🟥 magic or unsafe.

**Leaderboard:** 🟥 = −1, 🟨 = 0, 🟩 = 1, 🟩🟩 = 2. Sum of 7 dims, max 13.

### Discovery

~50 search terms run against the [Gleam packages registry](https://packages.gleam.run/). Cross-checked against [hex.pm](https://hex.pm/packages?_search=&_sort=recent_downloads), GitHub `language:gleam` searches, and Codeberg.

- [hash](https://packages.gleam.run/?search=hash) · [hashing](https://packages.gleam.run/?search=hashing) · [hasher](https://packages.gleam.run/?search=hasher) · [digest](https://packages.gleam.run/?search=digest) · [checksum](https://packages.gleam.run/?search=checksum) · [fingerprint](https://packages.gleam.run/?search=fingerprint)
- [crypto](https://packages.gleam.run/?search=crypto) · [crypt](https://packages.gleam.run/?search=crypt)
- [sha](https://packages.gleam.run/?search=sha) · [sha1](https://packages.gleam.run/?search=sha1) · [sha2](https://packages.gleam.run/?search=sha2) · [sha256](https://packages.gleam.run/?search=sha256) · [sha512](https://packages.gleam.run/?search=sha512) · [sha3](https://packages.gleam.run/?search=sha3) · [keccak](https://packages.gleam.run/?search=keccak)
- [md5](https://packages.gleam.run/?search=md5) — *no Gleam-native results; covered by `gleam_crypto`*
- [blake](https://packages.gleam.run/?search=blake) · [blake2](https://packages.gleam.run/?search=blake2) · [blake3](https://packages.gleam.run/?search=blake3)
- [crc](https://packages.gleam.run/?search=crc) · [crc32](https://packages.gleam.run/?search=crc32) · [adler](https://packages.gleam.run/?search=adler) — *no results*
- [xxhash](https://packages.gleam.run/?search=xxhash) · [xxh](https://packages.gleam.run/?search=xxh) — *no results*
- [murmur](https://packages.gleam.run/?search=murmur) · [murmur3](https://packages.gleam.run/?search=murmur3) · [murmurhash](https://packages.gleam.run/?search=murmurhash)
- [siphash](https://packages.gleam.run/?search=siphash) · [fnv](https://packages.gleam.run/?search=fnv) — *no results* · [cityhash](https://packages.gleam.run/?search=cityhash) — *no results* · [wyhash](https://packages.gleam.run/?search=wyhash) — *no results* · [highwayhash](https://packages.gleam.run/?search=highwayhash) — *no results* · [spookyhash](https://packages.gleam.run/?search=spookyhash) — *no results* · [farmhash](https://packages.gleam.run/?search=farmhash) — *no results* · [metrohash](https://packages.gleam.run/?search=metrohash) — *no results* · [t1ha](https://packages.gleam.run/?search=t1ha) — *no results*
- [hmac](https://packages.gleam.run/?search=hmac) · [mac](https://packages.gleam.run/?search=mac) · [poly1305](https://packages.gleam.run/?search=poly1305) — *no standalone result; only AEAD via `casper`*
- [argon](https://packages.gleam.run/?search=argon) · [scrypt](https://packages.gleam.run/?search=scrypt) — *no results* · [pbkdf2](https://packages.gleam.run/?search=pbkdf2) · [bcrypt](https://packages.gleam.run/?search=bcrypt) (covered in [authentication.md](authentication.md#password-hashing))
- [bloom](https://packages.gleam.run/?search=bloom) · [bloomfilter](https://packages.gleam.run/?search=bloomfilter) · [cuckoo](https://packages.gleam.run/?search=cuckoo) — *no results*
- [merkle](https://packages.gleam.run/?search=merkle) · [multihash](https://packages.gleam.run/?search=multihash) — *folded into [multiformats](#multiformats)* · [ipfs](https://packages.gleam.run/?search=ipfs) · [cid](https://packages.gleam.run/?search=cid)
- [paseto](https://packages.gleam.run/?search=paseto) — *no results* · [phash](https://packages.gleam.run/?search=phash) — *no results* · [perceptual](https://packages.gleam.run/?search=perceptual) — *no results* · [minhash](https://packages.gleam.run/?search=minhash) — *no results* · [simhash](https://packages.gleam.run/?search=simhash) — *no results* · [rabin](https://packages.gleam.run/?search=rabin) — *no results* · [rolling](https://packages.gleam.run/?search=rolling) — *no results*
- [ripemd](https://packages.gleam.run/?search=ripemd) — *no results* · [whirlpool](https://packages.gleam.run/?search=whirlpool) — *no results* · [tiger](https://packages.gleam.run/?search=tiger) — *no results* · [skein](https://packages.gleam.run/?search=skein) — *no results* · [poseidon](https://packages.gleam.run/?search=poseidon) — *no results*

GitHub `language:gleam` repository search surfaced two unpublished entries (`keccaky`, `sha3-gleam`) not on Hex.

## Disregarded

These turned up in searches but are **not recommended** for general use. Listed up-front so reviewers and readers see "this corner has been considered, here's what was skipped and why" before drilling into per-category content.

| Package | Reason disregarded |
| --- | --- |
| [`glesha2`](https://hex.pm/packages/glesha2) | Marked **retired** on Hex; deprecation notice points back to [`glesha`](#glesha). |
| [`murmur` (preciz/murmur)](https://hex.pm/packages/murmur) | **Pure Elixir, not Gleam.** Listed because Gleam users searching for Murmur3 will find it on Hex. Reachable via FFI; the more-complete 128-bit Murmur3 path. **Not** the "two Murmur3 hashes" the user's todo references — those are [`murmur3a`](#murmur3a) and [`mumu`](#mumu). |
| [`shamir`](https://hex.pm/packages/shamir) | Shamir Secret Sharing — **not a hash function**. AGPL-3.0. Listed because security-keyword searches surface it. |
| [`casper`](https://hex.pm/packages/casper) | ChaCha20-Poly1305 **AEAD** (combined cipher), not a standalone Poly1305 MAC. Listed because `poly1305` searches surface it. |
| [`gleam-merkle`](https://github.com/mazshakibaii/gleam-merkle) | Listed in Categories below for completeness, but no license, 0★, single commit — caveat for production use. |
| [`bloomfilter_gleam`](https://github.com/sravan-s/bloomfilter_gleam) | README explicitly says "Trying to implement…" — incomplete WIP, no license. |

## When to use what

| You want to… | Use | Notes |
| --- | --- | --- |
| **Verify a downloaded file or signed payload** (SHA-256, SHA-512) | [`gleam_crypto.hash(Sha256, ..)`](#gleam_crypto) | First-party, fast, dual-target. |
| **Sign / verify a webhook or session cookie** (HMAC-SHA256) | [`gleam_crypto.hmac/3`](#gleam_crypto) | Use [`gleam_crypto.secure_compare/2`](#gleam_crypto) on the result. |
| **Sign a serialisable cookie / JWT-lite token** | [`gleam_crypto.sign_message/3`](#gleam_crypto) | Built on HMAC; verify with `verify_signed_message/2`. |
| **Hash a password for storage** | See [authentication.md#password-hashing](authentication.md#password-hashing) | Argon2id via [`argus`](authentication.md#argus). **Never** `gleam_crypto.hash` for passwords. |
| **Generate / verify a JWT** | See [authentication.md#jose--jwt-jws-jwe](authentication.md#jose--jwt-jws-jwe) | `gose`, `ywt`, or `gwt` — they call into the right hash for you. |
| **Key a hash map / dedup big lists / shard a load balancer** (fast non-crypto) | [`murmur3a`](#murmur3a) (default) or [`mumu`](#mumu) (faster on BEAM) | Both are Murmur3 32-bit, both dual-target — `murmur3a` is a pure-Gleam port (zero native deps, active upstream); `mumu` FFI-wraps a native NIF on BEAM + vendored JS. |
| **Hash-table key randomisation against DoS** | [`gsiphash`](#gsiphash) | SipHash is what Python/Rust/Ruby use for the same purpose. |
| **SHA-3 / Keccak (Ethereum, Cardano, modern crypto specs)** | [`sha3` (poulwann)](#sha3-poulwann) for SHA-3 standard, [`keccak_gleam`](#keccak_gleam) for Ethereum-Keccak-256 | Both wrap battle-tested NIFs. Avoid [`sha3_gleam`](#sha3_gleam) — author disclaims production use. |
| **BLAKE3 (modern fast crypto hash)** | [`gblake3`](#gblake3) | Only option; dual-target. |
| **BLAKE2b** (Argon2 internals, libsodium parity, Nimiq) | [`gblake2`](#gblake2) for general use, [`nimiq_blake2b`](#nimiq_blake2b) for Nimiq, [`pegasus_crypto`](#pegasus_crypto) if you want the security-hardening claims (preview) | Three packages, three design points. |
| **MD5 / SHA-1** (legacy file formats, S3 ETags, git) | [`gleam_crypto.hash(Md5, ..)`](#gleam_crypto) | Insecure for crypto, fine for non-security checksums. |
| **Compute an IPFS CID / multihash** | [`multiformats`](#multiformats) + [`gleam_crypto`](#gleam_crypto) | `multiformats` builds the envelope; `gleam_crypto` does the SHA-256. |
| **Hash arbitrary BEAM terms for ETS / Map keys** | FFI to `:erlang.phash2/1` directly | No Gleam wrapper exists. One-line `@external(erlang, "erlang", "phash2")` declaration. |
| **CRC32 / Adler-32** (ZIP, gzip, PNG, network protocols) | FFI to Erlang `:erlang.crc32/1` or `zlib:crc32/2` | No Gleam-native package. |
| **xxHash, FNV, CityHash, wyhash** (other fast non-crypto) | FFI to the corresponding Erlang/Elixir Hex package | No Gleam-native package. |
| **Constant-time secure-compare of two hashes** | [`gleam_crypto.secure_compare/2`](#gleam_crypto) | Always use this for comparing MACs/digests against attacker-controlled input. **Never** `==`. |
| **Bloom filter / Cuckoo filter / probabilistic membership** | Roll your own on top of [`gsiphash`](#gsiphash) or [`mumu`](#mumu); [`bloomfilter_gleam`](#bloomfilter_gleam) is WIP | No production-ready Gleam package. |
| **Merkle tree** (audit logs, blockchains, certificate transparency) | [`gleam-merkle`](#gleam-merkle) for a starting point; verify the implementation before depending on it | 0★, no license — preview-quality. |

> [!IMPORTANT]
> **Two rules to take with you:**
> 1. **For passwords, always use a memory-hard KDF** (Argon2id via [`argus`](authentication.md#argus)). `gleam_crypto.hash(Sha256, password)` is **not** safe for password storage.
> 2. **For comparing two MACs / digests against attacker input, always use [`gleam_crypto.secure_compare/2`](#gleam_crypto)**. Comparing with `==` is a timing-attack vector.

## Categories

### Cryptographic hashes

The first-party path covers MD5, SHA-1, and SHA-2 across BEAM and JS in one package. Everything else (SHA-3, BLAKE) is a separate per-algorithm package, often with multiple competing implementations.

| Criterion | [gleam_crypto](#gleam_crypto) | [glesha](#glesha) | [keccak_gleam](#keccak_gleam) | [sha3](#sha3-poulwann) | [gblake3](#gblake3) | [gblake2](#gblake2) | [pegasus_crypto](#pegasus_crypto) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Algorithms | MD5, SHA-1, SHA-2 (224/256/384/512), HMAC | SHA-2 (224/256/384/512) | Keccak-256 | SHA-3 (224/256/384/512) | BLAKE3 | BLAKE2b/2s | BLAKE2b |
| Stars | 53★ · 🟨 | 2★ · 🟥 | 0★ · 🟥 | 0★ · 🟥 | 0★ · 🟥 | 3★ (parent) · 🟥 | 1★ · 🟥 |
| License | Apache-2.0 · 🟩 | MIT · 🟩 | (none) · 🟥 | 0BSD · 🟩 | Apache-2.0 · 🟩 | Apache-2.0 · 🟩 | MIT · 🟩 |
| Target | ☎️ BEAM + 📜 JS | ☎️ BEAM | ☎️ BEAM (Elixir NIF) | ☎️ BEAM (`:crypto`) | ☎️ BEAM + 📜 JS (NIF + JS-FFI) | ☎️ BEAM (Elixir NIF) | ☎️ BEAM (Rust NIF) |
| Gleam compat | `>= 0.44 and < 2.0` · 🟩 | (range) · 🟩 | (range) · 🟩 | (range) · 🟩 | (range) · 🟩 | (range) · 🟩 | (range) · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-04-18, 3 open issues) | 🟥 (last commit 2024-04-13, 1 open) | 🟥 (last commit 2024-08-11, 0 open) | 🟨 (last commit 2025-07-24, 0 open, 5 commits total) | 🟩🟩 (last commit 2026-04-16, 0 open) | 🟩 (parent last commit 2026-01-19) | 🟨 (last commit 2025-02-27, 1 open) |
| README | 🟩🟩 (full guide + examples + dual-target notes) | 🟩 (clear tagline + usage) | 🟥 (template-only "TODO: example") | 🟩 (clear) | 🟩 (clear, dual-target install) | 🟩 (clear, sub-dir of monorepo) | 🟩 (clear, security-claim docs) |
| Idiomaticity | 🟩 (typed, explicit `Algorithm` constructors) | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 | 🟩 |

#### gleam_crypto
[repo](https://github.com/gleam-lang/crypto) · [hexdocs](https://hexdocs.pm/gleam_crypto/) · [🥇](#leaderboard)

First-party Gleam wrapper for Erlang's `:crypto` (BEAM) and `node:crypto` (JS). The de-facto canonical hash + HMAC + secure-compare + signed-message library. Algorithms: `Md5`, `Sha1`, `Sha224`, `Sha256`, `Sha384`, `Sha512`. HMAC over all of those. Streaming via `Hasher` (`new_hasher` / `hash_chunk` / `digest`). `secure_compare/2` is constant-time.

```gleam
import gleam/crypto
import gleam/bit_array

pub fn hash_file(contents: BitArray) -> String {
  crypto.hash(crypto.Sha256, contents)
  |> bit_array.base16_encode
}

pub fn sign(secret: BitArray, message: BitArray) -> BitArray {
  crypto.hmac(message, crypto.Sha256, secret)
}

pub fn verify(secret: BitArray, message: BitArray, tag: BitArray) -> Bool {
  let expected = crypto.hmac(message, crypto.Sha256, secret)
  crypto.secure_compare(expected, tag)
}
```

Notable absence: **no SHA-3, no BLAKE, no MD2/MD4, no RIPEMD, no Whirlpool**. Anything beyond SHA-1/SHA-2 + MD5 needs a third-party package below.

#### glesha
[repo](https://github.com/bunopnu/glesha) · [hexdocs](https://hexdocs.pm/glesha/)

"SHA-2 for Gleam." Pre-dates `gleam_crypto`'s SHA-2 support; **fully redundant with stdlib today**. Listed for historical context — the sibling package `glesha2` is **retired** on Hex.

#### SHA-3 / Keccak

Four packages, none canonical. The ecosystem is fragmented here:

##### sha3 (poulwann)
[repo](https://github.com/poulwann/sha3-gleam)

Real **SHA-3 (224/256/384/512)** via Erlang `:crypto` — which has shipped SHA-3 since OTP 22 (2019) but `gleam_crypto` does not expose. Five commits total, **git-only** (no Hex publication), 0BSD. The closest thing to a canonical SHA-3 path on BEAM today; the function is implemented in OTP, this package is a thin wrapper.

##### keccak_gleam
[repo](https://github.com/gusinacio/keccak_gleam) · [hexdocs](https://hexdocs.pm/keccak_gleam/)

**Keccak-256** (the Ethereum-flavoured SHA-3 variant — different padding from standardised SHA-3-256) via the Elixir `ex_keccak` NIF. README is template-only; license not declared. Use this if you specifically need Ethereum-Keccak; for standardised SHA-3 use [`sha3` above](#sha3-poulwann).

##### keccaky
[repo](https://github.com/pxlvre/keccaky)

Same goal as `keccak_gleam` (Keccak-256) but via `tiny-keccak` Rust NIF. **Not on Hex** — clone-and-build only. 3★, MIT.

##### sha3_gleam
[repo](https://github.com/DenizBasgoren/sha3_gleam)

Pure-Gleam SHA-3 implementation. Author **explicitly disclaims**: *"not intended for production… not fast, nor safe."* Useful as a study reference; do not depend on it.

#### BLAKE family

##### gblake3
[repo](https://codeberg.org/delta_g/gblake3) · [hexdocs](https://hexdocs.pm/gblake3/)

**BLAKE3** with dual-target support — Erlang via the `b3` NIF, JavaScript via the `blake3` npm package. Includes keyed hashing. Apache-2.0, recently maintained (last commit 2026-04-16). The only path for BLAKE3 in Gleam.

##### gblake2
[repo](https://github.com/sisou/nimiq_gleam) (sub-dir `gblake2/`) · [hexdocs](https://hexdocs.pm/gblake2/)

**BLAKE2b/BLAKE2s** via Elixir's `blake2` Hex package (which itself wraps a C NIF). RFC 7693. Full-message hashing only — no streaming, no keyed-MAC, no tree mode. Lives in the `nimiq_gleam` monorepo.

##### nimiq_blake2b
[repo](https://github.com/sisou/nimiq_gleam) (sub-dir `nimiq_blake2b/`) · [hexdocs](https://hexdocs.pm/nimiq_blake2b/)

Nimiq-blockchain–parametrised BLAKE2b — a thin convenience wrapper around `gblake2`. Skip unless you're on Nimiq.

##### pegasus_crypto
[repo](https://codeberg.org/cmooon/pegasus) · [hexdocs](https://hexdocs.pm/pegasus_crypto/)

"Modern cryptography library for Gleam, built with safety and ease of use in mind." Implements **BLAKE2b** via a Rust NIF that inherits properties from the Orion crate — claims **memory zeroisation** and **constant-time execution**. The only Gleam package marketing those security properties. **Pre-1.0 (v0.0.1) — preview-quality**, 1★.

### Non-cryptographic hashes

For hash maps, dedup, sharding, bloom filters, fingerprinting — NOT for security.

| Criterion | [murmur3a](#murmur3a) | [mumu](#mumu) | [gsiphash](#gsiphash) | [kmh](#kmh) |
| --- | --- | --- | --- | --- |
| Algorithm | Murmur3 32-bit | Murmur3 32-bit | SipHash family | Knuth multiplicative |
| Implementation | Pure Gleam (port of Robin Heggelund Hansen's Elm impl) | FFI wrapper: Erlang NIF on BEAM + vendored `murmurhash-js` on JS | Pure Gleam | Pure Gleam |
| Stars | 0★ (Codeberg) · 🟥 | 1★ · 🟥 | 1★ · 🟥 | 0★ · 🟥 |
| License | MIT · 🟩 | MIT · 🟩 | MIT · 🟩 | LGPL-2.1 · 🟥 |
| Target | ☎️ BEAM + 📜 JS | ☎️ BEAM + 📜 JS | ☎️ BEAM | (unspecified — defaults to JS) |
| Gleam compat | (range) · 🟩 | (range) · 🟩 | (range) · 🟩 | (range) · 🟩 |
| Maintenance | 🟩🟩 (last commit 2026-02-13) | 🟥 (last commit 2024-05-12) | 🟥 (last commit 2024-09-07) | 🟥 (last commit 2024-09-08) |
| README | 🟩 (clear quickstart + JS optimisation note) | 🟩 (clear quickstart) | 🟩 (clear) | 🟩 (clear) |
| Idiomaticity | 🟩 | 🟩 | 🟩 | 🟩 |

> [!NOTE]
> **Why both `murmur3a` and `mumu` exist** — same algorithm (Murmur3 32-bit), same target matrix (BEAM + JS), but **opposite implementation strategies**:
>
> - **`mumu`** ([author Georges Boris](https://github.com/georgesboris/mumu), v1.0.0 published **2024-04-26** — first to land) is a thin **FFI wrapper**: `@external(erlang, ...)` calls the [`harness_erlang_murmurhash`](https://hex.pm/packages/harness_erlang_murmurhash) NIF on BEAM; `@external(javascript, ...)` calls a vendored copy of [Gary Court's `murmurhash3_gc.mjs`](https://github.com/garycourt/murmurhash-js) on JS. Faster on BEAM (NIF), but stale — last commit 2024-05-12 ("go away elixir" — dropped Elixir from the toolchain).
> - **`murmur3a`** ([author eaon](https://codeberg.org/eaon/murmur3a), v0.5.0 published **2025-01-19** — ~9 months later) is a **pure-Gleam port** ("with a little JavaScript optimisation") of [Robin Heggelund Hansen's Elm `murmur3`](https://github.com/robinheghan/murmur3/). One codebase, both targets, zero native deps. Actively maintained — Hayleigh Thompson (`lpil`) opened performance issues [#1](https://codeberg.org/eaon/murmur3a/issues/1) / [#2](https://codeberg.org/eaon/murmur3a/issues/2) on 2026-02-12 and eaon shipped 1.0.2 + 1.0.3 within two days.
>
> Neither README references the other. Looks like **parallel discovery**, not competition or replacement. Output is bit-identical (both are RFC-conforming Murmur3 32-bit). Default to `murmur3a` for active upstream + zero native deps; pick `mumu` only if BEAM-NIF throughput beats the inconvenience of an extra Erlang dep.

#### murmur3a
[hex](https://hex.pm/packages/murmur3a) · [repo](https://codeberg.org/eaon/murmur3a)

**Pure-Gleam port of Murmur3 32-bit** (no FFI; based on Robin Heggelund Hansen's Elm implementation). Provides `hash_string`, `hash_with_seed`, `hex_digest`. Dual-target via a single Gleam codebase — no NIF on BEAM, no vendored JS on the browser. Choose this for active maintenance and zero native dependencies.

```gleam
import murmur3a

pub fn shard_id(key: String) -> Int {
  murmur3a.hash_string(key) % 64
}
```

#### mumu
[hex](https://hex.pm/packages/mumu) · [repo](https://github.com/georgesboris/mumu)

**Murmur3 32-bit via FFI** — `harness_erlang_murmurhash` NIF on BEAM, vendored `murmurhash3_gc.mjs` on JS. Dual-target like `murmur3a`, but each target calls into a battle-tested external implementation rather than running a Gleam port. Returns `Int`. Faster on BEAM via the NIF; comparable on JS. **Stale** — last commit 2024-05-12 (9 commits total).

```gleam
import mumu

pub fn shard_id(key: String) -> Int {
  mumu.hash(key) % 64
}
```

#### gsiphash
[hex](https://hex.pm/packages/gsiphash) · [repo](https://github.com/BrendoCosta/gsiphash)

**SipHash** family — non-cryptographic, but designed to defend hash tables against [collision-flooding DoS](https://en.wikipedia.org/wiki/Collision_attack#Hash_collision_attacks). What Python, Rust, and Ruby use as their default `hash()`. Pure Gleam, BEAM-target.

#### kmh
[hex](https://hex.pm/packages/kmh) · [repo](https://github.com/mdarse/kmh)

**Knuth multiplicative hashing** — cheap integer-keyed hashing for fixed-size hash tables. Depends on `prime`. **LGPL-2.1**, which may be incompatible with closed-source consumers — caveat for proprietary projects.

### HMAC & message signing

#### gleam_crypto (HMAC entry point)

HMAC over MD5/SHA-1/SHA-2 lives in [`gleam_crypto.hmac/3`](#gleam_crypto). There is **no standalone HMAC package** — and no Gleam-native CMAC, KMAC, or Poly1305-as-MAC. For the latter, FFI to Erlang `:crypto.mac/4`.

#### hypersig
[hex](https://hex.pm/packages/hypersig) · [repo](https://codeberg.org/anactualemerald/hypersig)

**HTTP Signature + Digest header** library aimed at ActivityPub (Mastodon-style federated APIs). Produces `Digest:` headers and signs requests per draft-cavage / RFC 9421. Useful as a packaged consumer of hash + HMAC for HTTP signing — the only Gleam library wrapping HMAC in a domain-shaped API.

> [!WARNING]
> `hypersig` is **GPL-3.0-or-later** — incompatible with closed-source distribution. Pick a different signing path for proprietary projects.

#### hashsigs
[repo](https://github.com/ncitron/hashsigs)

**Hash-based signature schemes** (Lamport / Winternitz family — post-quantum primitives) "in pure Gleam." 1★, no license, single-commit stub. Listed for completeness; not production-ready.

### Password hashing

Covered in detail in [authentication.md#password-hashing](authentication.md#password-hashing). Summary:

| Algorithm | Package | Backing |
| --- | --- | --- |
| **Argon2id** (recommended for new code) | [argus](authentication.md#argus) · [antigone](authentication.md#antigone) · [aragorn2](authentication.md#aragorn2) | C reference NIF · Elixir NIF · Rust NIF |
| **bcrypt** | [beecrypt](authentication.md#beecrypt) | Erlang `bcrypt` NIF |
| **PBKDF2** | [pinkdf2](authentication.md#pinkdf2) | `fast_pbkdf2` NIF |
| **scrypt** | *(none)* | FFI to Erlang/Elixir `scrypt` |

> [!IMPORTANT]
> **Never** hash passwords with `gleam_crypto.hash`. SHA-256 is fast — that's the wrong property for password storage. Use a memory-hard KDF (Argon2id is the OWASP 2023+ default).

### Content-addressing & specialty

#### multiformats
[hex](https://hex.pm/packages/multiformats) · [repo](https://github.com/CrowdHailer/multiformats)

**IPFS Content Identifier (CID)** construction — multihash + multibase + multicodec. Currently supports **SHA-256** for the multihash side; pairs naturally with [`gleam_crypto`](#gleam_crypto) for the actual hashing. 4★, BEAM-only.

```gleam
import gleam/crypto
import multiformats/cid
import multiformats/multihash

pub fn content_id(payload: BitArray) -> String {
  let digest = crypto.hash(crypto.Sha256, payload)
  let mh = multihash.new(multihash.Sha2_256, digest)
  cid.new(cid.V1, cid.Raw, mh)
  |> cid.to_string
}
```

#### gleam-merkle
[repo](https://github.com/mazshakibaii/gleam-merkle)

Simple **Merkle tree** implementation, pure Gleam. 0★, no license, single commit — a starting point, not a vetted library. Verify the implementation before depending on it for audit logs / blockchains / certificate transparency.

#### bloomfilter_gleam
[repo](https://github.com/sravan-s/bloomfilter_gleam)

**Bloom filter** (probabilistic membership). README explicitly says *"Trying to implement…"* — incomplete WIP. No license. Roll your own on top of [`gsiphash`](#gsiphash) or [`mumu`](#mumu) instead.

### What's missing

Algorithms with **no Gleam package** and no canonical FFI wrapper. For each, the path is direct FFI to the corresponding Erlang/Elixir Hex package:

| Missing | Why you might want it | FFI path |
| --- | --- | --- |
| **xxHash / xxh3 / xxh64** | Fast non-crypto hash; default in many ecosystems | Elixir [`xxhash`](https://hex.pm/packages/xxhash) |
| **CRC32 / CRC32C** | ZIP, gzip, network protocol checksums | `:erlang.crc32/1` (Erlang stdlib) |
| **Adler-32** | zlib, PNG | `:zlib.adler32/2` (Erlang stdlib) |
| **FNV / FNV-1a** | Cheap string hash for small tables | Elixir [`ex_hash_ring`](https://hex.pm/packages/ex_hash_ring) bundles it; or roll your own |
| **CityHash / FarmHash / wyhash / HighwayHash / SpookyHash / MetroHash / t1ha** | Specialised non-crypto hashes | Per-algorithm Elixir/Erlang Hex package or NIF |
| **Murmur3 128-bit** | When 32-bit collision risk matters | Elixir [`murmur`](https://hex.pm/packages/murmur) (preciz/murmur) |
| **`:erlang.phash2/1,2`** | BEAM-internal term hash for ETS / Map keys | One-line `@external(erlang, "erlang", "phash2")` |
| **RIPEMD-160 / Whirlpool / Tiger / Skein / Groestl** | Legacy or niche cryptographic | Erlang `:crypto.hash/2` supports `ripemd160`; others need NIFs |
| **PASETO** | JWT alternative (saner cipher suite) | Elixir [`paseto`](https://hex.pm/packages/paseto) |
| **CMAC / KMAC / Poly1305-as-standalone-MAC** | MAC schemes other than HMAC | `:crypto.mac/4` (Erlang stdlib) |
| **Perceptual hashing (`phash`/`dhash`/`aHash`)** | Image-similarity / dedup | Elixir [`image`](https://hex.pm/packages/image) provides `phash` |
| **MinHash / SimHash / Rabin fingerprint / rolling hash** | Document similarity, content-defined chunking | None on Hex; port from another language |

## Leaderboard

Score = sum of 7 dimensions (Stars / License / Gleam compat / Maintenance / Age / README / Idiomaticity). Max 13.

| Rank | Package | Score | Highlights |
| --- | --- | --- | --- |
| 🥇 | [gleam_crypto](#gleam_crypto) | **9** | First-party · dual-target · 53★ · MD5/SHA-1/SHA-2 + HMAC + secure-compare + signed messages · the canonical pick |
| 🥈 | [gblake3](#gblake3) | **6** | Dual-target BLAKE3 · only path for BLAKE3 in Gleam · actively maintained |
| 🥈 | [murmur3a](#murmur3a) | **6** | Pure-Gleam Murmur3 port · dual-target via one codebase (no FFI) · actively maintained |
| 🥉 | [multiformats](#multiformats) | **5** | IPFS CID construction · pairs with `gleam_crypto` · only content-addressing path |
| 5 | [sha3 (poulwann)](#sha3-poulwann) | **3** | Closest to a canonical SHA-3 path · wraps Erlang `:crypto` · git-only, 5 commits |
| 5 | [gblake2](#gblake2) | **3** | BLAKE2b/2s · Elixir-NIF wrapper · monorepo-bundled |
| 5 | [glesha](#glesha) | **3** | Redundant with `gleam_crypto`'s SHA-2 support today |
| 5 | [mumu](#mumu) | **3** | Murmur3 via FFI (Erlang NIF + vendored JS) · dual-target · faster on BEAM · stale upstream |
| 5 | [gsiphash](#gsiphash) | **3** | SipHash · pure Gleam · BEAM-only · stale |
| 5 | [pegasus_crypto](#pegasus_crypto) | **3** | BLAKE2b with constant-time + zeroisation claims · v0.0.1 preview |
| 11 | [keccak_gleam](#keccak_gleam) | **0** | Keccak-256 (Ethereum) · Elixir NIF · template-only README · no license |
| 11 | [hypersig](#hypersig) | **0** | HTTP signing for ActivityPub · GPL · niche |
| 13 | [keccaky](#keccaky) | **−1** | Keccak-256 via Rust NIF · git-only · clone-and-build |
| 13 | [kmh](#kmh) | **−1** | Knuth multiplicative · LGPL · niche |
| 13 | [sha3_gleam](#sha3_gleam) | **−1** | Pure-Gleam SHA-3 · author disclaims production use |
| 13 | [hashsigs](#hashsigs) | **−1** | Lamport/Winternitz signature stub · no license |
| 13 | [gleam-merkle](#gleam-merkle) | **−1** | Merkle tree starter · no license · single commit |
| 13 | [bloomfilter_gleam](#bloomfilter_gleam) | **−1** | Bloom filter WIP · no license |

> [!IMPORTANT]
> **The leaderboard is not a recommendation order.** A 9-score canonical library that does SHA-2 cannot do BLAKE3, and a 0-score Keccak-256 wrapper might be the only thing that solves your Ethereum problem. Use the [When to use what](#when-to-use-what) table to pick by job; use the leaderboard to pick **between** competing implementations of the same algorithm.
