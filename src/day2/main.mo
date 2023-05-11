import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";

import Type "Types";

actor class Homework() {
  type Homework = Type.Homework;

  let homeworkDiary = Buffer.Buffer<Homework>(10);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    var index : Nat = homeworkDiary.size();
    homeworkDiary.add(homework);
    return index;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    var lastIndex : Nat = homeworkDiary.size() - 1;
    if(id > lastIndex){
      return #err("Not Found");
    };
    return #ok(homeworkDiary.get(id));
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    var lastIndex : Nat = homeworkDiary.size() - 1;
    if(id > lastIndex){
      return #err("Not Found");
    };
    homeworkDiary.put(id, homework);
    return #ok();
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    var lastIndex : Nat = homeworkDiary.size() - 1;
    if(id > lastIndex){
      return #err("Not Found");
    };
    var completedHomeWork = homeworkDiary.get(id);
    object markHomeWork {
      public let title = completedHomeWork.title;
      public let description = completedHomeWork.description;
      public let dueDate = completedHomeWork.dueDate;
      public let completed = true;
    };
    homeworkDiary.put(id, markHomeWork);
    return #ok();
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    var lastIndex : Nat = homeworkDiary.size();
    if(id >= lastIndex){
      return #err("Not Found");
    };
    let indexRemoved = homeworkDiary.remove(id);
    return #ok();
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray(homeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    let allHomework = Buffer.toArray(homeworkDiary);
    let pendingHomework = Array.filter<Homework>(allHomework, func x = x.completed == false);
    return pendingHomework;
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    var homeworkList = Buffer.Buffer<Homework>(10);
    var counter : Nat = 0;
    for(homework in homeworkDiary.vals()){
      if(searchTerm == homework.title){
        homeworkList.add(homeworkDiary.get(counter));
      };
      counter += 1;
    };
    return Buffer.toArray(homeworkList);
  };
};
