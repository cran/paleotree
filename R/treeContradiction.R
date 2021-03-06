#' Measure the Contradiction Difference Between Two Phylogenetic Topologies
#' 
#' An alternative measure of pair-wise dissimilarity between two tree topologies which ignores differences in phylogenetic
#' resolution between the two, unlike typical metrics (such as Robinson-Foulds distance). The metric essentially counts up
#' the number of splits on both trees that are directly contradicted by a split on the contrasting topology (treating both
#' as unrooted). By default, this 'contradiction difference' value is then scaled to between 0 and 1, by dividing by the total number
#' of splits that could have been contradicted across both trees ( 2 * (Number of shared tips - 2) ). On this scaled, 0 represents
#' no conflicting relationships and 1 reflects two entirely conflicting topologies, similar to the rescaling in Colless's consensus fork index.
#' 

#' @details
#' Algorithmically, conflicting splits are identified by counting the number of splits
#' (via \code{ape}'s \code{prop.part}) on one tree that disagree with at least one split
#' on the other tree: for example, split (AB)CD would be contradicted by split (AC)BD. To
#' put it another way, all we need to test for is whether the taxa segregated by that split
#' were found to be more closely related to some other taxa, not so segregated by the
#' considered split. 
#' 
#' This metric was designed mainly for use with trees that differ in their resolution, 
#' particularly when it is necessary to compare between summary trees 
#' (such as consensus trees of half-compatibility summaries) from separate phylogenetic analyses.
#' Note that comparing summary trees can be problematic in some instances, 
#' and users should carefully consider their question of interest, 
#' and whether it may be more ideal to consider whole samples of trees 
#' (e.g., the posterior sample, or the sample of most parsimonious trees).
#' 
#' The contradiction difference is \emph{not} a metric distance: 
#' most notably, the triangle inequality is not held and thus
#' the 'space' it describes between topologies is not a metric space. 
#' This can be shown most simply when considering any two
#' different but fully-resolve topologies and a third topology that is a star tree. 
#' The star tree will have a zero pair-wise CD with either fully-resolved phylogeny, 
#' but there will be a positive CD between the fully-resolved trees. 
#' An example of this is shown in the examples below.
#' 
#' The CD also suggest very large differences when small numbers of taxa shift
#'  greatly across the tree, a property shared by
#' many other typical tree comparisons, such as RF distances. See examples below.

#' @param tree1,tree2 Two phylogenies, with the same number of tips and 
#' an identical set of tip labels, both of class \code{phylo}. 

#' @param rescale A logical.  If \code{FALSE}, the raw number of contradicted 
#' splits across both trees is reported.
#' If \code{TRUE} (the default), the contradiction difference value is 
#' returned rescaled to the total number of splits across 
#' both input trees that could have contradicted.

#' @return
#' The contradiction difference between two trees is reported as a single numeric variable.

#' @seealso
#' See \code{phangorn}'s function for calculating the Robinson-Foulds distance: \code{\link[phangorn]{treedist}}.
#' 
#' Graeme Lloyd's \code{metatree} package, currently not on CRAN,
#' also contains the function \code{MultiTreeDistance}
#' for calculating both the contradiction difference measure and the Robinson-Foulds distance. 
#' This function is optimized for very large samples of trees or very large
#' trees, and thus may be faster than \code{treeContradiction}.
#' Also see the function \code{MultiTreeContradiction} in the same package.

# R CHECK doesn't like this because metatree isnt on CRAN:
# \code{\link[metatree]{MultiTreeContradiction}}

#' @author
#' David W. Bapst. This code was produced as part of a project 
#' funded by National Science Foundation grant EAR-1147537 to S. J. Carlson.

#' @references
#' This contradiction difference measure was introduced in:
#' 
#' Bapst, D. W., H. A. Schreiber, and S. J. Carlson. 2018. Combined Analysis of Extant Rhynchonellida
#' (Brachiopoda) using Morphological and Molecular Data. \emph{Systematic Biology} 67(1):32-48. 


