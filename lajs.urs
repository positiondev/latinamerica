val init : (int -> transaction unit) -> (* set year *)
           int -> (* the initial year *)
           transaction unit -> (* setting content_source to blank *)
           (int -> int -> transaction unit) -> (* setting an entry *)
           (int -> transaction unit) -> (* setting a year *)
           (int -> list {Id : int, Title : string, Loc : css_class,
                Start : int, End : int, Category : css_class, Size : string} -> transaction unit) -> (* rendering a year *)
           list {Id : int, Title : string, Loc : css_class,
                Start : int, End : int, Category : css_class, Size : string} ->
           transaction unit

val set_fragment : int -> (* year *)
                   int -> (* entry id *)
                   transaction unit

val draw_plates : int -> transaction unit

val paginate : int ->  transaction unit

val toggle_div : id -> transaction unit

val get_fragment_year : transaction int
val get_fragment_id : transaction int
val set_legend : string -> (xbody -> transaction unit) -> transaction unit
