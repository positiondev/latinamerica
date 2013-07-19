CREATE TABLE uw_Userpass_s(uw_loggedin text NOT NULL, uw_user text NOT NULL, 
                            uw_session text NOT NULL,
 PRIMARY KEY (uw_loggedIn)
  
 );
 
 CREATE TABLE uw_Userpass_u(uw_user text NOT NULL, uw_salt text NOT NULL, 
                             uw_password text NOT NULL,PRIMARY KEY (uw_user)
                                                        
  );
  
  CREATE TABLE uw_La_entries_s (id INTEGER PRIMARY KEY AUTOINCREMENT);
   
   CREATE TABLE uw_La_entries(uw_id integer NOT NULL, uw_title text NOT NULL, 
                               uw_start integer NOT NULL, 
                               uw_end integer NOT NULL, uw_loc text NOT NULL, 
                               uw_category text NOT NULL, 
                               uw_source text NOT NULL, 
                               uw_content text NOT NULL, uw_size text NOT NULL, 
                               uw_draft integer NOT NULL,PRIMARY KEY (uw_id)
                                                          
    );
    
    