/***
 * Excerpted from "The Way of the Web Tester",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/jrtest for more book information.
***/
var EmployeeController = function (pModel) {

    var model = pModel || new EmployeeModel();

    function init() {

        var that = this;

        $('#leftArrow').click(function () {
            $('#Offsite option:selected').appendTo('#Onsite');
        });

        $('#rightArrow').click(function () {
            $('#Onsite option:selected').appendTo('#Offsite');
        });

        $('#save').click(function () {

            if (that.model.getOnsiteIsEmpty()) {
                that.showErrorDialog();
            } else {
                that.save();
            }
        });

        return this;
    }

    function save() {

        params = model.saveParameters();

        $.ajax({
            type: "POST",
            traditional: true,
            url: "/tracker",
            data: params,
            dataType: 'json',
            success: function (result) {
                $('#SuccessMessage').html(result.message);
            }
        });
    }

    function showErrorDialog() {
        alert('Error - Onsite cannot be empty');
    }

    return {
        init: init,
        save: save,
        showErrorDialog: showErrorDialog,
        model: model
    };
};
