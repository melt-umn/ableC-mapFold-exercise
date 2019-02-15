grammar edu:umn:cs:melt:exts:ableC:mapFold:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:substitution;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:overloadable;

imports silver:langutil;
imports silver:langutil:pp;

abstract production nondestructiveMap
top::Expr ::= f::Name a::Expr n::Integer
{
  propagate substituted;
  top.pp = pp"map ${f.pp} (${a.pp}) ${text(toString(n))}";

  local plainFwd :: Expr =
    ableC_Expr {
      ({ int *tmp_a = $Expr{a};
         int *result = malloc($intLiteralExpr{n} * sizeof(int));
         for (int i=0; i < $intLiteralExpr{n}; ++i) {
           result[i] = $Name{f}(tmp_a[i]);
         }
         result;
      })
    };

  local optmFwd :: Maybe<Expr> =
    case a of
      nondestructiveMap(f1, a1, _) ->
        just(ableC_Expr {
          ({ int *tmp_a = $Expr{a1};
             int *result = malloc($intLiteralExpr{n} * sizeof(int));
             for (int i=0; i < $intLiteralExpr{n}; ++i) {
               result[i] = $Name{f}($Name{f1}(tmp_a[i]));
             }
             result;
          })
        })
    | _ -> nothing()
    end;

  f.env = top.env;
  a.env = top.env;
  a.returnType = top.returnType;
  local lerrors :: [Message] = a.errors ++ checkMapErrors(f, a, n, top.location);

  forwards to
    mkErrorCheck(lerrors,
      case optmFwd of
        just(fwd) -> fwd
      | nothing() -> plainFwd
      end
    );
}



function checkMapErrors
[Message] ::= f::Decorated Name  a::Decorated Expr  n::Integer  l::Location
{
  local functionTypeErrors :: [Message] =
    if !null(f.valueLookupCheck)
    then f.valueLookupCheck
    else
      case f.valueItem.typerep of
        functionType(retType, protoFunctionType(argTypes, false), _) ->
          case retType of
            builtinType(nilQualifier(), signedType(intType())) ->
              if length(argTypes) != 1
              then [err(l, "First argument to `map' must be a function accepting a single argument")]
              else case head(argTypes) of
                     builtinType(nilQualifier(), signedType(intType())) -> []
                   | _ -> [err(l,
                           "First argument to `map' must be a function accepting a single argument of type int, got " ++
                           showType(head(argTypes)))]
                   end
          | _ -> [err(l, "Return type of first argument to `map' must be int, got " ++ showType(retType))]
          end
      | _ -> [err(l, "First argument to `map' must be a function, got " ++ showType(f.valueItem.typerep))]
      end;

  local mismatchedSizeErrors :: [Message] =
    case a of
      nondestructiveMap(_, _, n1) ->
        if n != n1
        then [err(l, "Mismatched array sizes in nested maps: " ++ toString(n) ++ " and " ++ toString(n1))]
        else []
    -- perhaps a match for a destructiveMap is eventually needed
     | _ -> []
    end;

  local aErrors :: [Message] =
    if compatibleTypes(a.typerep.defaultFunctionArrayLvalueConversion,
         pointerType(nilQualifier(), builtinType(nilQualifier(), signedType(intType()))),
         false, false)
    then []
    else [err(l, "Second argument to `map' must be of type int *, got " ++
          showType(a.typerep.defaultFunctionArrayLvalueConversion))];

  return functionTypeErrors ++ mismatchedSizeErrors ++ aErrors;
}


