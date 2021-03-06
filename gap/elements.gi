#############################################################################
##
#W  elements.gi             Manuel Delgado <mdelgado@fc.up.pt>
#W                          Pedro A. Garcia-Sanchez <pedro@ugr.es>
#W                          Jose Morais <josejoao@fc.up.pt>
##
##
#Y  Copyright 2005 by Manuel Delgado,
#Y  Pedro Garcia-Sanchez and Jose Joao Morais
#Y  We adopt the copyright regulations of GAP as detailed in the
#Y  copyright notice in the GAP manual.
##
#############################################################################

#############################################################################
##
#F  ElementsUpTo(S,b)
##
##  Returns the elements of S up to the positive integer b
##
#############################################################################
InstallGlobalFunction(ElementsUpTo,function(S,b)
  local gens, sg, m, maxlen, elements, i, eltsofprevlen, f, eltsoflen, g;

  # check the arguments
  if not IsNumericalSemigroup(S) then
    Error("ElementsOfNumericalSemigroupUpTo: the first argument must be a numerical semigroup");
  fi;
  if not IsPosInt(b) then
    Error("ElementsOfNumericalSemigroupUpTo: the second argument must be a positive integer");
  fi;

  gens := Set(Generators(S));
  sg := Filtered(gens, g -> g <= b); #the generators up to b (if the generators were minimal, these were the elements of length 1)
  m := gens[1]; #the multiplicity of S
  maxlen := CeilingOfRational(b/m); #the maximum length of the elements to be computed
  elements := [[0],sg];#initialize with the elements of length 0 and 1
  for i in [2..maxlen] do #compute the sets of elements of bigger lengths
    eltsofprevlen := elements[i]; #elements of previous length
    f := First(sg, h -> eltsofprevlen[1] + h > b);
    if f <> fail then
      sg := Filtered(sg, h -> h < f); #bigger generators do not add anything and not to be used further
    fi;
    eltsoflen := [];
    for g in sg do
      eltsoflen := Union(eltsoflen,eltsofprevlen+g);
    od;
    Add(elements, Filtered(eltsoflen, g -> g <= b));
  od;
  
  return Set(Flat(elements));
end);


#############################################################################
##
#A  SmallElementsOfNumericalSemigroup(S)
##
##  Returns the list of elements in the numerical semigroup S,
##  not greater than the Frobenius number + 1.
##
#############################################################################
InstallMethod(SmallElementsOfNumericalSemigroup,
        "Returns the list of elements in the numerical semigroup not greater that the Frobenius number + 1",
        [IsNumericalSemigroup and HasSmallElements ],100,
        function( sgp )
    return SmallElements(sgp);
end);

InstallMethod(SmallElementsOfNumericalSemigroup,
        "Returns the list of elements in the numerical semigroup not greater that the Frobenius number + 1",
        [IsNumericalSemigroup and HasGaps ],99,
        function( sgp )
  local  G, K;
  G := Gaps(sgp);
  K := Difference([0..G[Length(G)]+1],G);
  SetSmallElements(sgp,K);

  return SmallElements(sgp);
end);


InstallMethod(SmallElementsOfNumericalSemigroup,
        "Returns the list of elements in the numerical semigroup not greater that the Frobenius number + 1",
        [IsNumericalSemigroup and HasFundamentalGaps ],99,
        function( sgp )
  local  L, G, K;
  L := FundamentalGaps(sgp);
  G := Set(Flat(List(L,i->DivisorsInt(i))));
  K := Difference([0..G[Length(G)]+1],G);
  SetSmallElements(sgp,K);

  return SmallElements(sgp);
end);



InstallMethod(SmallElementsOfNumericalSemigroup,
        "Returns the list of elements in the numerical semigroup not greater that the Frobenius number + 1",
        [IsNumericalSemigroup and HasAperyList ],50,
        function( sgp )
    local ap, m, x;
    ap := AperyList(sgp);
    m := Length(ap);
    SetSmallElements(sgp, Set(Filtered([0..FrobeniusNumber(sgp)+1], x -> x mod m = 0 or ap[x mod m + 1] <= x)));
    return SmallElements(sgp);
  end);



