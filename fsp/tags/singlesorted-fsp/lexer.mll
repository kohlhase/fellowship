(* Lexer for fsp *)

{
  open Lexing
  open Parser
   
  exception Lexing_error of string
    
  let kwd_tbl = [
    "defun", DEFFUN;
    "defp", DEFPRED;
    "discard", DISCARD;
    "goal", GOAL;
    "checkout", ACK;
    "coq", COQ;
    "pvs", PVS;
    "quit", QUIT;
    "axiom", AXIOM;
    "left", LEFT;
    "right", RIGHT;
    "imply", IMPLY;
    "or", OR;
    "and", AND;
    "not", NOT;
    "copy", COPY;
    "switch", SWITCH;
    "true", TRUE;
    "false", FALSE;
    "forall", FORALL;
    "exists", EXISTS]

  let id_or_kwd s =  try List.assoc s kwd_tbl with _ -> IDENT(s) 

  let newline lexbuf =
    let pos = lexbuf.lex_curr_p in
    lexbuf.lex_curr_p <- 
      { pos with pos_lnum = pos.pos_lnum + 1; pos_bol = pos.pos_cnum }
}

let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let ident = letter (letter | digit)*
let integer = ['0'-'9']+
let space = [' ' '\t']

rule nexttoken = parse
  | '\n'    { newline lexbuf; nexttoken lexbuf }
  | space+  { nexttoken lexbuf }
  | ident   { id_or_kwd (lexeme lexbuf) }
  | integer { ARITY(int_of_string(lexeme lexbuf)) }
  | '.'     { DOT }
  | ','     { VIR }
  | ';'     { PVIR }
  | ':'     { COLON }
  | '~'     { NOT }
  | "->"    { IMPLY }
  | "/\\"   { AND }
  | "\\/"   { OR }
  | '('     { LPAR }
  | ')'     { RPAR }
  | '_'     { UDS }
  | eof     { EOF }
  | _       { raise (Lexing_error (lexeme lexbuf)) }
