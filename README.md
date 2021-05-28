# ic-fungible-token
Basic Fungible/Stackable Token Standard for the IC. This does not allow for multiple transfers in a single transaction

## Rationale
There are a number of proposed standards for tokens on the IC - below is my proposal for a basic fungible token. Find below listed the core differences between this token standard and others proposed, as well as my rationale:

1. I have decided to use the **AccountIdentifier** as unique token addresses as it better aligns with what is being used throughout the ecosystem (exchanges and NNS).
2. I have decided to align this standard to be closer to **Ethereum's ERC20** as more developers would be use to this standard, improving developer adoption 
3. I have removed the **approve call in-favour of the increase/decrease Allowance**. This is a well known issue with the ERC20 standard, and non-standard calls were added. Instead of adding a broken call from the outset, we'll go straight to the improved allowance model.
4. All metadata has been moved to a single Metadata type to keep like data together in a single object.
5. For allowances, we store the Principal as the spender (as these will be the actual canister callers).

## Interface Specification
The ic-fungible-token standard requires the following data types/public entry points:

```
type Token = actor {
  balanceOf: query (who : AccountIdentifier) -> async Balance;
  
  allowance: query (owner : AccountIdentifier, spender : Principal) -> async Balance;

  metadata: query () -> async Metadata;

  name: query () -> async Tet;

  symbol: query () -> async Text;

  decimals: query () -> async Nat8;

  totalSupply: query () -> async Balance;

  transfer: shared (subaccount : ?SubAccount, to : AccountIdentifier, amount : Balance) -> async Bool;

  transferFrom: shared (from : AccountIdentifier, to : AccountIdentifier, amount : Balance) -> async Bool;

  increaseAllowance: shared (spender : Principal, subaccount : ?SubAccount, amount : Balance) -> async Bool;

  decreaseAllowance: shared (spender : Principal, subaccount : ?SubAccount, amount : Balance) -> async Bool;
};
```

## Types

### AccountIdentifier
```
type AccountIdentifier = AID.AccountId;
```
An accountidentifier represents a unique identifier for a users account, and matches that used across the ICP ecosystem (e.g. by exchanges and the NNS). It is made up of a users Principal and a 256-bit number representing an SubAccount. 

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
This type contains all metadata related to this token, and the above constitutes the minimum expected fields to abide by this standard. This allows external consumers to provide userfriendly experiences to end users.

### Balance
```
type Balance = Nat;
```
Simple type to represent an amount of the token (e.g. amount to send or an existing balance).

## Entry Points

### Query Calls

**balanceOf (AccountIdentifier) -> Balance**

Takes single input who (AccountIdentifier) and returns the current balance for who

**allowance (AccountIdenfitier, Principal) -> Balance**

Takes input owner (AccountIdenfitier) and spender (Principal) and returns the balance of how many tokens spender can transfer on behalf of owner.

**metadata () -> Metadata**

Takes no input and returns metadata for the token

**name () -> Text**

Takes no input and returns the stored name of the token

**symbol () -> Text**

Takes no input and returns the stored symbol of the token 

**decimals () -> Nat8**

Takes no input and returns the stored number of decimals of the token

**totalSupply () -> Nat**

Takes no input and returns the stored token supply of the token

### Update Calls

**transfer (?SubAccount, AccountIdentifier, Balance) -> Bool**

Generates a from address based on the caller's Principal and the provided SubAccount. If SubAccount is null, we use the default account (SUB_ACCOUNT_ZERO). We then attemp to transfer Balance from the users address to the specified AccountIdentifier.

**transferFrom (AccountIdentifier/from, AccountIdentitifer/to, Balance) -> Bool**

Attempt to transfer Balance from the from account to the to account. The caller must be approved to send the Balance.

**increaseAllowance (Principal, ?SubAccount, Balance) -> Bool**

Generates a from address based on the caller's Principal and the provided SubAccount. If SubAccount is null, we use the default account (SUB_ACCOUNT_ZERO). We then increases the allowance of the spender (Principal) by Balance. This is a safe call that will only ever increase allowance.

**decreaseAllowance (Principal, ?SubAccount, Balance) -> Bool**

Generates a from address based on the caller's Principal and the provided SubAccount. If SubAccount is null, we use the default account (SUB_ACCOUNT_ZERO). We then decrease the allowance of the spender (Principal) by Balance. This is a safe call that will only ever decrease allowance.
