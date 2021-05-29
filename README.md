# ic-fungible-token
Basic Fungible/Stackable Token Standard for the IC. Find below the specification, types used and entry points. In future, we want to also explore a secondary more advanced token standard that aligns more with Ethereum's ERC1155 (multi-token standard)

## Rationale
There are a number of proposed standards for tokens on the IC - below is my proposal for a **basic fungible token**. Find below listed the core differences between this token standard and others proposed, as well as my rationale:

1. We use the **AccountIdentifier** as unique token addresses as it better matches with what is being used throughout the ecosystem (exchanges and NNS).
2. This standard is based on **Ethereum's ERC20** as more developers would be accustomed to this standard, improving developer adoption 
3. We removed the **approve call in-favour of the increase/decrease Allowance**. This is a well-known issue with the ERC20 standard, and non-standard calls were added. Instead of adding a broken call from the outset, we'll go straight to the improved allowance model.
4. All metadata has been moved to a **single Metadata type** to keep like data together in a single object, and allow for an additional `metadata()` call.
5. For allowances, we store the **Principal as the spender** as opposed to the AccountIdentifier due to the way addresses work on the IC

## Interface Specification
The ic-fungible-token standard requires the following public entry points:

```
type Token = actor {
  name: query () -> async Text;

  symbol: query () -> async Text;

  decimals: query () -> async Nat8;

  totalSupply: query () -> async Balance;

  metadata: query () -> async Metadata;
  
  balanceOf: query (who : AccountIdentifier) -> async Balance;
  
  allowance: query (owner : AccountIdentifier, spender : Principal) -> async Balance;

  transfer: shared (subaccount : ?SubAccount, recipient : AccountIdentifier, amount : Balance) -> async Bool;

  transferFrom: shared (sender : AccountIdentifier, recipient : AccountIdentifier, amount : Balance) -> async Bool;

  increaseAllowance: shared (spender : Principal, subaccount : ?SubAccount, amount : Balance) -> async Bool;

  decreaseAllowance: shared (spender : Principal, subaccount : ?SubAccount, amount : Balance) -> async Bool;
};
```

## Types

### AccountIdentifier
```
type AccountIdentifier = AID.AccountId;
```
An accountidentifier represents a unique identifier for a user's account, and matches that used across the ICP ecosystem (e.g. by exchanges and the NNS). It is made up of a user's Principal and a 256-bit number representing an SubAccount. 

### SubAccount
```
type SubAccount = AID.SubAccount;
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

## Entry Points

The following entry points must be supported to allow other canisters and 3rd-party consumers the ability to better integrate with the given token.

### Query Calls

**`name: query () -> async Text;`**

Returns the stored name of the token

**`symbol: query () -> async Text;`**

Returns the stored symbol of the token 

**`decimals: query () -> async Nat8;`**

Returns the stored number of decimals of the token

**`totalSupply: query () -> async Balance;`**

Returns the stored token supply of the token

**`metadata: query () -> async Metadata;`**

Returns all metadata for the token

**`balanceOf: query (who : AccountIdentifier) -> async Balance;`**

Returns the balance of `who`.

**`allowance: query (owner : AccountIdentifier, spender : Principal) -> async Balance;`**

Returns the balance of how many tokens `spender` can transfer on behalf of `owner`.

### Update Calls

**`transfer: shared (subaccount : ?SubAccount, recipient : AccountIdentifier, amount : Balance) -> async Bool;`**

Generates an AccountIdentifier based on the caller's Principal and the provided SubAccount*, and then attempts to transfer `amount` from the generated AccountIdentifier to `recipient`, and returns the outcome as a bool.

<sub>* If SubAccount is null, we use the default sub account (SUBACCOUNT_ZERO).</sub>

**`transferFrom: shared (sender : AccountIdentifier, recipient : AccountIdentifier, amount : Balance) -> async Bool;`**

Asserts that the caller is approved to send `amount`, and then attempts to transfer `amount` from `sender` to `recipient`, and returns the outcome as a bool. 

**`increaseAllowance: shared (spender : Principal, subaccount : ?SubAccount, amount : Balance) -> async Bool;`**

Generates an AccountIdentifier based on the caller's Principal and the provided SubAccount*, and then attempts to increase the allowance of the `spender` by `amount` for the generated AccountIdentifier, and then returns the outcome a bool.

<sub>* If SubAccount is null, we use the default sub account (SUBACCOUNT_ZERO).</sub>

**`decreaseAllowance: shared (spender : Principal, subaccount : ?SubAccount, amount : Balance) -> async Bool;`**

Generates an AccountIdentifier based on the caller's Principal and the provided SubAccount*, and then attempts to decrease the allowance of the `spender` by `amount` for the generated AccountIdentifier, and then returns the outcome a bool.

<sub>* If SubAccount is null, we use the default sub account (SUBACCOUNT_ZERO).</sub>
