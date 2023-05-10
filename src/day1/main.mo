import Int "mo:base/Int";
import Float "mo:base/Float";
actor class Calculator() {
  // Step 1 -  Define a mutable variable called `counter`.
  var counter : Float = 0;

  // Step 2 - Implement add
  public func add(x : Float) : async Float {
    counter := counter + x;
    return counter;
  };

  // Step 3 - Implement sub
  public func sub(x : Float) : async Float {
    counter := counter - x;
    return counter;
  };

  // Step 4 - Implement mul
  public func mul(x : Float) : async Float {
    counter := counter * x;
    return counter;
  };

  // Step 5 - Implement div
  public func div(x : Float) : async Float {
    counter := counter / x;
    return counter;
  };

  // Step 6 - Implement reset
  public func reset() : async () {
    counter := 0;
  };

  // Step 7 - Implement query
  public query func see() : async Float {
    return counter;
  };

  // Step 8 - Implement power
  public func power(x : Float) : async Float {
    counter := Float.pow(counter, x);
    return counter;
  };

  // Step 9 - Implement sqrt
  public func sqrt() : async Float {
    return Float.sqrt(counter);
  };

  // Step 10 - Implement floor
  public func floor() : async Int {
    return Float.toInt(Float.floor(counter));
  };
};
