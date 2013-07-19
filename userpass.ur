(*
leaving this in so I don't forget how to do it
                
functor Make(M : sig
                 val template : xml [Body, Dyn, MakeForm] [] [] -> xml [Html] [] []
             end) = struct
*)    
cookie c : {Session: string}
table s : {LoggedIn : time, User : string, Session : string}
	      PRIMARY KEY LoggedIn
table u : {User : string, Salt : string, Password : string}
	      PRIMARY KEY User
          
fun list_users () =
    rows <- queryX (SELECT * FROM u)
		   (fn r => <xml><tr><td>{[r.U.User]}</td></tr>
		   </xml>);
    return <xml><table>{rows}</table></xml>
          
fun is_logged_in () =
    ro <- getCookie c;
    case ro of
        None => return None
      | Some v => 
	(row <- oneOrNoRows1 (SELECT * FROM s WHERE s.Session = {[v.Session]});
         case row of
             None => return None
           | Some r => return (Some r.User))

fun assert_logged_in msg_fun redir =
    logged_in <- is_logged_in ();
    case logged_in of
        None => msg_fun "Not logged in";
        redirect (url (redir ()))
      | Some _ => return ()

fun login_form redir_to =
    <xml>
      <form>
        User: <textbox{#User}/><br/>
        Password: <password{#Password}/><br/>
        <submit action={login redir_to}/>
      </form><br/><br/>
    </xml>
    
and login redir_to r =
    user <- oneOrNoRows1 (SELECT * FROM u WHERE (u.User = {[r.User]}));
    case user of
	None => redirect (url (redir_to ()))
      | Some us => 
	if us.Password = Hash.sha512 (Basis.strcat (us.Salt) (r.Password)) then 
	    rs <- Random.str 30;
	    setCookie c {Value = {Session = rs},
			 Expires = None,
			 Secure = False};
            dml (INSERT INTO s (LoggedIn, User, Session)
		 VALUES (CURRENT_TIMESTAMP, {[r.User]}, {[rs]} ));
	    redirect (url (redir_to ()))
	else
	    redirect (url (redir_to ()))
                  
and logout_form redir_to =
    <xml>
      <form><submit value="Logout" action={logout redir_to}/></form>
    </xml>

and logout redir_to () =
    ro <- getCookie c;
    clearCookie c;
    case ro of
	None => redir_to ()
      | Some v => 	
	dml (DELETE FROM s
	            WHERE T.Session = {[v.Session]} );
	redirect (url (redir_to ()))

and signup_form redir_to =
    <xml>
      <form>
        User: <textbox{#User}/><br/>
        Password: <password{#Password}/><br/>
        Confirm: <password{#Confirm}/><br/>
        <submit action={signup redir_to}/>
      </form><br/><br/>
    </xml>

and signup redir_to r =
    nameExists <- oneOrNoRows1 (SELECT u.User FROM u WHERE (u.User = {[r.User]}));
    case nameExists of
	Some _ => redirect (url (redir_to ()))
      | None => 
	if r.Password = r.Confirm then
            salt <- Random.str 10;
            dml (INSERT INTO u (User, Salt, Password)
                 VALUES ({[r.User]}, {[salt]}, {[Hash.sha512 (Basis.strcat salt r.Password)]}));
            (* Now login and redirect back *)
            login redir_to (r -- #Confirm)
	    (* rs <- Random.str 30; *)
	    (* setCookie c {Value = {Session = rs }, *)
	    (*     	 Expires = None, *)
	    (*     	 Secure = False}; *)
            (* dml (INSERT INTO s (LoggedIn, User, Session) *)
	    (*      VALUES (CURRENT_TIMESTAMP, {[r.User]}, {[rs]} )); *)
            (* redirect (url (redir_to ())) *)
	else
	    redirect (url (redir_to ()))
            
