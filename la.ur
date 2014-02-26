style location
style entry_small
style entry_medium
style entry_large
style close
style entry_title
style entry_source
style css_hidden
style draft
style not_draft

sequence entries_s
table entries : { Id : int, Title : string, Start : int, End : int,  Loc : string,
                  Category : string, Source : string, Content : string, Size : string,
                  Draft : bool }
                PRIMARY KEY Id

(* For fun :) *)
table misc : { Key : string, Data : string }
             PRIMARY KEY Key

fun size_to_class s = case s of
                          "small" => entry_small
                        | "medium" => entry_medium
                        | "large" => entry_large
                        | _ => error <xml>Invalid size for entry - this means a programming error</xml>

fun draft_class b = if b then draft else not_draft

(* Users see this as a one page app - this is the page *)

fun main () =
    content_source <- source <xml/>;
    entries_source <- source <xml/>;
    year_source <- SourceL.create 0;
    all_es <- fetch_all_entries ();
    return <xml>
      <head>
        <title>History Is A Weapon's Big Latin America Map</title>

        <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css"
        rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="http://map.historyisaweapon.com/static/css/main.css"
        type="text/css" media="screen" />
      </head>
      <body onload={SourceL.onChange year_source (fn year =>
                                                     set content_source <xml/>;
                                                     load_map True content_source entries_source all_es year);
                    frag_year <- Lajs.get_fragment_year;
                    frag_id <- Lajs.get_fragment_id;
                    let val year = if frag_year = (-1) then 1491 else frag_year
                    in
                        Lajs.init
                            (SourceL.set year_source)
                            year
                            (set content_source <xml/>)
                            (load_entry True content_source entries_source all_es)
                            (load_map False content_source entries_source all_es);
                        SourceL.set year_source year;
                        if frag_id <> (-1) then load_entry False content_source entries_source all_es year frag_id else return {}
                    end}>
        <div class={Unsafe.create_class "mainmap"}>
          <div class={Unsafe.create_class "slider"}></div>
          <span class={Unsafe.create_class "yearIndicator"}></span>

          <div class={Unsafe.create_class "inset"}></div>

          <div class={Unsafe.create_class "legend"}>
            <div class={Unsafe.create_class "power"}>Power</div>
            <div class={Unsafe.create_class "redstar"}>Red star</div>
            <div class={Unsafe.create_class "culture"}>Culture</div>
            <div class={Unsafe.create_class "economy"}>Economy</div>
            <div class={Unsafe.create_class "envir"}>Environment</div>
            <div class={Unsafe.create_class "massacre"}>Massacre</div>
            <div class={Unsafe.create_class "ind"}>Indigenous</div>
            <div class={Unsafe.create_class "event"}>Other Event</div>
          </div>
          <div class={Unsafe.create_class "textBox"}>
            <dyn signal={v <- signal content_source; return v}></dyn>
          </div>
          <dyn signal={v <- signal entries_source; return v}></dyn>
        </div>
      </body>
    </xml>

and test_handler () = let val s : string = "\"Hello"
                      in
                          return <xml><body>{[Lib.escape_quotes s]}</body></xml>
                      end

(* There is a little bit of ajax to fetch the entries *)
and load_map set_frag content_source map_source all_entries year =
    let val entries = List.filter (fn e => e.Start <= year && e.End >= year) all_entries
    in
      x <- (List.foldlM (fn r x =>
                                     newid <- fresh;
                                     return <xml>
        <a class={classes location (classes r.Loc r.Category)}
           id={newid} title={r.Title}
           onclick={fn _ =>
                load_entry False content_source map_source all_entries year r.Id
                }>

         </a>{x}
       </xml>) <xml/> entries);
       (if set_frag then Lajs.set_fragment year (-1) else return ());
       Lajs.set_year_specific year;
       set map_source x
    end

and load_entry change_year content_source map_source all_entries year id =
    r <- rpc (fetch_content id);
    Lajs.set_fragment year id;
    set content_source
        <xml><div class={classes (size_to_class r.Size) r.Id}>
          <div class={close}> </div>
          <h3 class={entry_title}>{r.Title}</h3>{r.Content}<hr/><div class={entry_source}>{r.Source}</div></div></xml>;
    Lajs.paginate id;
    (if change_year then load_map False content_source map_source all_entries year else return ())

