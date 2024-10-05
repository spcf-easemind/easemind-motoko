import Map "mo:map/Map";
import { phash } "mo:map/Map";
import { thash } "mo:map/Map";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Source "mo:uuid/async/SourceV4";
import UUID "mo:uuid/UUID";

actor {
  // Message
  type MessageResult = {
    message : Text;
  };

  //* TYPES
  type User = {
    id : Text;
    nickname : Text;
    achievementsId : Text;
    points : Float;
  };

  type Achievement = {
    emoji : Text;
    title : Text;
    description : Text;
    multiplier : Float;
    tradable : Bool;
  };

  type Task = {
    id : ?Text;
    title : Text;
    description : Text;
    emoji : Text;
    timeStart : Text;
    timeEnd : Text;
    timeOfDay : {
      #Morning;
      #Afternoon;
      #Evening;
    };
    taskType : {
      #DistanceBased;
      #StepBased;
      #TimeBased;
    };
    maxValue : Nat;
  };

  type UserTask = Task and {
    progress : Float;
    maxValue : Float;
    isCompleted : Bool;
  };

  type UserAchievement = {
    userId : Text;
    fullName : Text;
    achievementList : [Achievement];
  };

  type UserDetails = {
    id : Text;
    nickname : Text;
  };

  type updateUsername = {
    nickname : Text;
    message : Text;
  };

  //* UUID Generator
  func generateUUID() : async Text {
    let g = Source.Source();
    return UUID.toText(await g.new());
  };

  //* STABLE HASH-MAP
  stable let users = Map.new<Principal, User>();
  stable let achivementList = Map.new<Text, Achievement>();
  stable let userAchievements = Map.new<Text, Achievement>();
  stable let morningTaskList = Map.new<Text, Task>();
  stable let afternoonTaskList = Map.new<Text, Task>();
  stable let eveningTaskList = Map.new<Text, Task>();

  // Needed to get the principal id of the user
  public shared (msg) func whoami() : async Principal {
    msg.caller;
  };

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

  //* USER
  public shared ({ caller }) func createUser(payload : User) : async Result.Result<MessageResult and { id : Text }, MessageResult> {
    if (Principal.isAnonymous(caller)) {
      return #err({ message = "Anonymous identity found!" });
    };

    if (Map.contains(users, phash, caller) != null) {
      return #err({ message = "User already exist!" });
    };

    // Generate user id
    let userId : Text = await generateUUID();

    // Generate user achievements id
    let achievementsId : Text = await generateUUID();

    let newUser : User = {
      id = userId; // Ensure this is optional
      nickname = payload.nickname;
      achievementsId = achievementsId; // Ensure this is optional
      points = 0.0;
    };

    // Create new user
    switch (Map.add(users, phash, caller, newUser)) {
      case (null) {
        return #ok({
          message = "User account created successfully!";
          id = userId;
        });
      };
      case (?user) {
        return #err({ message = "User already exists!" });
      };
    };
  };

  // Update User nickname
  public shared ({ caller }) func updateUserNickname(newUsername : User) : async Result.Result<MessageResult, MessageResult> {
    switch (Map.get(users, phash, caller)) {
      case (null) {
        return #err({ message = "user not found" });
      };
      case (?user) {
        let newUserNickname : User = {
          id = user.id;
          nickname = newUsername.nickname;
          achievementsId = user.achievementsId;
          points = user.points;
        };

        Map.set(users, phash, caller, newUserNickname);
        return #ok({ message = "User nickname updated successfully!" });
      };
    };
  };

  // Get specific user
  public func getUser(principal : Principal) : async Result.Result<UserDetails, MessageResult> {
    switch (Map.get(users, phash, principal)) {
      case (null) {
        return #err({ message = "No user found" });
      };
      case (?user) {
        return #ok({
          id = user.id; // Fetch the user id
          nickname = user.nickname; // Fetch the user nickname
        });
      };
    };
  };

};
