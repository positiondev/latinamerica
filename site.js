function init(set_year, initial_year) {
    var set_year_wrap = function(year) {
        execF(execF(set_year, year), null);
    };
    
    $(document).ready(function() {
        $(".slider").slider({
            min: 1491,
            max: 2020,
            step: 1,
            value: initial_year,
        });

        $(".slider").bind("slidestop", function(event, ui) {
            set_year_wrap(ui.value);
            $(".yearIndicator").text(ui.value);
        });
        
        $(".yearIndicator").text("" + initial_year);

        $(document).on("click", ".close", function () {
          $(this).parent().hide();
        });

      
    });

}

function set_year_specific(year) {
  if (year >= 1900) {
    $(".inset").show();
  } else {
    $(".inset").hide();
  }
}

function set_fragment(year, id) {
    location.hash = "year=" + year + ",id=" + id;
}

function set_visible(id) {
  $(".id" + id).show();
}

function paginate(id) {
  var d = $(".id" + id);
  d.attr("data-page", 0);
  var pages = d.find(".page");
  if (pages.length != 0) {
    var navContainer = $("<div class='navContainer'>");
    var nav = $("<div class='nav'>");
    navContainer.append(nav);
    pages.each(function (i, p) {
      var title;
      if ($(p).attr("data-title")) {
        title = $(p).attr("data-title");
      } else {
        title = "" + i;
      }
      var s = $("<span class='page'>" + title + "</span>");
      s.on("click", function () {
        d.attr("data-page", i);
        set_page(d);
      });
      s.addClass("page" + i);
      nav.append(s);
    });

    d.find(".entry_title").after(navContainer);
    
    set_page(d);
  }
}

function set_page(d) {
  var i = -1;
  var current = parseInt(d.attr("data-page"));
  d.find(".nav .page").removeClass("selected");
  d.find(".nav .page"+current).addClass("selected");
  d.children().each(function (index, elem) {
    if ($(elem).hasClass("page")) {
      i++;
    }
    if (i === current) {
      $(elem).show();
    } else if (i > -1) {
      $(elem).hide();
    }
  });

  d.find(".navContainer").show();
  d.find(".close").show();
}

function toggle_div(id) {
  $("#" + id).toggle();
}

function get_fragment_year() {
    try {
        var v = parseInt(location.hash.split(",")[0].split("=")[1]);
        if (isNaN(v)) {
            return -1;
        } else {
            return v;
        }
    } catch (e) {
        return -1;
    }
}

function get_fragment_id() {
    try {
        return parseInt(location.hash.split(",")[1].split("=")[1]);
    } catch (e) {
        return -1;
    }
}
