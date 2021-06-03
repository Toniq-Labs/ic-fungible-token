# ic-fungible-token
Basic Fungible/Stackable Token Standard for the IC. Find below the specification, types used and entry points. In future, we want to also explore a secondary more advanced token standard that aligns more with Ethereum's ERC1155 (multi-token standard)

## Rationale
There are a number of proposed standards for tokens on the IC - below is my proposal for a **basic fungible token**.

1. We include the **AccountIdentifier** as unique token addresses for sideways-compatiability with ICP
2. Receivers can be #accounts (AccountIdentifiers), #principals, or #canisters 
3. We adopted a transferAndCall approach, allowing the submission of a callback function (no need for approvals)
4. This approach gives canister developers more control of how they want to integrate with tokens
5. Canisters can reject transfers

## Interface Specification
The ic-fungible-token standard requires the following public entry points:

```
type Token = actor {
  totalSupply: query () -> async Balance;

  metadata: query () -> async Metadata;
  
  balanceOf: query (who : TokenHolder) -> async Balance;
  
  transfer: shared (subaccount : ?SubAccount, recipient : Receiver, amount : Balance) -> async TransferResponse;
  
  subscribe: shared (callback : Callback) -> ();

  unsubscribe : shared () -> ();
};
```

## Types

### AccountIdentifier
```
type AccountIdentifier = AID.AccountIdentifier; //Text
```
An Accountidentifier represents a unique identifier for a user's account, and matches that used across the ICP ecosystem (e.g. by exchanges and the NNS). It is made up of a user's Principal and a 256-bit number representing a SubAccount. Ths comes fro the [motoko-accountid library](https://github.com/stephenandrews/motoko-accountid)

### SubAccount
```
type SubAccount = AID.SubAccount; //[Nat8]
```
As above, the SubAccount allows for a single principal to control 2^256 different accounts.

### Metadata
```
type Metadata = {
  name : Text;
  
  decimals : Nat8;
  
  symbol : Text;
};
```
This type contains all metadata related to this token, and the above constitutes the minimum expected fields to abide by this standard. This allows external consumers to provide user-friendly experiences to end users.

### Balance
```
type Balance = Nat;
```
Simple type to represent an amount of the token (e.g. amount to send or an existing balance).

### Callback (for canisters)
```
//msg.caller, subaccount, amount
type Callback = shared (Principal, ?SubAccount, Balance) -> async Bool;
```
This represents a callback that should exist within the receiving canister which is called during the transaction. If this function returns false, the tx is rejected and returned to the sender.

### Token Holders
```
type TokenHolder = {
  #account : AccountIdentifier;
  #principal : Principal;
};
```
This represents something that may hold tokens, either a principal or an accountid.

### Receiver
```
type Receiver = {
  #account : AccountIdentifier;
  #principal : Principal;
  #canister : {
    principal : Principal;
    callback : ?Callback;
  };
};
```
This allows for a range of receivers to be defined. We support AccountIdentifier to allow sending to ICP/NNS addresses, as well as sending to a Principal. For smart canisters, we can use the #canister variant. If no callback is provided, we will lookup if a callback has been subscribed. If a callback is provided BUT the smart canister has subscribed, than we also fail (we do not allow user provided callbacks when a subscribed one exists).

### Transfer Response
```
type TransferResponse = {
  #ok;
  #err : {
    #InsufficientBalance;
    #RejectedByCanister;
    #NoSubscribedCallback;
    #CallbackInvalid; //Can't use a custom callback for an subscriber
  }
};
```
This represents a response to a transfer, #ok if successful, otherwise an error.

## Entry Points

The following entry points must be supported to allow other canisters and 3rd-party consumers the ability to better integrate with the given token.

### Query Calls

**`totalSupply: query () -> async Balance;`**

Returns the stored token supply of the token

**`metadata: query () -> async Metadata;`**

Returns all metadata for the token

**`balanceOf: query (who : TokenHolder) -> async Balance;`**

Returns the balance of `who`.

### Update Calls

**`transfer: shared (subaccount : ?SubAccount, recipient : Receiver, amount : Balance) -> async TransferResponse;`**

Generates an AccountIdentifier based on the caller's Principal and the provided SubAccount*, and then attempts to transfer `amount` from the generated AccountIdentifier to `recipient`, and returns the outcome as TransferResponse. `recipient` can be an AccountIdentitifer, a Principal (which then transfers to the default subaccount), or a canister (where a callback is triggered).

<sub>* If SubAccount is null, we use the default sub account (SUBACCOUNT_ZERO).</sub>

**`subscribe: shared (callback : Callback) -> ();`**

Subscribes the caller and adds sets the callback to be used in future for the caller. If already subscribed, this replaces the previous callback. (i.e. only one callback per principal). Note: this will prevent transfer's where a custom callback is provided.

**`unsubscribe : shared () -> ();`**

Unsubscribes the caller. Transfer's which trigger a callback must be provided by the sender in the transfer.


