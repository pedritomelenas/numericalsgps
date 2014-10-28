#############################################################################
##
#W  affine-def.gd           Manuel Delgado <mdelgado@fc.up.pt>
#W                          Pedro A. Garcia-Sanchez <pedro@ugr.es>
#Y  Copyright .......
#############################################################################

#############################################################################
##
#R  IsAffineSemigroupRep
##
##  The representation of an affine semigroup.
##
#############################################################################
DeclareRepresentation( "IsAffineSemigroupRep",
        IsComponentObjectRep and IsAttributeStoringRep and IsAdditiveElement and IsAdditiveElementWithInverse and IsMultiplicativeElement,
        ["list"]);

#############################################################################
##
#C  IsAffineSemigroup
##
##  The category of affine semigroups.
##
#############################################################################
DeclareCategory( "IsAffineSemigroup", IsObject and IsAffineSemigroupRep);

#############################################################################
##
#C  IsAffineSemigroup
##
##  The family category of affine semigroups.
##
#############################################################################
DeclareCategoryFamily( "IsAffineSemigroup" );

#############################################################################
##
#C  IsAffineSemigroup
##
##  The collections category of numerical semigroups.
##
#############################################################################
DeclareCategoryCollections( "IsAffineSemigroup" );

BindGlobal( "AffineSemigroupsFamily",
        NewFamily( "AffineSemigroups", IsAffineSemigroup ));

BindGlobal( "AffineSemigroupsType",
        NewType( AffineSemigroupsFamily, IsAffineSemigroup));


#############################################################################
##
#F  AffineSemigroupByGenerators(arg)
##
##  Returns the affine semigroup generated by arg.
##
#############################################################################
DeclareGlobalFunction( "AffineSemigroupByGenerators" );
#A
DeclareAttribute( "GeneratorsAS", IsAffineSemigroup);


#############################################################################
##
#F  AffineSemigroupByMinimalGenerators(arg)
##
##  Returns the affine semigroup minimally generated by arg.
##  If the generators given are not minimal, the minimal ones
##  are computed and used.
##
#############################################################################
DeclareGlobalFunction( "AffineSemigroupByMinimalGenerators" );
#A
DeclareAttribute( "MinimalGeneratorsAS", IsAffineSemigroup);


#############################################################################
##
#F  AffineSemigroupByMinimalGeneratorsNC(arg)
##
##  Returns the affine semigroup minimally generated by arg.
##  No test is made about args' minimality.
##
#############################################################################
DeclareGlobalFunction( "AffineSemigroupByMinimalGeneratorsNC" );

#############################################################################
##
#F  GeneratorsOfAffineSemigroup(S)
##
##  Returns a set of generators of the ideal I.
##  If a minimal generating system has already been computed, this
##  is the set returned.
############################################################################
DeclareGlobalFunction("GeneratorsOfAffineSemigroup");
#A
DeclareAttribute( "GeneratorsAS", IsAffineSemigroup);


#############################################################################
##
#F  AffineSemigroup(arg)
##
##  This function's first argument may be one of:
##  "generators", "minimalgenerators", 
## UNDER CONSTRUCTION: equations...
##
##  The following arguments must conform to the arguments of
##  the corresponding function defined above.
##  By default, the option "generators" is used, so,
##  gap> AffineSemigroup([1,3],[7,2],[1,5]);
##  <Affine semigroup in 3-dimensional space, with 3 generators>
##
##
#############################################################################
DeclareGlobalFunction( "AffineSemigroup" );

#############################################################################
##
#P  IsAffineSemigroupByGenerators(S)
##
##  Tests if a affine semigroup was given by its generators.
##
#############################################################################
DeclareProperty( "IsAffineSemigroupByGenerators", IsAffineSemigroup);


#############################################################################
##
#P  IsAffineSemigroupByMinimalGenerators(S)
##
##  Tests if a affine semigroup was given by its minimal generators.
##
#############################################################################
DeclareProperty( "IsAffineSemigroupByMinimalGenerators", IsAffineSemigroup);