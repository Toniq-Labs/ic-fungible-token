# ic-fungible-token
Basic Fungible/Stackable Token Standard for the IC. This does not allow for multiple transfers in a single transaction

## Interface Specification
The ic-fungible-token standard requires the following data types/public entry points:

```
type Address = AID.AccountId; // Text
type SubAccount = AID.SubAccount; // [Nat8]
type Balance = Nat;
type MetaData = {
  name : Text;
  
  totalSupply : Nat;
  
  decimals : Nat8;
  
  symbol : Text;
  
  //Any other data can be included here too
};
type TransferRequest = {
  principal: ?Principal;
  subaccount: ?SubAccount;
  to: Address;
  amount: Balance;
};

type Token = actor {
  balanceOf: query (who : Address) -> async Balance;
  
  allowance: query (owner : Address, spender : Principal) -> async Balance;

  metadata: query () -> async MetaData;

  transfer: shared (TransferRequest) -> async Bool;

  approve: shared (spender : Principal, subaccount : ?SubAccount, amount : Balance) -> async Bool;
};
```
**balanceOf**
Takes single input who (address) and returns the current balance

**allowance**
Takes input owner (address) and spender (principal) and returns the balance of how many tokens spender can transfer on behalf of owner.

**Note:** Spenders are principals as they are the ones calling the canister

**metadata**
Takes no input and returns metadata for the token

**transfer**
Takes single input of TransferRequest and returns true if transfer is successful, otherwise false.

TransferRequest is made up of the principal (either null to send from the current principals account, or 

**approve**
