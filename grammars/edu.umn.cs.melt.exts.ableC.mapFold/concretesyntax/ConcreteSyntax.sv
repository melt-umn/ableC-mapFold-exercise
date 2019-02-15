grammar edu:umn:cs:melt:exts:ableC:mapFold:concretesyntax;

imports edu:umn:cs:melt:ableC:concretesyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:host as abs;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction only fromId;
imports silver:langutil only ast;

imports edu:umn:cs:melt:exts:ableC:mapFold:abstractsyntax;

marking terminal Map_t 'map' lexer classes {Ckeyword};

concrete productions top::AssignExpr_c
| 'map' f::Identifier_t a::Identifier_t n::DecConstant_t
  {
    top.ast = nondestructiveMap(fromId(f), abs:directRefExpr(fromId(a), location=a.location), toInt(n.lexeme), location=top.location);
  }
| 'map' f::Identifier_t '(' a::AssignExpr_c ')' n::DecConstant_t
  {
    top.ast = nondestructiveMap(fromId(f), a.ast, toInt(n.lexeme), location=top.location);
  }