InstallMethod(SmallElementsOfNumericalSemigroup,
        "Returns the list of elements in the numerical semigroup not greater that the conductor",
        [IsNumericalSemigroup and HasGenerators],1,
        function( ns )
  local primitives, m, elements, n, bool, k, gaps, frob, smalls;

  primitives := MinimalGenerators(ns);
  m := primitives[1];
  # we start by computing the elements up to 5m by using a function that is efficient in practice
  # note that (by a result of Zhai) assimtotically most numerical semigroups fall in this class 
  elements := ElementsUpTo(ns,5*m);
  # if the small elements are not yet computed we continue using a more traditional process 
  # we test m elements in a row to reduce the number of tests 
  n := Maximum(elements);
  if not IsSubset(elements,[n-m+1 .. n]) then
    repeat
     bool := true;
      for k in [n..n+m-1] do
        if Intersection(k-primitives,elements) <> [] then
           AddSet(elements,k);
         else
          bool := false;
          n := k+1;
          break;
        fi;  
      od;
    until bool;
  fi;
  ## set gaps, Frobenius number and small elements
  if Length(elements) > 1 then
    gaps := Difference([1..Maximum(elements)],elements);
  else
    gaps := [];
  fi;
  SetGapsOfNumericalSemigroup(ns,gaps);
  ## setFrobenius number
  if gaps = [] then
    frob := -1;
  else
    frob := Maximum(gaps);
  fi;
  SetFrobeniusNumberOfNumericalSemigroup(ns,frob);
  ## set small elements
  smalls := Intersection([0..frob+1],elements);
  SetSmallElements(ns, smalls);
  ##
  return smalls;

end);



# InstallMethod(SmallElementsOfNumericalSemigroup,
#         "Returns the list of elements in the numerical semigroup not greater that the Frobenius number + 1",
#         [IsNumericalSemigroup and HasGenerators],1,
#          function( sgp )
#      local g, S, n, bool, gen, R, sumNS, ss;

#     #####################################################
#     # Computes the sum of subsets of numerical semigroups
#     sumNS := function(S,T)
#         local mm, s, t, R;
#         R := [];
#         mm := Minimum(Maximum(S),Maximum(T));
#         for s in S do
#             for t in T do
#                 if s+t > mm then
#                     break;
#                 else
#                     AddSet(R,s+t);
#                 fi;
#             od;
#         od;
#         return R;
#     end;
#     if HasMinimalGenerators(sgp) then
#         gen := MinimalGenerators(sgp);
#     else
#         gen := Generators(sgp);
#         # a naive reduction of the number of generators
#         ss := sumNS(gen,gen);
#         gen := Difference(gen,ss);
#         if ss <> [] then
#             gen := Difference(gen,sumNS(ss,gen));
#         fi;
#     fi;

#     S := [0];
#     n := 1;
#     bool := true;
#     while bool do
#         for g in gen do
#             if n -g in S then
#                 AddSet(S,n);
#                 break;
#             fi;
#         od;
#         if not IsSubset(S,[S[Length(S)]-gen[1]+1..S[Length(S)]]) then
#             n:=n+1;
#         else
#             bool := false;
#         fi;
#     od;
#     if Length(S) > 1 then
#         SetGapsOfNumericalSemigroup(sgp,AsList(Difference([1..S[Length(S)]],S)));
#     fi;
#     R := GapsOfNumericalSemigroup(sgp);
#     if R = [] then
#         g := -1;
#     else
#         g := R[Length(R)];
#     fi;
#     SetFrobeniusNumberOfNumericalSemigroup(sgp,g);

#     SetSmallElements(sgp, Intersection([0..g+1],Union(S, [g+1])));
#     return SmallElements(sgp);
# end);



#############################################################################
##
#A  SmallElementsOfNumericalSemigroup(S)
##
##  Returns the list of the elements of S(a,b)
##  in [0..b].
##
#############################################################################
InstallMethod(SmallElementsOfNumericalSemigroup,
        "Returns the list of elements in the numerical semigroup not greater that the Frobenius number + 1",
        [IsNumericalSemigroup and HasModularConditionNS],20,
         function( sgp )
    local a, b, g, R, S, x;
    a := ModularConditionNS(sgp)[1];
    b := ModularConditionNS(sgp)[2];
    S := [0];
    for x in [1..b] do
        if a*x <= x or RemInt(a*x,b) <= x then
            Add(S,x);
        fi;
    od;
    if Length(S) > 1 then
        SetGapsOfNumericalSemigroup(sgp,AsList(Difference([1..S[Length(S)]],S)));
    fi;
    R := GapsOfNumericalSemigroup(sgp);
    if R = [] then
        g := -1;
    else
        g := R[Length(R)];
    fi;
    SetFrobeniusNumberOfNumericalSemigroup(sgp,g);

    SetSmallElements(sgp, Intersection([0..g+1],Union(S, [g+1])));
    return SmallElements(sgp);
end);



