import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Iter "mo:base/Iter";

import IC "Ic";
import HTTP "Http";
import Type "Types";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;
  stable var studentProfileStoreEntries : [(Principal, StudentProfile)] = [];
  let studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(10, Principal.equal, Principal.hash);

  system func preupgrade() {
    studentProfileStoreEntries := Iter.toArray(studentProfileStore.entries());
  };

  system func postupgrade() {
    for((studentPrincipal, studentProfile) in studentProfileStoreEntries.vals()){
      studentProfileStore.put(studentPrincipal, studentProfile);
    };
  };
  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    studentProfileStore.put(caller, profile);
    return #ok();
  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    let student = studentProfileStore.get(p);
    switch(student){
      case(null){
        return #err("Student not found");
      };
      case(?student){
        return #ok(student);
      }
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    let student = studentProfileStore.get(caller);
    switch(student){
      case(null){
        return #err("Student not found");
      };
      case(?student){
        studentProfileStore.put(caller, profile);
        return #ok();
      }
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    let student = studentProfileStore.get(caller);
    switch(student){
      case(null){
        return #err("Student not found");
      };
      case(?student){
        studentProfileStore.delete(caller);
        return #ok();
      }
    };
  };


  // STEP 1 - END

  // STEP 2 - BEGIN
  type calculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public func test(canisterId : Principal) : async TestResult {
    let studentCanister = actor (Principal.toText(canisterId)) : actor {
      add : shared (n : Int)-> async Int;
      sub : shared (n : Nat)-> async Int;
      reset : shared ()-> async Int;
    };
    try {
      let addResult = await studentCanister.add(4);
      if(addResult != 4){
        return #err(#UnexpectedValue("Somthing went wront with the add method"));
      };
      let subResult = await studentCanister.sub(2);
      if(subResult != 2){
        return #err(#UnexpectedValue("Somthing went wront with the sub method"));
      };
      let resetResult = await studentCanister.reset();
      if(resetResult != 0){
        return #err(#UnexpectedValue("Somthing went wront with the reset method"));
      };
      return #ok();
    } catch e {
      return #err(#UnexpectedError("An unexpected error ocurred when calling calculator canister"));
    }
  };
  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally
  func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };

  public func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
    let managementCanister : IC.ManagementCanisterInterface = actor("aaaaa-aa");
    try {
      let canisterStatus = await managementCanister.canister_status({ canister_id = canisterId });
      let canisterControllers = canisterStatus.settings.controllers;
      for (controller in canisterControllers.vals()){
        if(controller == p){
          return true;
        };
      };
      return false;
    } catch (e) {
      let message = Error.message(e);
      let controlers = parseControllersFromCanisterStatusErrorIfCallerNotController(message);
      for (controller in controlers.vals()){
        if(controller == p){
          return true;
        };
      };
      return false;
    }
  };
  // STEP 3 - END

  // STEP 4 - BEGIN
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
    let isItTheOwner : Bool = await verifyOwnership(canisterId, p);
    if(isItTheOwner){
      let canisterTest : Type.TestResult = await test(canisterId);
      switch(canisterTest){
        case (#ok()){
          var hasProfile = studentProfileStore.get(p);
          switch(hasProfile){
            case (?studentProfile){
              let graduatedProfile = {
                name = studentProfile.name;
                team = studentProfile.team;
                graduate = true;
              };
              studentProfileStore.put(p, graduatedProfile);
              return #ok();
            };
            case (null){
              return #err("The principal has not a registered profile");
            };
          };
        };
        case (#err(_)){
          return #err("The canister does not pass the test");
        };
      };
    } else {
      return #err("The caller isn't the owner of the canister");
    };
  };
  // STEP 4 - END

  // STEP 5 - BEGIN
  public type HttpRequest = HTTP.HttpRequest;
  public type HttpResponse = HTTP.HttpResponse;

  // NOTE: Not possible to develop locally,
  // as Timer is not running on a local replica
  public func activateGraduation() : async () {
    return ();
  };

  public func deactivateGraduation() : async () {
    return ();
  };

  public query func http_request(request : HttpRequest) : async HttpResponse {
    return ({
      status_code = 200;
      headers = [];
      body = Text.encodeUtf8("");
      streaming_strategy = null;
    });
  };
  // STEP 5 - END
};
