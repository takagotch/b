/***
 * Excerpted from "The Way of the Web Tester",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
***/
describe("When adding employees", function(){

    var model;
    var controller;

    beforeEach(function() {
        setFixtures(
            '<select id="Onsite" size="4" multiple="multiple">' +
            '<option value="1">One</option>' +
            '<option value="2">Two</option>' +
            '</select>' +
            '<input id="leftArrow" type="button" value=" < "  />' +
            '<input id="rightArrow" type="button" value=" > " />' +
            '<select id="Offste" size="4" multiple="multiple">' +
            '<option value="3">Three</option>' +
            '<option value="4">Four</option>' +
            '</select>'
        );

        model = new EmployeeModel();
        controller = new EmployeeController().init();
    });

    it("should be able to transfer from Onsite to Offsite", function(){
        expect(model.getOnsite()).toEqual(['1','2']);
        expect(model.getOffsite()).toEqual(['3','4']);
        $("#Onsite").val('2');
        $('#rightArrow').click();
        expect(model.getOnsite()).toEqual(['1']);
        expect(model.getOffsite()).toEqual(['3','4', '2']);
    });

    it("should be able to transfer from Offsite to Onsite", function(){
        expect(model.getOnsite()).toEqual(['1','2']);
        expect(model.getOffsite()).toEqual(['3','4']);
        $("#Offsite").val('3');
        $('#leftArrow').click();
        expect(model.getOnsite()).toEqual(['1','2','3']);
        expect(model.getOffsite()).toEqual(['4']);
    });

});

describe("When saving the tracker list", function() {
    var controller = null;

    describe("and Onsite has people", function() {

        beforeEach(function() {

            setFixtures(
                '<select id="Onsite" size="4" multiple="multiple">' +
                '<option value="1">One</option>' +
                '<option value="2">Two</option>' +
                '</select>' +
                '<input type="submit" id="save" value="Save"/>'
            );

            controller = new EmployeeController().init();
        });

        it("should save", function() {
            spyOn(controller, 'save');
            $('#save').click();
            expect(controller.save).toHaveBeenCalled();
        });

    });

    describe("and Onsite is empty ", function() {

        beforeEach(function() {

            setFixtures(
                '<select id="Onsite" size="4" multiple="multiple">' +
                '</select>' +
                '<input type="submit" id="save" value="Save"/>'
            );

            controller = new EmployeeController().init();
        });

        it("should show error dialog", function() {
            spyOn(controller, 'showErrorDialog');
            $('#save').click();
            expect(controller.showErrorDialog).toHaveBeenCalled();
        });

    });

});
