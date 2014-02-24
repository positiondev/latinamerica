CREATE TABLE uw_Userpass_s(uw_loggedin timestamp NOT NULL, 
                            uw_user text NOT NULL, uw_session text NOT NULL,
 PRIMARY KEY (uw_loggedIn)
  
 );
 
 CREATE TABLE uw_Userpass_u(uw_user text NOT NULL, uw_salt text NOT NULL, 
                             uw_password text NOT NULL,PRIMARY KEY (uw_user)
                                                        
  );
  
  CREATE SEQUENCE uw_La_entries_s;
   
   CREATE TABLE uw_La_entries(uw_id int8 NOT NULL, uw_title text NOT NULL, 
                               uw_start int8 NOT NULL, uw_end int8 NOT NULL, 
                               uw_loc text NOT NULL, uw_category text NOT NULL, 
                               uw_source text NOT NULL, 
                               uw_content text NOT NULL, uw_size text NOT NULL, 
                               uw_draft bool NOT NULL,PRIMARY KEY (uw_id)
                                                       
    );
    
    CREATE TABLE uw_La_misc(uw_key text NOT NULL, uw_data text NOT NULL,
     PRIMARY KEY (uw_key)
      
     );
     
     