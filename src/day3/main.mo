import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Blob "mo:base/Blob";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Int "mo:base/Int";

actor class StudentWall() {
  type Hash = Hash.Hash;
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;

  stable var messageId : Nat = 0;
  func _hashNat(n : Nat) : Hash {
    Text.hash(Nat.toText(n));
  };
  var wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, _hashNat);

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    let id : Nat = messageId;
    messageId+=1;
    let newMessage : Message = {
      content = c;
      vote = 0;
      creator = caller;
    };
    wall.put(id, newMessage);
    return id;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    let requestedMessage : ?Message = wall.get(messageId);
    switch(requestedMessage){
      case(null){
        return #err("Message not found");
      };
      case(?currentMessage){
        return #ok(currentMessage);
      };
    };
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    let requestedMessage : ?Message = wall.get(messageId);
    switch(requestedMessage){
      case(null){
        return #err("Message not found");
      };
      case(?currentMessage){
        if(currentMessage.creator == caller){
          let updatedMessage : Message = {
            content = c;
            vote = currentMessage.vote;
            creator = currentMessage.creator;
          };
          wall.put(messageId, updatedMessage);
          return #ok();
        } else  {
          return #err("Wrong sender");
        }
      };
    };
  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let requestedMessage : ?Message = wall.get(messageId);
    switch(requestedMessage){
      case(null){
        return #err("Message not found");
      };
      case(?currentMessage){
        ignore wall.remove(messageId);
        return #ok();
      };
    };
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    let requestedMessage : ?Message = wall.get(messageId);
    switch(requestedMessage){
      case(null){
        return #err("Message not found");
      };
      case(?currentMessage){
        let updatedMessage : Message = {
          content = currentMessage.content;
          vote = currentMessage.vote + 1;
          creator = currentMessage.creator;
        };
        wall.put(messageId, updatedMessage);
        return #ok();
      };
    };
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    let requestedMessage : ?Message = wall.get(messageId);
    switch(requestedMessage){
      case(null){
        return #err("Message not found");
      };
      case(?currentMessage){
        let updatedMessage : Message = {
          content = currentMessage.content;
          vote = currentMessage.vote - 1;
          creator = currentMessage.creator;
        };
        wall.put(messageId, updatedMessage);
        return #ok();
      };
    };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    let messagesList = Buffer.Buffer<Message>(1);
    for ((key, value) in wall.entries()){
      messagesList.add(value);
    };
    return Buffer.toArray(messagesList);
  };

  // Get all messages ordered by votes
  public func getAllMessagesRanked() : async [Message] {
    let messagesList = Buffer.Buffer<Message>(1);
    for ((key, value) in wall.entries()){
      messagesList.add(value);
    };
    let sortedMessagesListArray = Array.sort<Message>(Buffer.toArray(messagesList),func (x, y) = Int.compare(y.vote, x.vote) );
    return sortedMessagesListArray;
  };
};
