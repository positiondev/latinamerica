function init(set_year, initial_year, close_callback, load_entry, load_year) {
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
      set_fragment(get_fragment_year(), -1);
      execF(close_callback, null);
    });

    $(document).on("click", "a[data-entry]", function() {
      var id = parseInt($(this).attr("data-entry"));
      var year = -1;
      if (typeof $(this).attr("data-year") !== "undefined") {
        year = parseInt($(this).attr("data-year"));
        $(".slider").slider("value", year);
        $(".yearIndicator").text(year);
      }
      execF(execF(execF(load_entry, year), id), null);
      return false;
    });

    window.onpopstate = function(event) {
      if (event.laInfo === "manual") {
        return;
      }
      console.log("popping");
      var year = get_fragment_year();
      var id = get_fragment_id();
      $(".slider").slider("value", year);
      $(".yearIndicator").text(year);
      if (id !== -1) {
        execF(execF(execF(load_entry, year), id), null);
      } else {
        execF(close_callback, null);
        execF(execF(load_year, year), null);
      }
    };

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
  history.pushState({laInfo: "manual"}, '', "#year=" + year + ",id=" + id);
}

function paginate(id) {
  var d = $(".id" + id);
  var pageDividers = d.find(".page");
  if (pageDividers.length != 0) {
    var pages = [];
    var collected = [];
    var cur = $("<div class='page'>");
    var start = false;
    d.children().each(function(i,e) {
      console.log(e);
      if (!start) {
        if ($(e).hasClass("page")) {
          start = true;
          if (typeof $(e).attr("data-title") !== "undefined") {
            cur.attr("data-title", $(e).attr("data-title"));
          }
          $(e).remove();
        }
      } else {
        if ($(e).hasClass("page")) {
          collected.map(function(elt) { cur.append(elt); });
          collected = [];
          pages.push(cur);
          cur = $("<div class='page'>");
          if (typeof $(e).attr("data-title") !== "undefined") {
            cur.attr("data-title", $(e).attr("data-title"));
          }
        } else {
          collected.push($(e).clone());
        }
        $(e).remove();
      }
    });
    collected.map(function(elt) { cur.append(elt); });
    pages.push(cur);

    console.log(pages);
    pages.map(function(e) { d.append(e); });

    var pagesDS = pages.map(function (p) {
      var title;
      if (typeof $(p).attr("data-title") !== "undefined") {
        title = "" + $(p).attr("data-title");
      } else {
        title = "";
      }
      return {title: title, page: p};
    });
    set_page(d, pagesDS, 0);
  }
  d.find(".close").show();
}

function set_page(d, pages, i) {
  d.find('.page').hide();
  $(pages[i].page).show();
  d.find(".nav").remove();
  var nav = $("<div class='nav'>");
  var titleText = "Page " + (i+1) + " of " + pages.length;
  if (pages[i].title !== "") {
    titleText = titleText + ": " + pages[i].title;
  }
  var title = $("<span class='title'>").text(titleText);
  var prev = $("<a href='#' class='prev'>Previous</span>");
  var next = $("<a href='#' class='next'>Next</span>");
  if (i !== 0) {
    nav.append(prev);
  }
  nav.append(title);
  if (i !== pages.length - 1) {
    nav.append(next);
  }

  prev.on('click', function () {
    if (i > 0) {
      set_page(d, pages, i-1);
    }
    return false;
  });
  next.on('click', function () {
    if (i < pages.length - 1) {
      set_page(d, pages, i+1);
    }
    return false;
  });

  d.append(nav);
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
