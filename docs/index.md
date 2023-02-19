#<center>— C++ testing made simple —</center>


=== "A simple test"
    ``` cpp
    #include <cest>

    describe("A mars rover", []() {
      it("can go forward", []() {
        MarsRover rover(0,0);

        rover.move(Direction::Forward);

        expect(rover.position.x).toBe(1);
      });
    });
    ```
=== "Working with exceptions"
    ``` cpp
    #include <cest>

    describe("Discount vouchers", []() {
      it("can only have positive discount", []() {
        assertRaises<InvalidDiscountException>() {
          DiscountVoucher voucher(-30);
        }
      });
    });
    ```
=== "Advanced collection features"
    ``` cpp
    #include <cest>

    describe("Message queue", []() {
      it("can contain multiple messages", []() {
        std::vector<string> pendingData { "<header>", "20 apples" };

        expect(pendingData).toHaveLength(2);
        expect(pendingData).toContain("<header>);
        expect(pendingData[1]).toMatch(Regex(".*\\d+ apples"));
      });
    });
    ```
=== "Parametrized tests"
    ``` cpp
    #include <cest>

    describe("Hardware Version register", []() {
      it("is mirrored in two addresses in the memory map", []() {
        withParameter<uint32_t *>().
          withValue(0x00A1000F).
          withValue(0xFFA1000F).
          thenDo([](uint32_t *address) {
            uint32_t version = *address;
            expect(version).toBe(123);
          });
      });
    });
    ```

# <center>Main features</center>

### :material-source-branch: Single Header
All features are included in a single C++ header,
making it easy to integrate into any project's existing pipeline. Just include `cest` in each test file to compile a self-contained and runnable test

### :material-lightbulb-on: BDD inspired API
Using from `it` to `expect`, write your tests
as you would in JavaScript, Python or Ruby. One of the main objectives of Cest is slashing the learning curve towards C++ testing. No more esoteric syntax in C++ tests!

### :fontawesome-solid-wand-magic-sparkles: Feature rich from the get-go
Includes exception handling assertions, parametrized tests, pointer assertions, integration with STL collections, and more. Want more? Planned features include parametric tests, extended collection support, async support, and more

# <center>Why yet another testing framework?</center>
