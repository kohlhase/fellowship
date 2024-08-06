/* Parser for fsp */

%{
  open Core
  open Tactics
  open Instructions
  open Help
  open Print

%}

%token <string> IDENT
%token COQ PVS ISABELLE
%token LJ LK MIN FULL DECLARE THEOREM NEXT PREV QED ACK PROOF TERM NATURAL LANGUAGE UNDO DISCARD QUIT HELP
%token AXIOM CUT ELIM IDTAC IN FOCUS CONTRACTION 
%token TACTICALS
%token PROP SET
%token NEG ARROW MINUS AND OR FORALL EXISTS TRUE FALSE LEFT RIGHT ALL
%token LPAR RPAR LBRA RBRA VIR PVIR PIPE COLON DOT 
%token EOF 

/* Token priorities / associativity */

%nonassoc VIR
%nonassoc FORALL EXISTS
%right ARROW PVIR
%left MINUS AND OR 
%nonassoc NEG
%nonassoc LBRA RBRA

/* The grammar entry point */
%start main

/* The type of values returned by the syntactic analyzer */
%type <Help.script> main

%%


main:
| instr args DOT                           { Instruction ($1,$2) }
| tactical DOT                             { Tactical $1 }
/*toplvl only*/
| HELP DOT                                 { Help Nix }
| HELP instr DOT                           { Help (HInstr $2) }
| HELP tac DOT                             { Help (HTac $2) }
| HELP ELIM dir connector DOT              { Help (HElim ($3,$4)) }
| HELP TACTICALS DOT                       { Help HTacticals }
| EOF                                      { raise (Failure "end") } 

instr:
| LJ                                       { Lj true }
| LK                                       { Lj false }
| MIN                                      { Min true }
| FULL                                     { Min false }
| DECLARE                                  { Declare }
| THEOREM                                  { Goal }
| NEXT                                     { Next }
| PREV                                     { Prev }
| QED                                      { Qed }
| ACK                                      { Ack }
| ACK PROOF TERM                           { AckProofTerm }
| ACK NATURAL LANGUAGE                     { ExportNaturalLanguage }
| UNDO                                     { if !toplvl then Undo 
					     else raise Parsing.Parse_error }
| DISCARD                                  { if !toplvl then Discard
					     else raise Parsing.Parse_error }
| QUIT                                     { Quit }

tac: 
/* primitive tactics */
| AXIOM                                    { Axiom }
| CUT                                      { Cut }
| ELIM                                     { Elim }
/* tacticals */
| IDTAC                                    { Idtac }
/* derived tactics */
| FOCUS                                    { Focus }
| ELIM IN                                  { Elim_In }
| CONTRACTION                              { Contraction }
;

tactical:
| tac args                                 { TPlug ($1,$2,symbol_start_pos ()) }
| tactical PVIR tactical                   { Then ($1,$3,symbol_start_pos ()) }
| tactical PVIR LBRA taclist RBRA          { Thens ($1,$4,symbol_start_pos ()) }

taclist:
| tactical PIPE taclist                    { $1::$3 }
| tactical                                 { [$1] }

dir:
| RIGHT                                    { true }
| LEFT                                     { false }

connector:
| AND                                      { "and" }
| OR                                       { "or" }
| NEG                                      { "neg" }
| ARROW                                    { "imply" }
| MINUS                                    { "minus" }
| FORALL                                   { "forall" }
| EXISTS                                   { "exists" }
| TRUE                                     { "true" }
| FALSE                                    { "false" }

arg:
| LEFT                                    { OnTheLeft }
| RIGHT                                   { OnTheRight }
| IDENT                                   { Ident $1 }
| delimited_p_expr                        { Formula $1 }
| delimited_t_expr                        { Expression $1 }
| varlist COLON s_expr                    { Labeled_sort ($1,$3) }
| varlist COLON delimited_p_expr          { Labeled_prop ($1,$3) }
| COQ                                     { Prover Coq }
| PVS                                     { Prover Pvs }
| ISABELLE                                { Prover Isabelle }
| ALL                                     { All }
| THEOREM                                 { Theorem }

args:
| arg args                                 { $1::$2 }
|                                          { [] }

s_expr:
| SET                                      { SSet }
| PROP                                     { SProp }
| IDENT                                    { SSym $1 }
| s_expr ARROW s_expr                      { SArr ($1,$3) }
;

t_expr:
| t_exprat                                 { $1 }
| t_expr t_exprat                          { TApp ($1,$2) }
;

t_exprat:
| IDENT                                    { TSym $1 }
| LPAR t_expr RPAR                         { $2 }

p_expr:
| TRUE                                     { True }
| FALSE                                    { False }
| IDENT                                    { PSym $1 }
| NEG p_expr                               { UProp(Neg,$2) }
| p_expr delimited_t_expr                  { PApp($1,$2) }
| p_expr ARROW p_expr                      { BProp($1,Imp,$3) }
| p_expr MINUS p_expr                      { BProp($1,Minus,$3) }
| p_expr OR p_expr                         { BProp($1,Disj,$3) }
| p_expr AND p_expr                        { BProp($1,Conj,$3) }
| FORALL varlist COLON s_expr VIR p_expr   { Quant(Forall,($2,$4),$6) } 
| EXISTS varlist COLON s_expr VIR p_expr   { Quant(Exists,($2,$4),$6) }
| LPAR p_expr RPAR                         { $2 }
;

varlist:
| IDENT                                    { [$1] }
| IDENT VIR varlist                        { $1::$3 }
;

delimited_p_expr:
| LPAR p_expr RPAR                         { $2 }

delimited_t_expr:
| LBRA t_expr RBRA                         { $2 }
