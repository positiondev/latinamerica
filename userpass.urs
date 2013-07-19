val assert_logged_in : (string -> transaction unit) -> (unit -> transaction page) -> transaction unit
val is_logged_in : unit -> transaction (option string)
val list_users : unit -> transaction (xml [Body, MakeForm, Dyn] [] [])
val login_form : (unit -> transaction page) -> xml [Body, MakeForm, Dyn] [] []
val login : (unit -> transaction page) -> {User : string, Password : string} -> transaction page
val logout_form : (unit -> transaction page) -> xml [Body, MakeForm, Dyn] [] []
val logout : (unit -> transaction page) -> unit -> transaction page
val signup_form : (unit -> transaction page) ->
                  xml [Body, MakeForm, Dyn] [] []
val signup : (unit -> transaction page) ->
             {User : string, Password : string, Confirm : string}
             -> transaction page
