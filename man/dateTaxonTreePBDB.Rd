% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dateTaxonTreePBDB.R
\name{dateTaxonTreePBDB}
\alias{dateTaxonTreePBDB}
\title{Date a Taxon-Topology from the Paleobiology Database Using Appearance Data from the API}
\usage{
dateTaxonTreePBDB(
  taxaTree,
  taxaDataPBDB = taxaTree$taxaDataPBDB,
  minBranchLen = 0,
  tipTaxonDateUsed = "shallowestAge",
  dropZeroOccurrenceTaxa = TRUE,
  plotTree = FALSE,
  failIfNoInternet = TRUE
)
}
\arguments{
\item{taxaTree}{A tree with tip taxon names matching the taxon names
in \code{taxaDataPBDB}. Probably a taxon tree estimated
with \code{\link{makePBDBtaxonTree}}.}

\item{taxaDataPBDB}{A data table of taxonomic information obtained
using the Paleobiology Database's API for a set of taxa that
includes the tip taxa on \code{taxaTree}, generated with
parameter \code{show = app} so that appearance times are included.}

\item{minBranchLen}{Following dating using the appearance times taken directly
from the PBDB for each tip taxon and node, the tree may then be assessed with
the minimum branch length algorithm, as applied by \code{\link{minBranchLength}}.
If \code{minBranchLen = 0}, the default, this step is skipped. It may be necessary
to set \code{minBranchLen} higher than zero to differentiate nodes in cases
with poor stratigraphic congruency, so that derived taxa are the first taxa
observed in a group.}

\item{tipTaxonDateUsed}{Controls what date for a taxon from the PBDB
is used for 'when' the tip should be placed in the dated phylogeny
produced by this function. The default, \code{tipTaxonDateUsed = "shallowestAge"}
will use the minimum age of the last appearance time of that taxon, which if it
is extant will be 0, and if it is extinct, will be the maximum constraint on the
age of its last appearance (i.e. the last time we saw it before it went extinct).
A second option is \code{"deepestAge"}, which is the oldest possible first appearance time
from the PBDB, i.e. the maximum age constraint for the first appearance. As closely
related taxa often first occur in the same short interval of geologic time, due to
diversification bursts and/or the heterogeneity of fossil preservation, this may
result in confusing polytomies of many terminal taxa with no terminal branch lengths.}

\item{dropZeroOccurrenceTaxa}{If \code{TRUE}, the default, then extinct taxa
or extinct clades found to have zero occurrences in the Paleobiology Database
are removed. If this option isn't used, the function will likely fail as nodes
or tips with \code{NA} ages listed cannot be processed by \code{parentChild2TaxonTree}.}

\item{plotTree}{If \code{TRUE}, the resulting dated tree is plotted.
This is \code{FALSE} by default.}

\item{failIfNoInternet}{If the Paleobiology Database or another 
needed internet resource cannot be accessed, perhaps because of
no internet connection, should the function fail (with an error)
or should the function return \code{NULL} and return an
informative message instead, thus meeting the CRAN policy
that such functionalities must 'fail gracefully'?
The default is \code{TRUE} but all examples that might be auto-run
use \code{FALSE} so they do not fail during R CHECK.}
}
\value{
Returns a dated phylogeny of class \code{phylo}, with an additional element
\code{$taxaDataPBDB} added containing the input \code{taxaDataPBDB}, as this might be
called by other functions.
}
\description{
The function \code{dateTaxonTreePBDB} takes a input consisting of
a topology, with tip and internal node labels corresponding to
taxa in the Paleobiology Database, and a table of data (containing those same tip and
node taxa) obtained from the taxa-list functionality of the Paleobiology Database's API,
with appearance times. This function will then output a tree with nodes reflecting the
ages of the respective higher taxa, based on their earliest times of appearance
from the Paleobiology Database.
}
\details{
The dating by this function is very simplistic, representing a rather
straight interpretation of what the PBDB reports. The dated trees
produced should not be taken overly seriously.
}
\examples{
# Note that all examples here use argument 
    # failIfNoInternet = FALSE so that functions do
    # not error out but simply return NULL if internet
    # connection is not available, and thus
    # fail gracefully rather than error out (required by CRAN).
# Remove this argument or set to TRUE so functions fail
    # when internet resources (paleobiodb) is not available.
    
\donttest{

taxaAnimals <- c("Archaeopteryx", "Eldredgeops",
	"Corvus", "Acropora", "Velociraptor", "Gorilla", 
	"Olenellus", "Lingula", "Dunkleosteus",
	"Tyrannosaurus", "Triceratops", "Giraffa",
	"Megatheriidae", "Aedes", "Histiodella",
	"Rhynchotrema", "Pecten", "Homo", "Dimetrodon",
	"Nemagraptus", "Panthera", "Anomalocaris")

animalData <-getSpecificTaxaPBDB(taxaAnimals, 
    failIfNoInternet = FALSE)
    
if(!is.null(animalData)){

tree <- makePBDBtaxonTree(animalData, 
    rankTaxon = "genus")

#get the ranges 
timeTree <- dateTaxonTreePBDB(tree)
    
}

}

#####################################

\dontrun{
 
# plotting the tree with phyloPics

plotPhyloPicTree(tree = timeTree,
     depthAxisPhylo = TRUE, 
     failIfNoInternet = FALSE)


# can also plot dated tree with strap

library(strap)
#now plot it
strap::geoscalePhylo(
    tree = timeTree,
    direction = "upwards",
    ages = rangesMinMax,
    cex.tip = 0.7,
    cex.ts = 0.55,
    cex.age = 0.5,
    width = 3,
    tick.scale = 50,
    quat.rm = TRUE,
    boxes = "Period",
    arotate = 90,
    units = c("Eon","Period","Era"),
    x.lim = c(650,-20)
    )
}

##############################################################

## HORSES

\donttest{
#if(require(curl)){

# we can also use this for pre-existing trees
    # for example, this tree of equuids (horses)
    # borrowed from UCMP materials on horse evolution
    # https://evolution.berkeley.edu/evolibrary/images/HorseTree.pdf
    # (apparently from MacFadden, 1992? Citation above)

# read the tree in as Newick string
horseTree <- ape::read.tree(file=NULL, 
    text = paste0(
         "(Eohippus,(Xenicohippus,(Haplohippus,(Epihippus,",
         "(Miohippus,(((Hypohippus,Megahippus),(Anchitherium,",
         "Kalobatippus)),(Archaeohippus,(Desmatippus,(Parahippus,",
         "(Merychippus,(((Hipparion_Merychippus,(Nannippus,",
         " Cormohipparion)),(Pseudhipparion,(Neohipparion,",
         " Hipparion))),(Equine_Merychippus,((Protohippus,Calippus),",
         "(Pliohippus,(Astrohippus,(Dinohippus,Equus))))))))))))))));"
         )
    )

# note there is a message that the tree lacks node names
    # this is unexpected / atypical for taxon trees

plot(horseTree)

# now let's get data on the tip from the PBDB
    # using getSpecificTaxaPBDB
horseData <- getSpecificTaxaPBDB(horseTree$tip.label, 
    failIfNoInternet = FALSE)

if(!is.null(horseData)){

# now we can date the tree with dateTaxonTreePBDB

datedHorseTree <- dateTaxonTreePBDB(
    taxaTree = horseTree,
    taxaDataPBDB = horseData,
    minBranchLen = 1, 
    failIfNoInternet = FALSE)

# and let's try plotting it!	
plotPhyloPicTree(
    tree = datedHorseTree,
    depthAxisPhylo = TRUE, 
    failIfNoInternet = FALSE)		
	
# a fairly boring phylopic diagram
     # not many horse phylopics as of 07-16-19?

}

#}
}

\dontrun{

# Let's look at this horse tree with strap

library(strap)

geoscalePhylo(
    tree = datedHorseTree,
    ages = datedHorseTree$ranges.used,
    cex.tip = 0.7,
    cex.ts = 0.7,
    cex.age = 0.7,
    width = 4,
    tick.scale = 15,
    boxes = "Epoch",
    erotate = 90,
    quat.rm = TRUE,
    units = c("Period","Epoch"),
    x.lim = c(65,-10)
    )

}

}
\references{
Peters, S. E., and M. McClennen. 2015. The Paleobiology Database
application programming interface. \emph{Paleobiology} 42(1):1-7.

The equuid tree used in the examples is from:
MacFadden, B. J. 1992. Fossil horses: systematics, paleobiology, and
evolution of the family Equidae. \emph{Cambridge University Press}.
}
\seealso{
See \code{\link{getDataPBDB}}, \code{\link{makePBDBtaxonTree}},
and \code{\link{plotPhyloPicTree}}.
}
\author{
David W. Bapst
}
