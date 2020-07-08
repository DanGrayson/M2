-- -*- coding: utf-8 -*-
newPackage(
	"SubalgebraBases",
	AuxiliaryFiles => true,
    	Version => "0.1", 
    	Date => "November 24, 2006",
    	Authors => {{Name => "Mike Stillman", 
		  Email => "mike@math.cornell.edu", 
		  HomePage => "http://www.math.cornell.edu/~mike/"}},
    	Headline => "canonical subalgebra bases (sagbi bases)"
    	)

export {"subalgebraBasis", "sagbi" => "subalgebraBasis", "PrintLevel"}

load "SubalgebraBases/sagbi-common.m2"
load "SubalgebraBases/sagbitop.m2"
load "SubalgebraBases/sagbieng.m2"
load "SubalgebraBases/sagbi-tests.m2"

beginDocumentation()

doc ///
   Key
     SubalgebraBases
   Headline
     a package for finding canonical subalgebra bases (aka SAGBI bases)
   Description
    Text
      Let $R=k[f_1,\ldots,f_k]$ denote the subalgebra of the polynomial ring $k[x_1,\ldots,x_n]$ generated by $f_1,\ldots ,f_k.$ We say 
      $f_1,\ldots,f_k$ form a {\it subalgebra basis} with respect to a monomial order $<$ if the {\it initial algebra}
      associated to $<$, defined as $in(R) := k[in(f) \mid f \in R],$ is generated by the elements
      $in(f_1), \ldots , in(f_k).$ 
///

doc ///
   Key
     subalgebraBasis
     (subalgebraBasis,Matrix)
     [subalgebraBasis,Limit]
     [subalgebraBasis,PrintLevel]
     [subalgebraBasis,Strategy]
   Headline
     subalgebra basis (sagbi basis)
   Usage
     N = subalgebraBasis M    
   Inputs
     M:Matrix
       $1\times k$ with entries in a @TO "PolynomialRing"@
     Limit=>ZZ
       the maximum number of subalgebra generators to return
     PrintLevel=>ZZ
     Strategy=>String
   Outputs
     N:Matrix
       $1\times r,$ with $r\le $ "Limit" above, whose entries form a partial subalgebra basis
   Description
    Text
      
    Example
      R=QQ[x,t]
      M=matrix{{t*x^3,t*(x^2+1),t*x}}
      N=subalgebraBasis M
    Text
      
    Example
      R=QQ[x,y,MonomialOrder=>Lex]
      M=matrix{{x+y,x*y,x*y^2}}
      N=subalgebraBasis(M,Limit=>10)
      N'=subalgebraBasis(M,Limit=>20)
      N'=subalgebraBasis(M,Limit=>20,Strategy=>Engine)
      (numcols N,numcols N')
    Text
      Some references for Subalgebra bases (aka canonical subalgebra bases, SAGBI bases):
      
      Kapur, D., Madlener, K. (1989). A completion procedure for computing a canonical basis of a $k$-subalgebra.
      Proceedings of {\it Computers and Mathematics 89} (eds. Kaltofen and Watt), MIT, Cambridge, June 1989,

      Robbiano, L., Sweedler, M. (1990). Subalgebra bases,
      in W.~Bruns, A.~Simis (eds.): {\it Commutative Algebra},
      Springer Lecture Notes in Mathematics {\bf 1430}, pp.~61--87,
     
      F. Ollivier, Canonical Bases: Relations with Standard bases, finiteness
      conditions and applications to tame automorphisms, in Effective Methods
      in Algebraic Geometry, Castiglioncello 1990, pp. 379-400, 
      Progress in Math. {\bf 94} Birkhauser, Boston (1991),
     
      B. Sturmfels, Groebner bases and Convex Polytopes, Univ. Lecture 
      Series 8, Amer Math Soc, Providence, 1996      
   Caveat
   SeeAlso
///

end--

document { 
	Key => SubalgebraBases,
	Headline => "a package for finding canonical subalgebra bases (sagbi bases)",
	EM "SubalgebraBases", " is "
	}


{
	Key => {(subalgebraBasis,Matrix),sagbi},
	Headline => "subalgebra basis (sagbi basis)",
	Usage => "sagbi M\nsubalgebraBasis M",
	Inputs => { "M"},
	Outputs => { Matrix => { "
		  whose entries form a subalgebra basis (sagbi) 
                  of the subalgebra generated by the entries of the matrix M"}
              },
     	 "This routine computes a sagbi basis degree by degree,
     	 for a graded or nongraded subalgebra.",
	 Caveat => "M should be a matrix over a polynomial ring over a field,
     	 and NOT a quotient ring.",
     PARA{},
     TEX ///References: Kapur, D., Madlener, K. (1989). A completion procedure
     for computing a canonical basis of a $k$-subalgebra.
     Proceedings of {\it Computers and Mathematics 89}
     (eds. Kaltofen and Watt), MIT, Cambridge, June 1989.///,
     PARA{},
     TEX ///Robbiano, L., Sweedler, M. (1990). Subalgebra bases,
     in W.~Bruns, A.~Simis (eds.): {\it Commutative Algebra},
     Springer Lecture Notes in Mathematics {\bf 1430}, pp.~61--87.///,
     PARA{},
     TEX ///F. Ollivier, Canonical Bases: Relations with Standard bases, finiteness
     conditions and applications to tame automorphisms, in Effective Methods
     in Algebraic Geometry, Castiglioncello 1990, pp. 379-400, 
     Progress in Math. {\bf 94} Birkhauser, Boston (1991)///,
     PARA{},
     TEX ///B. Sturmfels, Groebner bases and Convex Polytopes, Univ. Lecture 
     Series 8, Amer Math Soc, Providence, 1996///
	}




uninstallPackage "SubalgebraBases"
restart
installPackage "SubalgebraBases"

restart
needsPackage "SubalgebraBases"

R=QQ[x,y,MonomialOrder=>Lex]
M=matrix{{x+y,x*y,x*y^2}}
N=subalgebraBasis(M,Limit=>3,Strategy=>Engine)


viewHelp "SubalgebraBases"

load "SubalgebraBases/sagbi-tests.m2"
needsPackage "SubalgebraBases"
check "SubalgebraBases"