#############################################################################
##
#A  SmallElementsOfNumericalSemigroup(S)
##
##  Returns the list of the elements of S(a,b,c)
##  in [0..b].
##
#############################################################################
InstallMethod(SmallElementsOfNumericalSemigroup,
        "Returns the list of elements in the numerical semigroup not greater that the Frobenius number + 1",
        [IsNumericalSemigroup and HasProportionallyModularConditionNS],20,
         function( sgp )
   local a, b, c, g, R, S, x;
    a := ProportionallyModularConditionNS(sgp)[1];
    b := ProportionallyModularConditionNS(sgp)[2];
    c := ProportionallyModularConditionNS(sgp)[3];
    S := [0];
    for x in [1..b] do
        if a*x <= c*x or RemInt(a*x,b) <= c*x then
            Add(S,x);
        fi;
    od;

    if Length(S) > 1 then
        SetGapsOfNumericalSemigroup(sgp,AsList(Difference([1..S[Length(S)]],S)));
    fi;
    R := GapsOfNumericalSemigroup(sgp);
    if R = [] then
        g := -1;
    else
        g := R[Length(R)];
    fi;
    SetFrobeniusNumberOfNumericalSemigroup(sgp,g);

    SetSmallElements(sgp, Intersection([0..g+1],Union(S, [g+1])));
    return SmallElements(sgp);
end);


#############################################################################
##
#A  SmallElementsOfNumericalSemigroup(S)
##
##  Computes the numerical semigroup consiting of the non negative integers
##  of the submonoid of RR generated by the interval ]r,s[ where r and s
##  are rational numbers.
##
#############################################################################
InstallMethod(SmallElementsOfNumericalSemigroup,
    "Returns the list of elements in the numerical semigroup not greater that the Frobenius number + 1",
        [IsNumericalSemigroup and HasOpenIntervalNS],10,
         function( sgp )
    local   r,  s,  k,  max,  NS,  i,  R,  g;

    r := OpenIntervalNS(sgp)[1];
    s := OpenIntervalNS(sgp)[2];

    k := 1;
    while k*s <= (k+1)*r do
        k := k+1;
    od;
    max := Int(k * s);
    NS := [0];
    for i in [1..k] do
        NS := Union(NS, Filtered([1..max+1], j -> (i*r < j) and (j < i *s)));
    od;

    if Length(NS) > 1 then
        SetGapsOfNumericalSemigroup(sgp,AsList(Difference([1..NS[Length(NS)]],NS)));
    fi;
    R := GapsOfNumericalSemigroup(sgp);
    if R = [] then
        g := -1;
    else
        g := R[Length(R)];
    fi;
    SetFrobeniusNumberOfNumericalSemigroup(sgp,g);

    SetSmallElements(sgp, Intersection([0..g+1],Union(NS, [g+1])));
    return SmallElements(sgp);
end);



#############################################################################
##
#A  SmallElementsOfNumericalSemigroup(S)
##
##  Given a subadditive function which is periodic with period Length(L)
##  produces the corresponding numerical semigroup
##
##  The periodic subadditive function is given through a list and
##  the last element of the list must be 0.
##
#############################################################################
InstallMethod(SmallElementsOfNumericalSemigroup,
        "Returns the list of elements in the numerical semigroup not greater that the Frobenius number + 1",
        [IsNumericalSemigroup and HasSubAdditiveFunctionNS],10,
         function( sgp )
    local   L,  m,  F,  S,  x,  fx,  R,  g;

    L := SubAdditiveFunctionNS(sgp);

    m := Length(L);
    F := Maximum(L) + m +1;
    S := [0];
    for x in [1..F] do
        if x mod m <> 0 then
            fx := L[x mod m];
        else
            fx := 0;
        fi;
        if fx <= x then
            Add(S,x);
        fi;
    od;

    if Length(S) > 1 then
        SetGapsOfNumericalSemigroup(sgp,AsList(Difference([1..S[Length(S)]],S)));
    fi;
    R := GapsOfNumericalSemigroup(sgp);
    if R = [] then
        g := -1;
    else
        g := R[Length(R)];
    fi;
    SetFrobeniusNumberOfNumericalSemigroup(sgp,g);

    SetSmallElements(sgp, Intersection([0..g+1],Union(S, [g+1])));
    return SmallElements(sgp);
end);

