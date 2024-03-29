% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/makePBDBtaxonTree.R
\name{makePBDBtaxonTree}
\alias{makePBDBtaxonTree}
\alias{plotTaxaTreePBDB}
\title{Creating a Taxon-Tree from Taxonomic Data Downloaded from the Paleobiology Database}
\usage{
makePBDBtaxonTree(
  taxaDataPBDB,
  rankTaxon,
  method = "parentChild",
  tipSet = NULL,
  cleanTree = TRUE,
  annotatedDuplicateNames = TRUE,
  APIversion = "1.2",
  failIfNoInternet = TRUE
)

plotTaxaTreePBDB(taxaTree, edgeLength = 1)
}
\arguments{
\item{taxaDataPBDB}{A table of taxonomic data collected from
the Paleobiology Database, using the taxa list option
with \code{show = class}. Should work with versions 1.1-1.2 of
the API, with either the \code{pbdb} or \code{com} vocab. However,
as \code{accepted_name} is not available in API v1.1, the resulting
tree will have a taxon's *original* name and not
any formally updated name.}

\item{rankTaxon}{The selected taxon rank; must be one of \code{'species'},
\code{'genus'}, \code{'family'}, \code{'order'}, \code{'class'} or \code{'phylum'}.}

\item{method}{Controls which algorithm is used for calculating
the taxon-tree. The default option is \code{method  = "parentChild"}
which converts the listed binary parent-child taxon relationships in
the Paleobiology Database- these parent-child relationships (if missing
from the input dataset) are autofilled using API calls to the
Paleobiology Database. Alternatively, users may use
\code{method = "Linnean"}, which converts the table of Linnean taxonomic
assignments (family, order, etc as provided by \code{show = class} in
PBDB API calls) into a taxon-tree. Two methods formerly both implemented
under \code{method  = "parentChild"} are also available as
\code{method = "parentChildOldMergeRoot"} and \code{method = "parentChildOldQueryPBDB"}
respectively. Both of these use similar algorithms as the current
\code{method  = "parentChild"} but differ in how they treat taxa with
parents missing from the input taxonomic dataset.
\code{method = "parentChildOldQueryPBDB"} behaves most similar
to \code{method = "parentChild"}  in that it queries the Paleobiology
Database via the API , but repeatedly does so for information on parent
taxa of the 'floating' parents, and continues within a \code{while}
loop until only one such unassigned parent taxon remains. This latter
option may talk a long time or never finish, depending on the
linearity and taxonomic structures encountered in the PBDB taxonomic
data; i.e. if someone a taxon was ultimately its own indirect child
in some grand loop by mistake, then under this option
\code{makePBDBtaxonTree} might never finish. In cases where taxonomy
is bad due to weird and erroneous taxonomic assignments reported by
the PBDB, this routine may search all the way back to a very ancient
and deep taxon, such as the \emph{Eukaryota} taxon.
\code{method = "parentChildOldMergeRoot"} will combine these disparate
potential roots and link them to an artificially-constructed
pseudo-root, which at least allows for visualization of the taxonomic
structure in a limited dataset. This latter option will be fully
offline, as it does not do any additional API calls
of the Paleobiology Database, unlike other options.}

\item{tipSet}{This argument only impacts analyses where 
\code{method  = "parentChild"} is used. This \code{tipSet} argument controls
which taxa are selected as tip taxa for the output tree. 
\code{tipSet  = "nonParents"} selects all child taxa which
are not listed as parents in \code{parentChild}.
Alternatively, \code{tipSet = "all"} will add a tip to every
internal node with the parent-taxon name encapsulated in parentheses.
The default is \code{NULL} - if \code{tipSet = NULL} and \code{method  = "parentChild"},
then \code{tipSet} will be set so \code{tipSet = "nonParents"}.}

\item{cleanTree}{When \code{TRUE} (the default), the tree is run through a series of
post-processing, including having singles collapsed,
nodes reordered and being written out as a Newick string and read
back in, to ensure functionality with ape functions
and ape-derived functions. 
If \code{FALSE}, none of this post-processing is done and
users should beware, as such trees can lead to hard-crashes of R.}

\item{annotatedDuplicateNames}{A logical determining whether duplicate taxon names,
when found in the Paleobiology Database for taxa (presumably reflecting an issue with
taxa being obsolete but with incomplete seniority data), should be annotated to include
sequential numbers so to modify them, via function\code{base}'s
\code{\link[base]{make.unique}}. This only applies to
\code{method = "parentChild"}, with the default option being
\code{annotatedDuplicateNames = TRUE}. If more than 26 duplicates are found, an error
is issued. If this argument is \code{FALSE}, an error is issued if duplicate taxon
names are found.}

\item{APIversion}{Version of the Paleobiology Database API used by
\code{makePBDBtaxonTree} when \code{method  = "parentChild"} or
\code{method  = "parentChildOldQueryPBDB"} is used. The current default
is \code{APIversion = "1.2"}, the most recent API version as of 12/11/2018.}

\item{failIfNoInternet}{If the Paleobiology Database or another 
needed internet resource cannot be accessed, perhaps because of
no internet connection, should the function fail (with an error)
or should the function return \code{NULL} and return an
informative message instead, thus meeting the CRAN policy
that such functionalities must 'fail gracefully'?
The default is \code{TRUE} but all examples that might be auto-run
use \code{FALSE} so they do not fail during R CHECK.}

\item{taxaTree}{A phylogeny of class \code{phylo}, presumably a taxon tree as output from
\code{makePBDBtaxonTree} with higher-taxon names as node labels.}

\item{edgeLength}{The edge length that the plotted tree should be plotted
with (\code{plotTaxaTreePBDB} plots phylogenies as non-ultrametric,
not as a cladogram with aligned tips).}
}
\value{
A phylogeny of class \code{phylo}, where each tip is a taxon of the given \code{rankTaxon}. See additional details
regarding branch lengths can be found in the sub-algorithms used to create the taxon-tree by this function:
\code{\link{parentChild2taxonTree}} and \code{\link{taxonTable2taxonTree}}.

Depending on the \code{method}
used, either the element \code{$parentChild} or \code{$taxonTable} is added to the list structure of
the output phylogeny object, which was used as input for one of the two algorithms mentioned above.

Please note that when applied to output from the taxa option of the API version 1.1, the taxon names
returned are the \emph{original} taxon names as 'accepted_name' is not available in API v1.1, while
under API v1.2, the returned taxon names should be the most up-to-date formal names for those taxa.
Similar issues also effect the identification of parent taxa, as the accepted name of the
parent ID number is only provided in version 1.2 of the API.
}
\description{
The function \code{makePBDBtaxonTree} creates phylogeny-like 
object of class \code{phylo} from the taxonomic information
recorded in a taxonomy download from the PBDB for
a given group. Two different algorithms are provided,
the default being based on parent-child taxon relationships,
the other based on the nested Linnean hierarchy. The function
\code{plotTaxaTreePBDB} is also provided as a minor helper
function for optimally plotting the labeled topologies that are
output by \code{makePBDBtaxonTree}.
}
\details{
This function should not be taken too seriously.
Many groups in the Paleobiology Database have
out-of-date or very incomplete taxonomic information.
This function is meant to help visualize
what information is present, and by use of time-scaling
functions, allow us to visualize the intersection
of temporal and phylogenetic, mainly to look for incongruence
due to either incorrect taxonomic placements,
erroneous occurrence data or both. 

Note however that, contrary to common opinion among some
paleontologists, taxon-trees may be just as useful for 
macroevolutionary studies as reconstructed phylogenies
(Soul and Friedman, 2015).
}
\examples{
# Note that most examples here use argument 
    # failIfNoInternet = FALSE so that functions do
    # not error out but simply return NULL if internet
    # connection is not available, and thus
    # fail gracefully rather than error out (required by CRAN).
# Remove this argument or set to TRUE so functions DO fail
    # when internet resources (paleobiodb) is not available.

set.seed(1)

\donttest{

#get some example occurrence and taxonomic data
data(graptPBDB)

#get the taxon tree: Linnean method
graptTreeLinnean <- makePBDBtaxonTree(
    taxaDataPBDB = graptTaxaPBDB,
    rankTaxon = "genus",
    method = "Linnean", 
    failIfNoInternet = FALSE)

#get the taxon tree: parentChild method
graptTreeParentChild <- makePBDBtaxonTree(
    taxaDataPBDB = graptTaxaPBDB,
    rankTaxon = "genus",
    method = "parentChild", 
    failIfNoInternet = FALSE)
    
if(!is.null(graptTreeParentChild) & 
        !is.null(graptTreeLinnean)){
    # if those functions worked...
    # let's plot these and compare them! 
    plotTaxaTreePBDB(graptTreeParentChild)
    plotTaxaTreePBDB(graptTreeLinnean)
    }


# pause 3 seconds so we don't spam the API
Sys.sleep(3)

####################################################
# let's try some other groups

###################################
#conodonts

conoData <- getCladeTaxaPBDB("Conodonta", 
    failIfNoInternet = FALSE)

if(!is.null(conoData)){ 
 
conoTree <- makePBDBtaxonTree(
    taxaDataPBDB = conoData,
    rankTaxon = "genus",
    method = "parentChild")

# if it worked, plot it!
plotTaxaTreePBDB(conoTree)

}

# pause 3 seconds so we don't spam the API
Sys.sleep(3)

#############################
#asaphid trilobites

asaData <- getCladeTaxaPBDB("Asaphida", 
    failIfNoInternet = FALSE)
    
if(!is.null(asaData)){

asaTree <- makePBDBtaxonTree(
    taxaDataPBDB = asaData,
    rankTaxon = "genus",
    method = "parentChild")

# if it worked, plot it!
plotTaxaTreePBDB(asaTree)

}

# pause 3 seconds so we don't spam the API
Sys.sleep(3)

###############################
#Ornithischia

ornithData <- getCladeTaxaPBDB("Ornithischia", 
    failIfNoInternet = FALSE)

if(!is.null(ornithData)){

ornithTree <- makePBDBtaxonTree(
    taxaDataPBDB = ornithData,
    rankTaxon = "genus",
    method = "parentChild")

# if it worked, plot it!
plotTaxaTreePBDB(ornithTree)

# pause 3 seconds so we don't spam the API
Sys.sleep(3)

#try Linnean!

#but first... need to drop repeated taxon first: Hylaeosaurus
    # actually this taxon seems to have been repaired 
    # as of September 2019 !
# findHylaeo <- ornithData$taxon_name == "Hylaeosaurus"
# there's actually only one accepted ID number
# HylaeoIDnum <- unique(ornithData[findHylaeo,"taxon_no"])
# HylaeoIDnum 
# so, take which one has occurrences listed
# dropThis <- which((ornithData$n_occs < 1) & findHylaeo)
# ornithDataCleaned <- ornithData[-dropThis,]

ornithTree <- makePBDBtaxonTree(
    ornithData,
    rankTaxon = "genus",
    method = "Linnean", 
    failIfNoInternet = FALSE)

# if it worked, plot it!
plotTaxaTreePBDB(ornithTree)

}

# pause 3 seconds so we don't spam the API
Sys.sleep(3)

#########################
# Rhynchonellida

rhynchData <- getCladeTaxaPBDB("Rhynchonellida", 
    failIfNoInternet = FALSE)
    
if(!is.null(rhynchData)){  

rhynchTree <- makePBDBtaxonTree(
    taxaDataPBDB = rhynchData,
    rankTaxon = "genus",
    method = "parentChild")

    # if it worked, plot it!
    plotTaxaTreePBDB(rhynchTree)
    }

#some of these look pretty messy!

}

}
\references{
Peters, S. E., and M. McClennen. 2015. The Paleobiology Database
application programming interface. \emph{Paleobiology} 42(1):1-7.

Soul, L. C., and M. Friedman. 2015. Taxonomy and Phylogeny Can Yield
Comparable Results in Comparative Palaeontological Analyses. \emph{Systematic Biology} 
(\doi{10.1093/sysbio/syv015})
}
\seealso{
Two other functions in paleotree are used as sub-algorithms by \code{makePBDBtaxonTree}
to create the taxon-tree within this function,
and users should consult their manual pages for additional details:

\code{\link{parentChild2taxonTree}} and \code{\link{taxonTable2taxonTree}}

Closely related functions for 

Other functions for manipulating PBDB data can be found at \code{\link{taxonSortPBDBocc}},
\code{\link{occData2timeList}}, and the example data at \code{\link{graptPBDB}}.
}
\author{
David W. Bapst
}
