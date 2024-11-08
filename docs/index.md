#<center>C++ testing made simple</center>


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
=== "Nested test suites"
    ```cpp
    #include <cest>

    describe("DatabaseConnector", []() {
      describe("connect()", []() {
        it("succeeds at connecting to host", []() {
          auto result = DatabaseConnector().connect();
          expect(result).toEqual(Result::SUCCESS);
        });
      });

      describe("disconnect()", []() {
        it("fails to disconnect if not connected", []() {
          auto result = DatabaseConnector().disconnect();
          expect(result).toEqual(Result::FAILURE);
        });
      });
    });
    ```
=== "Exceptions"
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
=== "Asserting collections"
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

<div class="grid cards" style="padding-bottom: 24px; padding-top: 24px" markdown>

-   :material-clock-fast:{ .lg .middle } __Get Started__

    ---

    Checkout the [quick start](./quickstart/first.md) guide and start
    building your first test in a minute!

    [:octicons-arrow-right-24: Quick start](./quickstart/first.md)

-   :material-code-block-braces:{ .lg .middle } __API Reference__

    ---

    Find all the nitty gritty details of Cest and make the most
    out of your tests.

    [:octicons-arrow-right-24: API Reference](./reference.md)
</div>

# <center>Main features</center>

### :material-source-branch: Single Header
All features are included in a single C++ header,
making it easy to integrate into any project's existing pipeline. Just include `cest` in each test file to compile a self-contained and runnable test

### :material-lightbulb-on: BDD inspired API
By using `it` , `describe` and `expect`, write your tests
as you would in JavaScript, Python or Ruby. One of the main objectives of Cest is slashing the learning curve towards C++ testing. No more esoteric syntax in C++ tests!

### :fontawesome-solid-wand-magic-sparkles: Feature rich from the get-go
Includes exception handling assertions, parametrized tests, pointer assertions, integration with STL collections, and more. Want more? Planned features include parametric tests, extended collection support, async execution support, and more

# <center>Contribute to Cest Framework</center>

Do you like Cest Framework? Are you planning on using it on your C or C++ projects?

If you enjoy it, it would be great to have your Star in the [GitHub repository](https://github.com/cegonse/cest)!

Are you missing any feature? Open an issue and let's start the conversation to get it implemented.

Do you feel like contributing? Check the contribution guide in the GitHub repository README file, and contribute to Cest. These are the current contributors of Cest, click on their avatars to go to their GitHub profiles:

<div class="grid cards" markdown>
  <a href="https://github.com/cegonse"><img width="128" src="https://avatars.githubusercontent.com/u/10237441?v=4"></img></a>
  <a href="https://github.com/jamofer"><img width="128" src="https://avatars.githubusercontent.com/u/9080627?v=4"></img></a>
</div>