#############################################################################
##
#F  SmallElements(S)
##
##  If S is a numerical semigroup, then this function just passes the task of computing the minimal generating system to SmallElementsOfNumericalSemigroup
## If S is an ideal of numerical semigroup, then this function just passes the task of computing the minimal generating system to SmallElementsOfIdealOfNumericalSemigroup
##
##
# InstallGlobalFunction(SmallElements,
#         function(S)
#   if IsNumericalSemigroup(S) then
#     return SmallElementsOfNumericalSemigroup(S);
#   elif IsIdealOfNumericalSemigroup(S) then
#     return SmallElementsOfIdealOfNumericalSemigroup(S);
#   else
#     Error("The argument must be a numerical semigroup or an ideal of a numerical semigroup.");
#   fi;
# end);

#############################################################################
##
#A  GapsOfNumericalSemigroup(S)
##
##  Returns the list of the gaps of the numerical semigroup S.
##
#############################################################################
InstallMethod(GapsOfNumericalSemigroup,
        "Returns the list of the gaps of a numerical semigroup",
        [IsNumericalSemigroup],
        function( sgp )
    local S;
    S := SmallElementsOfNumericalSemigroup(sgp);
    return Difference([1..S[Length(S)]],S);
end);


#############################################################################
##
#A  Weight(S)
##
##  Returns the sum of all  gaps of the numerical semigroup S.
##
#############################################################################
InstallMethod(Weight,
    "Returns the sum of all gaps of a numerical semigroup",
    [IsNumericalSemigroup],
    function(sgp)
    return Sum(Gaps(sgp)-[1..Genus(sgp)]);
end);

#############################################################################
##
#F  DesertsOfNumericalSemigroup(S)
##
##  Returns the lists of runs of gaps of the numerical semigroup S
##
#############################################################################
InstallGlobalFunction(DesertsOfNumericalSemigroup, function(s)
  local ds, gs, run, g;

  if not(IsNumericalSemigroup(s)) then
    Error("The argument must be a numerical semigroup");
  fi;

  ds:=[];
  gs:=GapsOfNumericalSemigroup(s);
  if gs=[] then
    return [];
  fi;

  run:=[];
  for g in gs do
    Add(run,g);
    if not(g+1 in gs) then
      Add(ds,run);
      run:=[];
    fi;
  od;

  return ds;
end);

InstallMethod(Deserts,
    "for numerical semigroups",
    [IsNumericalSemigroup],
    DesertsOfNumericalSemigroup);

#############################################################################
##
#A  GenusOfNumericalSemigroup(S)
##
##  Returns the number of gaps of the numerical semigroup S.
##
#############################################################################
InstallMethod(GenusOfNumericalSemigroup,
        "Returns the genus of the numerical semigroup",
        [IsNumericalSemigroup],10,
        function( sgp )
	return Length(GapsOfNumericalSemigroup(sgp));
end);


#############################################################################
##
#A  WilfNumberOfNumericalSemigroup(S)
##
##  Let c,edim and se be the conductor, embedding dimension and number of
##  elements smaller than c in S. Returns the edim*se-c, which was conjetured
##  by Wilf to be nonnegative.
##
#############################################################################
InstallMethod(WilfNumberOfNumericalSemigroup,
        "Returns the Wilf number of the numerical semigroup",
        [IsNumericalSemigroup],10,
         function(s)
    local se, edim, c;

    edim:=EmbeddingDimensionOfNumericalSemigroup(s);
    c:=ConductorOfNumericalSemigroup(s);
    se:=Length(SmallElements(s))-1;
    return edim*se-c;
end);

