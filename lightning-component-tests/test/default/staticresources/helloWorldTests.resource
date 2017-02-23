describe("Sample: Passing", function() {
    it("A simple passing tests", function() {
        expect(true).toBe(true);
    });
});

describe("Sample: Failing", function() {
    it("A simple failing test", function() {
        expect(true).toBe(false);
    });
});