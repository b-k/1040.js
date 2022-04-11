m4_divert(-1)
m4_changequote(<|,|>)

m4_define(<|strip|>, <|m4_translit($1, <|
|>)|>)

m4_define(<|m4_form|>, <|m4_define(<|m4form|>,$1)|>)

m4_define(<|Cell|>, <|m4_divert(1)g.setNode("m4form<||>_$1",  { label: "$1", baselabel: "$1", form: "m4form", fullname: "$3", class: "a_node strip($5)", val:0 , eqn: "strip($4)", last_eval:0 });
m4_divert(-1)|>)
m4_define(<|CV|>, <|Cv('strip(m4_ifelse(<|$#|>,1,m4form,$1))_<||>strip(m4_ifelse(<|$#|>,1,$1,$2))')|>)
m4_define(<|SUM|>, <|$@, |>)
m4_define(<|SUM|>, <|m4_ifelse(<|$1|>,<||>,0,
<|CV(strip($1)) + SUM(m4_shift($@))|>)|>)

m4_define(Situation, <| situations['.$1'] |>)
m4_define(IF, <|(($1) ? ($2) : ($3))|>)
m4_define(FirstPart, <|$1|>)
m4_define(SecondPart, <|$2|>)

m4_define(Fswitch, <|m4_ifelse($#,1, $1, <|IF(fstatus()=='FirstPart$1', SecondPart$1,Fswitch(m4_shift($@)))|>) |>)