#############################################################################
##
#A  TruncatedWilfNumberOfNumericalSemigroup(S)
#A  EliahouNumber
##
##  Returns W_0(S) (see [E])
##
#############################################################################
InstallMethod(TruncatedWilfNumberOfNumericalSemigroup,
        "Returns the Eliahou number of the numerical semigroup",
        [IsNumericalSemigroup],10,
function(s)
    local se, edim, c, msg, dq, smsg, r,m,q;
    msg:=MinimalGeneratingSystem(s);
    m:=Minimum(msg);
    edim:=Length(msg);
    c:=ConductorOfNumericalSemigroup(s);
    smsg:=Length(Intersection(msg,[0..c-1]));
    se:=Length(SmallElements(s))-1;
    q:=CeilingOfRational(c/m);
    r:=q*m-c;
    dq:=Length(Difference([c..c+m-1],msg));
    return smsg*se-q*dq+r;

end);


#############################################################################
##
#F  ProfileOfNumericalSemigroup(S)
##
##  Returns the profile of a numerical semigroup (see [E]);
##  corresponds with the sizes of the intervals (except the last) returned by
##  EliahouSliceOfNumericalSemigroup(S)
##
#############################################################################
InstallGlobalFunction(ProfileOfNumericalSemigroup,function(s)
    local c, m, msg, r, q;
    if not IsNumericalSemigroup(s) then
        Error("The argument must be a numerical semigroup");
    fi;
    m:=MultiplicityOfNumericalSemigroup(s);
    c:=ConductorOfNumericalSemigroup(s);
    msg:=MinimalGeneratingSystem(s);
    q:=CeilingOfRational(c/m);
    r:=q*m-c;
    return List([1..q-1],i->Length(Intersection(msg,[i*m-r..(i+1)*m-r-1])));

end);

#############################################################################
##
#F  EliahouSlicesOfNumericalSemigroup(S)
##
##  Returns a list of lists of integers, each list is the set of elements in
##  S belonging to [jm-r, (j+1)m-r[ where m is the mulitiplicity of S,
##  and j in [1..q-1]; with q,r such that c=qm-r, c the conductor of S
##  (see [E])
##
#############################################################################
InstallGlobalFunction(EliahouSlicesOfNumericalSemigroup,function(s)
    local c, m, msg, r, q;
    if not IsNumericalSemigroup(s) then
        Error("The argument must be a numerical semigroup");
    fi;
    m:=MultiplicityOfNumericalSemigroup(s);
    c:=ConductorOfNumericalSemigroup(s);
    msg:=MinimalGeneratingSystem(s);
    q:=CeilingOfRational(c/m);
    r:=q*m-c;
    return List([1..q-1],i->Intersection(s,[i*m-r..(i+1)*m-r-1]));

end);

#########################################################
##
#F LatticePathAssociatedToNumericalSemigroup(s,p,q)
##
## s is a numerical semigroup, and p,q are elements in s
## Then s is an oversemigroup of <p,q> and all its gaps
## are gaps of <p,q>. If c is the conductor of <p,q>,
## every gap g in <p,q> is expressed uniquely as
## g=c-1-(ap+bq) for some nonnegative integers a and b,
## whence g has associated coordinates (a,b)
## The output is the path in N^2 such that every point
## in N^2 corresponding to a gap of <p,q> above the path
## correspond to gaps of s (see [K-W])
#########################################################
InstallGlobalFunction(LatticePathAssociatedToNumericalSemigroup, function(s,p,q)

    local gaps, coords, c, le;

    le:=function(p1,p2)
        return ((p1[1]<=p2[1]) and (p1[2]<=p2[2]));
    end;


    if not(IsNumericalSemigroup(s)) then
        Error("The first argument must be a numerical semigroup");
    fi;

    if not((p in s) and (q in s)) then
        Error("The second and third argument must be elements in the semigroup");
    fi;

    gaps:=GapsOfNumericalSemigroup(s);

    c:=ConductorOfNumericalSemigroup(NumericalSemigroup(p,q));
    coords:=List(gaps, g-> FactorizationsIntegerWRTList(c-1-g,[p,q])[1]);
    Info(InfoNumSgps,2,"Coordinates of gaps wrt p,q\n",coords);
    return Filtered(coords, x->Filtered(coords, y ->le(x,y))=[x]);

end);