and fetch_all_entries () : transaction (List.t {Id : int, Title : string, Loc : css_class, Category : css_class, Start : int, End : int}) =
    ili <- Userpass.is_logged_in ();
    let val show_drafts = case ili of
                              None => False
                            | _ => True
    in
        (l <- (if show_drafts then
                  (queryL (SELECT E.Id, E.Title, E.Loc, E.Category, E.Start, E.End
                     FROM entries AS E))
              else (queryL (SELECT E.Id, E.Title, E.Loc, E.Category, E.Start, E.End
                     FROM entries AS E WHERE E.Draft = {[False]})));
        return (List.mp (fn e => {Id = e.E.Id, Title = Lib.escape_quotes e.E.Title,
                                  Loc = Unsafe.create_class e.E.Loc,
                                  Category = Unsafe.create_class e.E.Category,
                                  Start = e.E.Start, End = e.E.End}) l))
    end

and fetch_content id =
    r <- oneRow1 (SELECT E.Content,E.Title,E.Source,E.Size FROM entries AS E WHERE E.Id = {[id]});
    return {Content = (Unsafe.inject_html r.Content), Title = (Unsafe.inject_html (Lib.escape_quotes r.Title)), Source = (Unsafe.inject_html r.Source), Size = r.Size,
            Id = Unsafe.create_class ("id" ^ (show id))}

(* What follows is the backend *)
and template content =
    msg <- Messages.get_message ();
    logged_in <- Userpass.is_logged_in ();
    let val m = Option.get "" msg
        val logout = Option.get <xml/> (Option.bind (fn _ => Some <xml><h4>
          <form>
            <submit action={Userpass.logout admin} value="Logout"/>
            </form>
          </h4></xml>) logged_in)
    in
        return
            (<xml>
              <head>
                <link rel="stylesheet" href="http://map.historyisaweapon.com/static/css/admin.css"
                type="text/css" media="screen" />
              </head>
              <body>
                <h4>{[m]}</h4>
                <a href={url (admin ())}>Admin Home</a>
                {content}
                {logout}
              </body>
            </xml>)
    end

and login_page () =
    template <xml>
      <h4>Login</h4>
      {Userpass.login_form admin}
      <!--<h4>Signup</h4>
      {Userpass.signup_form admin}-->
    </xml>

and blank_entry () = {Id = 0, Title="", Content="", Start=0, End=0, Loc="",Category="",Source="", Size="large", Draft=False}

and render_entries entries add_entry_id =
    template <xml>
     <button Onclick={fn _ => Lajs.toggle_div add_entry_id} value="Add Entry"></button>
      <div class={css_hidden} id={add_entry_id}>{entry_form (blank_entry ()) add_submit}</div>
      <br/>{entries}</xml>

and show_country r =
    entries <- queryX (SELECT E.Id, E.Title, E.Start, E.End, E.Draft FROM entries AS E
                                                                     WHERE E.Loc LIKE {["%" ^ r.Country ^ "%"]}
                                                                     ORDER BY E.Start)
                      (fn r => <xml><div class={draft_class r.E.Draft}>
                        <a href={url (edit_entry r.E.Id)}>Edit</a> -
                        {[r.E.Title]} - {[show r.E.Start]} to {[show r.E.End]}</div></xml>);
    add_entry_id <- fresh;
    render_entries entries add_entry_id

