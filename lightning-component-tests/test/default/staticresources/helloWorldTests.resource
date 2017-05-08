/**
 * This is a 'hello world' jasmine test spec file
 */
describe("Sample: Passing", function() {
    it("A simple passing tests", function() {
        expect(true).toBe(true);
    });
});

describe("Sample: Failing", function() {
    xit("A simple failing test", function() {
        expect(true).toBe(false);
    });
});