(function ($, Drupal) {
  $(window).on("load", function () {
    if ($("table", context).length > 0) {
      $("table").each((_, table) => {
        // add bootstrap table class
        if (!$(table).hasClass("table")) {
          $(table).addClass("table");
        }

        // add bootstrap table responsive parent div
        if (!$(table).parent().hasClass("table-responsive")) {
          $(table).wrap('<div class="table-responsive"></div>');
        }

        if ($(table).data("table") != "off") {
          // log($(table).data("table"));

          if ($(".table[border]", context).length > 0) {
            $(table).removeAttr("border");
          }

          // bootstrap table-hover class
          if (!$(table).hasClass("table-hover")) {
            $(table).addClass("table-hover");
          }

          // bootstrap table-striped class
          if (!$(table).hasClass("table-striped")) {
            $(table).addClass("table-striped");
          }

          // bootstrap table-bordered class
          if (!$(table).hasClass("table-bordered")) {
            $(table).addClass("table-bordered");
          }
        }

        // Trim spaces for table charts & reinitialize
        if ($(table).hasClass("wb-charts")) {
          $("td", context).each(function () {
            $(this).text($.trim($(this).text()));
          });
          $(".wb-charts", context).trigger("wb-update.wb-charts");
        }
      });
    }
  });
})(jQuery, Drupal);