and admin () =
    Userpass.assert_logged_in Messages.set_message login_page;
    num <- oneRowE1 (SELECT COUNT( * ) FROM entries);
    num_drafts <- oneRowE1 (SELECT COUNT ( * ) FROM entries AS E WHERE E.Draft = {[True]});
    did_work_yay <- oneOrNoRows1 (SELECT M.Data FROM misc AS M WHERE M.Key = {["did_work_yay"]});
    dml (DELETE FROM misc WHERE Key = {["did_work_yay"]});
    let val options = List.foldr (fn c x => <xml><option value={c.Pre}>{[c.Nm]}</option>{x}</xml>)
                                 <xml/>
                                 (Cons ({Pre = "afr", Nm = "Africa"},
                                  Cons ({Pre = "ant", Nm = "Antilles"},
                                  Cons ({Pre = "arg", Nm = "Argentina"},
                                  Cons ({Pre = "asi", Nm = "Asia"},
                                  Cons ({Pre = "bar", Nm = "Barbados"},
                                  Cons ({Pre = "bel", Nm = "Belize"},
                                  Cons ({Pre = "bol", Nm = "Bolivia"},
                                  Cons ({Pre = "bra", Nm = "Brazil"},
                                  Cons ({Pre = "chi", Nm = "Chile"},
                                  Cons ({Pre = "col", Nm = "Colombia"},
                                  Cons ({Pre = "cos", Nm = "Costa Rica"},
                                  Cons ({Pre = "cub", Nm = "Cuba"},
                                  Cons ({Pre = "cur", Nm = "Curaçao"},
                                  Cons ({Pre = "domre", Nm = "Dominican Republic"},
                                  Cons ({Pre = "ecu", Nm = "Ecuador"},
                                  Cons ({Pre = "els", Nm = "El Salvador"},
                                  Cons ({Pre = "eur", Nm = "Europe"},
                                  Cons ({Pre = "gre", Nm = "Grenada"},
                                  Cons ({Pre = "gua", Nm = "Guatemala"},
                                  Cons ({Pre = "gui", Nm = "French Guiana"},
                                  Cons ({Pre = "guy", Nm = "Guyana"},
                                  Cons ({Pre = "hai", Nm = "Haiti"},
                                  Cons ({Pre = "hon", Nm = "Honduras"},
                                  Cons ({Pre = "jam", Nm = "Jamaica"},
                                  Cons ({Pre = "mex", Nm = "Mexico"},
                                  Cons ({Pre = "nic", Nm = "Nicaragua"},
                                  Cons ({Pre = "pan", Nm = "Panama"},
                                  Cons ({Pre = "par", Nm = "Paraguay"},
                                  Cons ({Pre = "per", Nm = "Peru"},
                                  Cons ({Pre = "pue", Nm = "Puerto Rico"},
                                  Cons ({Pre = "sea", Nm = "Ocean"},
                                  Cons ({Pre = "stj", Nm = "St. James"},
                                  Cons ({Pre = "stk", Nm = "St. Kitts"},
                                  Cons ({Pre = "sur", Nm = "Suriname"},
                                  Cons ({Pre = "tat", Nm = "Trinidad and Tobego"},
                                  Cons ({Pre = "uru", Nm = "Uruguay"},
                                  Cons ({Pre = "usa", Nm = "Murica"},
                                  Cons ({Pre = "ven", Nm = "Venezuela"},
                                        Nil)))))))))))))))))))))))))))))))))))))))
    in
        template <xml>
          <h4>Total Entries: {[num]}</h4>
          <h4>Total Entries (Drafts): {[num_drafts]}</h4>
          {case did_work_yay of
               Some _ => <xml><h4 class={Unsafe.create_class "yay_draft"}>
                 Finished a draft! YAYAYAY!</h4></xml>
             | _ => <xml/>}
          <h4><a href={url (show_all_entries ())}>All Entries</a></h4>
          <h4><a href={url (show_all_entries_long ())}>All Entries (with content)</a></h4>
          <form>
            Country: <select{#Country}>
              {options}
            </select>
            <submit action={show_country} />
          </form>
        </xml>
    end

and load_n_entries n start =
    raw_entries <- queryL (SELECT E.Id, E.Title, E.Start, E.End, E.Content, E.Draft FROM entries AS E ORDER BY E.Start LIMIT {n} OFFSET {start});
    let val entries_xml = List.foldr (fn r x => <xml>{x}<div class={draft_class r.E.Draft}><a href={url (edit_entry r.E.Id)}>Edit</a> - {[r.E.Title]} - {[show r.E.Start]} to {[show r.E.End]}<hr/>
                      {Unsafe.inject_html r.E.Content}</div></xml>) <xml/> raw_entries
    in
        return {Xml = entries_xml, More = ((List.length raw_entries) = n)}
    end

and load_all_entries start (box : source xbody) =
    r <- rpc (load_n_entries 50 start);
    existing <- get box;
    set box <xml>{existing} {r.Xml}</xml>;
    if r.More then load_all_entries (start + 50) box else return ()

and show_all_entries_long () =
    ebox <- source <xml/>;
    Userpass.assert_logged_in Messages.set_message login_page;
    return <xml>
      <head>
        <link rel="stylesheet" href="http://map.historyisaweapon.com/static/css/admin.css"
        type="text/css" media="screen" />
      </head>
      <body onload={load_all_entries 0 ebox}>
        <h4>All Entries</h4>
        <a href={url (admin ())}>Admin Home</a>
        <dyn signal={x <- signal ebox; return x}/>
      </body>
    </xml>

and entry_form r target =
    <xml>
      <form>
        <hidden{#Id} value={show r.Id}/>
        Title: <textbox{#Title} value={r.Title}/><br/>
        Content: <textarea{#Content} rows=30 cols=100>{[r.Content]}</textarea><br/>
        Start: <textbox{#Start} value={show r.Start}/><br/>
        End: <textbox{#End} value={show r.End}/><br/>
        Loc: <textbox{#Loc} value={r.Loc}/><br/>
        Category: <select{#Category}>
          <option selected={r.Category = "power"}>power</option>
          <option selected={r.Category = "redstar"}>redstar</option>
          <option selected={r.Category = "redfist"}>redfist</option>
          <option selected={r.Category = "culture"}>culture</option>
          <option selected={r.Category = "church"}>church</option>
          <option selected={r.Category = "economy"}>economy</option>
          <option selected={r.Category = "argicultural"}>argicultural</option>
          <option selected={r.Category = "envir"}>envir</option>
          <option selected={r.Category = "event"}>event</option>
          <option selected={r.Category = "massacre"}>massacre</option>
          <option selected={r.Category = "ind"}>ind</option>
          <option selected={r.Category = "war"}>war</option>
        </select>
        Source: <textbox{#Source} value={r.Source}/><br/>
        Size: <select{#Size}>
          <option selected={r.Size = "small"}>small</option>
          <option selected={r.Size = "medium"}>medium</option>
          <option selected={r.Size = "large"}>large</option>
        </select><br/>
        Draft <checkbox{#Draft} checked={r.Draft}/><br/>
        <br/>
        Continue Editing <checkbox{#Continue} checked={True}/><br/>
        <submit action={target} value="Save"/>
      </form>
    </xml>



and add_submit r =
    Userpass.assert_logged_in Messages.set_message login_page;
    id <- nextval entries_s;
    dml (INSERT INTO entries (Id,Title,Start,End,Loc,Category,Source,Content,Size,Draft)
        VALUES ({[id]},{[r.Title]},{[readError r.Start]},
            {[readError r.End]},{[r.Loc]},{[r.Category]},{[r.Source]},{[r.Content]}, {[r.Size]}, {[r.Draft]}));
    Messages.set_message "Successfully added entry";
    if r.Continue then
        redirect (url (edit_entry id))
    else
        redirect (url (admin ()))

and show_all_entries () =
    Userpass.assert_logged_in Messages.set_message login_page;
    add_entry_id <- fresh;
    entries <- queryX (SELECT E.Id, E.Title, E.Start, E.End, E.Draft FROM entries AS E ORDER BY E.Start)
                      (fn r => <xml><div class={draft_class r.E.Draft}><a href={url (edit_entry r.E.Id)}>Edit</a> - {[r.E.Title]} - {[show r.E.Start]} to {[show r.E.End]}</div></xml>);
    render_entries entries add_entry_id

and edit_entry (id:int) =
    Userpass.assert_logged_in Messages.set_message login_page;
    entry <- queryL (SELECT E.Id,E.Title,E.Start,E.End,
                            E.Loc,E.Category,E.Source,E.Content,E.Size,E.Draft
                          FROM entries AS E WHERE E.Id = {[id]});
    case entry of
        Cons (r,_) =>
        template <xml>
          <h4>Edit Entry</h4>
          <a href={url (show_all_entries ())}>Back to All Entries</a>
          <br/><br/>
          {entry_form r.E edit_submit}
        </xml>
      | _ =>
        Messages.set_message "Could not find entry";
        redirect (url (admin ()))

and edit_submit r =
    Userpass.assert_logged_in Messages.set_message login_page;
    num_drafts <- oneRowE1 (SELECT COUNT ( * ) FROM entries AS E WHERE E.Draft = {[True]});
    dml (UPDATE entries SET Title = {[r.Title]}, Start = {[readError r.Start]},
        End = {[readError r.End]}, Loc = {[r.Loc]}, Category = {[r.Category]},
        Source = {[r.Source]}, Content = {[r.Content]}, Size = {[r.Size]}, Draft = {[r.Draft]}
        WHERE Id = {[readError r.Id]});
    num_drafts_after <- oneRowE1 (SELECT COUNT ( * ) FROM entries AS E WHERE E.Draft = {[True]});
    (if num_drafts_after < num_drafts
    then (hr <- hasRows (SELECT * FROM misc AS M WHERE M.Key = {["did_work_yay"]});
         (case hr of
             False => dml (INSERT INTO misc (Key, Data) VALUES ({["did_work_yay"]}, {["yes"]}))
           | True => return ()))
    else return ());
    (* Messages.set_message "Successfully updated entry"; *)
    if r.Continue then
        redirect (url (edit_entry (readError r.Id)))
    else
        redirect (url (admin ()))
