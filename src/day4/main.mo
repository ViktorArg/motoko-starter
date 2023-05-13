import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";

import Account "Account";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
// Local canister: be2us-64aaa-aaaaa-qaabq-cai

actor class MotoCoin() {
  public type Account = Account.Account;
  let ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);
  let studentBootCamp = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
    getAllStudentsPrincipal : shared ()-> async [Principal];
  };
  // Returns the name of the token
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    var ledgerTotalSupply : Nat = 0;
    for (balance in ledger.vals()){
      ledgerTotalSupply += balance;
    };
    return ledgerTotalSupply;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    switch(ledger.get(account)){
      case(null){
        return 0;
      };
      case(?balance){
        return balance;
      }
    }
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    var fromBalance = Option.get(ledger.get(from), 0);
    var toBalance = Option.get(ledger.get(to), 0);
    fromBalance := fromBalance - amount;
    toBalance := toBalance + amount;
    if(fromBalance < amount){
      return #err("Sender's account has insufficient funds")
    } else {
      ledger.put(from, fromBalance);
      ledger.put(to, toBalance);
      return #ok;
    }
  };

  // Airdrop 100 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    try {
      let principalList = await studentBootCamp.getAllStudentsPrincipal();
      for (principal in principalList.vals()){
        let studentAccount : Account = 
          { owner = principal;
            subaccount = null;
          };
        let actualBalance = Option.get(ledger.get(studentAccount), 0);
        let newBalance = actualBalance + 100;
        ledger.put(studentAccount, newBalance);
      };
      return #ok();
    } catch e {
      #err("There was an error during the airdrop and couldn't be completed");
    }
  };
};
