cookie c : {Message: string}

fun set_message msg =
    current_time <- now;
    setCookie c {Value = {Message = msg},
                 Expires = Some (addSeconds current_time 100),
                 Secure = False}

fun get_message () =
    mc <- getCookie c;
    clearCookie c;
    case mc of
        None => return None
      | Some v => return (Some v.Message)
