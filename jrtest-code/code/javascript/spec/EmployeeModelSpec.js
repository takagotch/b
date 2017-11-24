/***
 * Excerpted from "The Way of the Web Tester",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
***/
describe("When selecting elements for employee", function(){

    var model;

    beforeEach(function() {
        setFixtures(
            '<select id="Onsite" size="4" multiple="multiple">' +
            '<option value="1">One</option>' +
            '<option value="2">Two</option>' +
            '</select>' +
            '<select id="Offsite" size="4" multiple="multiple">' +
            '<option value="3">Three</option>' +
            '<option value="4">Four</option>' +
            '</select>'
        );

        model = new EmployeeModel();
    });

    it("should be able to get Onsite", function () {
        expect(model.getOnsite()).toEqual(['1', '2']);
    });

    it("should be able to get Offsite", function () {
        expect(model.getOffsite()).toEqual(['3', '4']);
    });

    it("should be able to get saveParameters", function(){
        var expected = {"employees": [{"1": "One"},{"2": "Two"}]};
        expect(model.saveParameters()).toEqual(expected);
    });

    it("should be able to detect if Onsite is empty", function(){
        expect(model.getOnsiteIsEmpty()).toBeFalsy();
    });

});

describe("When selecting elements for employee - external fixture", function(){

    var model;

    beforeEach(function() {
        loadFixtures('ListboxFixture.html');
        model = new EmployeeModel();
    });

    it("should be able to get Onsite", function(){
        expect(model.getOnsite()).toEqual(['1','2']);
    });

});