#' @examples
#' 
#' # let's simulate two trees
#' 
#' set.seed(1)
#' treeA <- rtree(30,br = NULL)
#' treeB <- rtree(30,br = NULL)
#' 
#' \dontrun{
#' 
#' # visualize the difference between these two trees
#' library(phytools)
#' plot(cophylo(treeA,treeB))
#' 
#' # what is the Robinson-Foulds (RF) distance between these trees?
#' library(phangorn)
#' treedist(treeA,treeB)
#' 
#' }
#' 
#' # The RF distance is less intuitive when 
#'     # we consider a tree that isn't well-resolved
#' 
#' # let's simulate the worst resolved tree possible: a star tree
#' treeC <- stree(30)
#' 
#' \dontrun{
#' # plot the tanglegram between A and C
#' plot(cophylo(treeA,treeC))
#' 
#' # however the RF distance is *not* zero
#' # even though the only difference is a difference in resolution
#' treedist(treeA,treeC)
#' }
#' 
#' # the contradiction difference (CD) ignores differences in resolution
#' 
#' # Tree C (the star tree) has zero CD between it and trees A and B
#' identical(treeContradiction(treeA,treeC),0)  # should be zero distance
#' identical(treeContradiction(treeB,treeC),0)  # should be zero distance
#' 
#' # two identical trees also have zero CD between them (as you'd hope) 
#' identical(treeContradiction(treeA,treeA),0)  # should be zero distance
#' 
#' #' and here's the CD between A and B
#' treeContradiction(treeA,treeB)  # should be non-zero distance
#' 
#' # a less ideal property of the CD is that two taxon on opposite ends of the 
#' # moving from side of the topology to the other of an otherwise identical tree
#' # will return the maximum contradiction difference possible (i.e., ` =  1`)
#' 
#' # an example
#' treeAA <- read.tree(text = "(A,(B,(C,(D,(E,F)))));")
#' treeBB <- read.tree(text = "(E,(B,(C,(D,(A,F)))));")
#' 
#' \dontrun{
#' plot(cophylo(treeAA,treeBB))
#' }
#' 
#' treeContradiction(treeAA,treeBB)
#' 
#' \dontrun{
#' # Note however also a property of RF distance too:
#' treedist(treeAA,treeBB)
#' }
#' 


#' @name treeContradiction
#' @rdname treeContradiction
#' @export
treeContradiction <- function(tree1,tree2,rescale = TRUE){
  # checks
  if(!inherits(tree1, "phylo")){
		stop("tree1 is not of class phylo")
    }
  if(!inherits(tree2, "phylo")){
		stop("tree2 is not of class phylo")
    }
  #
  tree1 <- drop.tip(tree1,setdiff(tree1$tip.label,tree2$tip.label))
  tree2 <- drop.tip(tree2,setdiff(tree2$tip.label,tree1$tip.label))
  #
  # more checks
  if(Ntip(tree1) != Ntip(tree2)){
      stop("Trees do not contain same number of tips after pruning to tips with identical labels (?!)")}
  if(Ntip(tree1)<2 | Ntip(tree2)<2){
      stop("Trees contain less than one tip after pruning")}
  #
  # now measure number of contraditions
  nUnshared <- sum(1 == attr(prop.part(tree1,tree2),"number"))
  part1 <- lapply(prop.part(tree1),function(x) tree1$tip.label[x])
  part2 <- lapply(prop.part(tree2),function(x) tree2$tip.label[x])
  nContra1 <- nContradiction(part1,part2)
  nContra2 <- nContradiction(part2,part1)
  res <- nContra1+nContra2
  #
  # rescale to 0-1 scale?
  if(rescale){
    #number of possible nodes that could contradict on one unrooted tree
    nPossNodes <- Ntip(tree1)-2   # per tree   
    res <- res/(2*nPossNodes)     # per two trees
    }
  return(res)
  }
  
  
testContradiction <- function(namesA,namesB){
	matchA <- namesA %in% namesB
	matchB <- namesB %in% namesA
	if(any(matchB)){
		res <- !(all(matchA) | all(matchB))
	}else{
		res <- FALSE
		}
	return(res)
	}
  
  
nContradiction <- function(partA,partB){
  partContra <- sapply(partA,function(x) 
      any(sapply(partB,function(y) 
        testContradiction(x,y))))  
  res <- sum(partContra)
  return(res)
  }
