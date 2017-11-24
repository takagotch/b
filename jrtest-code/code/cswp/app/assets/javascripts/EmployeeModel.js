/***
 * Excerpted from "The Way of the Web Tester",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
***/
var EmployeeModel = function(){

    function getOnsite(){
        var selectedArray = [];
        $.each($('#Onsite option'),function(key,option) {
            selectedArray[selectedArray.length] = $(option).val();})

        return selectedArray;
    }

    function getOffsite(){
        var selectedArray = [];
        $.each($('#Offsite option'),function(key,option) {
            selectedArray[selectedArray.length] = $(option).val();})

        return selectedArray;
    }

    function saveParameters(){

        var employees = $("#Onsite > option").map(function() {
            var jsonData = {};
            jsonData[$(this).val()] = $(this).text();
            return jsonData;
        }).get();

        return {"employees": employees};
    }

    return {
        getOnsite : getOnsite,
        getOffsite : getOffsite,
        saveParameters: saveParameters
    }
};