type AccountIdentifier = Text;
type Balance = Nat;
type SubAccount = [Nat8];
type Metadata = {
  name : Text;
  symbol : Text;
  decimals : Nat8;
};
//msg.caller, subaccount, amount
type Callback = shared (Principal, ?SubAccount, Balance) -> async Bool;

type Receiver = {
  #account : AccountIdentifier;
  #principal : Principal;
  #canister : {
    principal : Principal;
    callback : ?Callback;
  };
};

type TokenHolder = {
  #account : AccountIdentifier;
  #principal : Principal;
};

type TransferResponse = {
  #ok;
  #err : {
    #InsufficientBalance;
    #RejectedByCanister;
    #NoSubscribedCallback;
    #CallbackInvalid; //Can't use a custom callback for an subscriber
  }
};

type Token = actor {
  totalSupply: query () -> async Balance;

  metadata: query () -> async Metadata;
  
  balanceOf: query (who : TokenHolder) -> async Balance;
  
  transfer: shared (subaccount : ?SubAccount, recipient : Receiver, amount : Balance) -> async TransferResponse;
  
  subscribe: shared (callback : Callback) -> ();

  unsubscribe : shared () -> ();
};
