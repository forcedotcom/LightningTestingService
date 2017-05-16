/**
 * This is a 'hello world' jasmine test spec file.
 * These examples show the "shape" of a Jasmine spec.
 */
describe("A simple passing test", function() {
    it("verifies that true is always true", function() {
        expect(true).toBe(true);
    });
});

describe("A simple failing test", function() {
    xit("fails when false does not equal true", function() {
        // Note: Use xit() instead of it() to temporarily disable a test
        expect(true).toBe(false);
    });
});
