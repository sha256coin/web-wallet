# Importing a private key from the S256 Web-Wallet into S256 Core

Status: the `wpkh` import (`s21` address) has been tested on S256 Core with a descriptor wallet and the GUI console. Sending from the imported wallet (change address) was tested on regtest on 2026-11-07. The `pkh` variant for `S` addresses has not been tested.

This guide shows how to move a key you exported from the S256 mobile or web wallet into S256 Core. Core creates descriptor wallets, so the older `importprivkey` command does not work. You use `importdescriptors` instead.

> **Read this first**
> - **Never share your private key or seed phrase with anyone.** Not in a chat, not with a person offering help, not on a website. Anyone who sees it can take your coins.
> - **Test with a small amount first.**
> - **Use a new, blank wallet for the import,** not your main Core wallet. A key added to a descriptor wallet cannot be removed later.
> - Anything you type in the console may stay in its history. When you are finished, move the funds (step 8) and restart Core.
> - This is a community guide, provided as is. No support is offered, and you are responsible for your own funds.

## What you need

- S256 Core, fully synced (`getblockchaininfo` shows `verificationprogress` close to 1)
- The private key exported from the wallet, as a single string (WIF). **Seed phrases cannot be imported into Core; only the private key can.**
- Not a pruned node. A pruned node cannot rescan old blocks.

## Steps

Type the commands in the Core console (Window > Console), or use `sha256coin-cli -rpcwallet=importtest <command>`.

**1. Create a new wallet that can hold private keys**

```
createwallet "importtest"
```

Do not make it blank (`createwallet "importtest" false true`). A blank wallet has no keys of its own, and then Core cannot create a change address: sending fails with `Transaction needs a change address, but we can't generate it. Error: No bech32 addresses available.` A single imported key cannot be set as the active (change) descriptor, because only ranged descriptors can be active. A normal wallet generates its own change keys, so sending works.

**2. Check that you are using it**

In the GUI, select `importtest` in the wallet dropdown at the top of the console. Then run:

```
getwalletinfo
```

`walletname` must say `importtest`. If it does not, stop and select the right wallet. Otherwise the key goes into another wallet.

**If more than one wallet is loaded** (check with `listwallets`), creating `importtest` does not switch the console to it. Select `importtest` in the dropdown at the top of the console window again, and run `getwalletinfo` once more to confirm before you continue. Commands typed while another wallet is selected run against that wallet, which is also where the "enter the wallet passphrase" error comes from if that wallet is encrypted.

**3. Get the checksum for your descriptor**

Replace `<WIF>` with your key:

```
getdescriptorinfo "wpkh(<WIF>)"
```

Copy the value next to `"checksum"`. Do not use the `#...` at the end of the `"descriptor"` line; that one is for the public version and will fail.

`wpkh` is for addresses that start with `s21`. If your address starts with `S`, use `pkh(<WIF>)` instead. That variant has not been tested here.

**4. Import the key**

```
importdescriptors '[{"desc":"wpkh(<WIF>)#<checksum>","timestamp":0,"label":"test"}]'
```

The result should contain `"success": true`. The `timestamp` of `0` makes Core scan the whole chain.

**5. Wait for the rescan**

```
getwalletinfo
```

The `scanning` field shows progress and turns `false` when it is done. Do not close Core in the meantime. The balance shows zero until the scan is finished, so a zero balance during the scan means nothing.

**6. Check the result**

```
getbalance
listunspent
getaddressinfo <your address from the app>
```

`ismine` should be `true` and the balance should match the wallet.

**7. Sending from this wallet**

In a normal wallet, sending works as usual. Change goes to a new address of this wallet's own keys, not to your imported address. So this wallet now holds funds under two kinds of keys: back it up (Core menu: File > Backup Wallet) and protect it with `encryptwallet`.

If you made a blank wallet before reading this and sending fails with the change-address error, you do not have to start over. Either:

- in the GUI, set a **custom change address**, for example your imported address. The change then comes back to the same address, as in the mobile wallet. Coin control is hidden by default: first tick Settings > Options > Wallet > "Enable coin control features" (restart if asked). Then on the Send tab click "Inputs..." and tick "Custom change address", or
- import the same key into a new non-blank wallet as above.

The `sendall` command in step 8 needs no change address either.

**8. Move the funds to a wallet only you control**

The key was typed into a console, so treat it as exposed. Send everything to a new address in a Core wallet you have protected with a passphrase (`encryptwallet`), or to a wallet you create fresh:

```
sendall '["<new address>"]'
```

Wait for a confirmation and check the balance at the new address. Then run `unloadwallet importtest`, delete the `importtest` wallet folder, and restart Core. Stop using the old wallet, since its key is now known to you at least in plain text.

## Troubleshooting

| Problem | Likely cause |
|---|---|
| `Please enter the wallet passphrase` | The console is on an encrypted wallet, not `importtest`. Select the right wallet. |
| Checksum error | You used the checksum from the `"descriptor"` line, or you changed the key after generating it. Run `getdescriptorinfo` again. |
| `getdescriptorinfo` reports an invalid key | The exported key is not in WIF format for S256 (the S256 WIF prefix is `0xBF`). |
| Import succeeds but the balance is zero | The rescan is still running, the node is not fully synced, the node is pruned, or the address type is wrong. Run `deriveaddresses` on the public descriptor and compare it with your address. |
| `Transaction needs a change address, but we can't generate it` / `No bech32 addresses available` when sending | The wallet was created blank. Use a non-blank wallet (step 1), or set a custom change address in coin control (step 7). |
| `ismine` is `false` | The descriptor type does not match your address. Try the other type. |

## Notes

- Seed phrases work only in wallets that use the same derivation as the S256 Wallet (BIP39, first address of `m/44'/0'/0'/0/0`, shown as an `s21` address). Core does not import them.
- Your funds live on the blockchain. The key is what controls them, and this method lets you use it in Core without the wallet apps or their servers.
